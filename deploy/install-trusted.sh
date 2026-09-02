#!/bin/sh
set -eu

PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH

release=${1:?release directory is required}
trusted_digest=${2:?trusted SHA256SUMS digest file is required}
root=${YUL_INSTALL_ROOT:-/root/yul-vending-machine}
trusted_verifier=/usr/local/sbin/yul-vending-machine-verify-trusted-release
trusted_unit=/usr/local/share/yul-vending-machine/yul-vending-machine.service

if [ "$(id -u)" -ne 0 ]; then
    printf '%s\n' "trusted install must run as root" >&2
    exit 1
fi
if [ "$root" != "/root/yul-vending-machine" ]; then
    printf '%s\n' "custom install roots are not supported by the systemd unit" >&2
    exit 1
fi
case "$release" in
    /*) ;;
    *) printf '%s\n' "release must be an absolute path" >&2; exit 1 ;;
esac
release=$(realpath -e -- "$release")
release_id=$(basename "$release")
case "$release_id" in
    ""|*[!A-Za-z0-9._-]*) printf '%s\n' "invalid release id" >&2; exit 1 ;;
esac
if [ -e "$root/releases/$release_id" ] || [ -L "$root/releases/$release_id" ]; then
    printf '%s\n' "release id already exists" >&2
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
if [ ! -f "$trusted_unit" ] || [ -L "$trusted_unit" ] || [ "$(stat -c '%u' -- "$trusted_unit")" != "0" ] || find "$trusted_unit" -maxdepth 0 -perm /022 -print -quit | grep -q .; then
    printf '%s\n' "host trusted systemd unit is missing or not protected" >&2
    exit 1
fi
trusted_unit_parent=$(dirname -- "$trusted_unit")
if [ "$(stat -c '%u' -- "$trusted_unit_parent")" != "0" ] || find "$trusted_unit_parent" -maxdepth 0 -perm /022 -print -quit | grep -q .; then
    printf '%s\n' "trusted systemd unit directory must be root-owned and non-writable" >&2
    exit 1
fi

if [ -e "$root/current" ] && [ ! -L "$root/current" ]; then
    printf '%s\n' "$root/current must be a symlink" >&2
    exit 1
fi
if [ -L "$root/current" ]; then
    old_current=$(realpath -e -- "$root/current" 2>/dev/null || true)
    if [ -z "$old_current" ]; then
        printf '%s\n' "$root/current points to a missing release" >&2
        exit 1
    fi
    case "$old_current" in
        "$root/releases/"*) ;;
        *) printf '%s\n' "$root/current points outside releases" >&2; exit 1 ;;
    esac
fi

install -d -o root -g root -m 0755 "$root/releases"
install -d -o root -g root -m 0700 "$root/shared" "$root/shared/config" "$root/shared/data" "$root/shared/backups" "$root/shared/logs" "$root/shared/runtime"
stage=$(mktemp -d "$root/.release-staging.XXXXXX")
cleanup() {
    rm -rf -- "$stage"
}
trap cleanup EXIT HUP INT TERM
cp -a "$release"/. "$stage"/
/bin/sh "$trusted_verifier" "$stage" "$trusted_digest" "$release_id"

chown -R root:root "$stage"
find "$stage" -type d -exec chmod 0755 {} +
find "$stage" -type f -exec chmod 0644 {} +
chmod 0755 "$stage/yul-vending-machine"
chmod 0750 "$stage"/deploy/*.sh
/bin/sh "$trusted_verifier" "$stage" "$trusted_digest" "$release_id"
mv -- "$stage" "$root/releases/$release_id"
trap - EXIT HUP INT TERM

ln -sfn "$root/releases/$release_id" "$root/current"
chown -R root:root "$root/shared"
if [ ! -e "$root/shared/config/vending.ini" ]; then
    if [ ! -f "$root/current/config.example.ini" ]; then
        printf '%s\n' "release does not contain config.example.ini" >&2
        exit 1
    fi
    install -o root -g root -m 0600 "$root/current/config.example.ini" "$root/shared/config/vending.ini"
    sed -i "s#^DATABASE_PATH=.*#DATABASE_PATH=$root/shared/data/vending.db#" "$root/shared/config/vending.ini"
fi
chown root:root "$root/shared/config/vending.ini"
chmod 0600 "$root/shared/config/vending.ini"
install -m 0644 "$trusted_unit" /etc/systemd/system/yul-vending-machine.service
systemctl daemon-reload
systemctl enable yul-vending-machine.service
printf '%s\n' "configure $root/shared/config/vending.ini (0600) before starting yul-vending-machine.service"
