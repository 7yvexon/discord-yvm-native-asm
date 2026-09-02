#!/bin/sh
set -eu

PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH

target=${1:?release id is required}
trusted_digest=${2:?trusted SHA256SUMS digest file is required}
root=${YUL_INSTALL_ROOT:-/root/yul-vending-machine}
trusted_verifier=/usr/local/sbin/yul-vending-machine-verify-trusted-release
trusted_root=/etc/yul-vending-machine/trusted

if [ "$(id -u)" -ne 0 ]; then
    printf '%s\n' "trusted rollback must run as root" >&2
    exit 1
fi
if [ "$root" != "/root/yul-vending-machine" ]; then
    printf '%s\n' "custom install roots are not supported by the systemd unit" >&2
    exit 1
fi
case "$target" in
    *[!A-Za-z0-9._-]*) printf '%s\n' "invalid release id" >&2; exit 1 ;;
esac
if [ ! -d "$root/releases" ] || [ -L "$root/releases" ]; then
    printf '%s\n' "release directory is not protected" >&2
    exit 1
fi
release=$(realpath -e -- "$root/releases/$target" 2>/dev/null || true)
if [ -z "$release" ] || [ ! -d "$release" ]; then
    printf '%s\n' "release does not exist" >&2
    exit 1
fi
case "$release" in
    "$root/releases/"*) ;;
    *) printf '%s\n' "rollback release points outside releases" >&2; exit 1 ;;
esac
if [ "$(basename "$release")" != "$target" ]; then
    printf '%s\n' "rollback release id is a symlink alias" >&2
    exit 1
fi
if [ ! -f "$trusted_verifier" ] || [ -L "$trusted_verifier" ] || [ ! -x "$trusted_verifier" ] || [ "$(stat -c '%u' -- "$trusted_verifier")" != "0" ] || find "$trusted_verifier" -maxdepth 0 -perm /022 -print -quit | grep -q .; then
    printf '%s\n' "host trusted verifier is missing or not protected" >&2
    exit 1
fi
trusted_verifier_parent=$(dirname -- "$trusted_verifier")
if [ "$(stat -c '%u' -- "$trusted_verifier_parent")" != "0" ] || find "$trusted_verifier_parent" -maxdepth 0 -perm /022 -print -quit | grep -q .; then
    printf '%s\n' "trusted verifier directory must be root-owned and non-writable" >&2
    exit 1
fi
case "$trusted_digest" in
    "$trusted_root"/*) ;;
    *) printf '%s\n' "trusted digest must be under the protected trust directory" >&2; exit 1 ;;
esac
/bin/sh "$trusted_verifier" "$release" "$trusted_digest" "$target"
if [ -e "$root/current" ] && [ ! -L "$root/current" ]; then
    printf '%s\n' "current must be a symlink" >&2
    exit 1
fi
old_target=$(realpath -e -- "$root/current" 2>/dev/null || true)
if [ -L "$root/current" ] && [ -z "$old_target" ]; then
    printf '%s\n' "current points to a missing release" >&2
    exit 1
fi
if [ -n "$old_target" ]; then
    case "$old_target" in
        "$root/releases/"*) ;;
        *) printf '%s\n' "current points outside releases" >&2; exit 1 ;;
    esac
fi
restore_previous() {
    if [ -n "$old_target" ]; then
        ln -sfn "$old_target" "$root/current"
        systemctl restart yul-vending-machine.service || true
    fi
}
ln -sfn -- "$release" "$root/current"
if ! systemctl restart yul-vending-machine.service; then
    restore_previous
    exit 1
fi
if ! /bin/sh "$root/current/deploy/healthcheck.sh"; then
    restore_previous
    exit 1
fi
