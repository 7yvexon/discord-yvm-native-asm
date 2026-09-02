#!/bin/sh
set -eu

PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH

release=${1:?release directory is required}
trusted_digest=${2:?trusted SHA256SUMS digest file is required}
expected_release_id=${3:-}
trusted_root=/etc/yul-vending-machine/trusted

case "$release" in
    /*) ;;
    *) printf '%s\n' "release must be an absolute path" >&2; exit 1 ;;
esac
case "$trusted_digest" in
    /*) ;;
    *) printf '%s\n' "trusted digest must be an absolute path" >&2; exit 1 ;;
esac
if [ -L "$trusted_digest" ]; then
    printf '%s\n' "trusted digest must not be a symbolic link" >&2
    exit 1
fi
release=$(realpath -e -- "$release")
trusted_digest=$(realpath -e -- "$trusted_digest")
if [ ! -d "$release" ]; then
    printf '%s\n' "release directory does not exist" >&2
    exit 1
fi
if [ ! -f "$trusted_digest" ]; then
    printf '%s\n' "trusted digest file does not exist" >&2
    exit 1
fi
if [ ! -d "$trusted_root" ] || [ -L "$trusted_root" ] || [ "$(stat -c '%u' -- "$trusted_root")" != "0" ] || find "$trusted_root" -maxdepth 0 -perm /022 -print -quit | grep -q .; then
    printf '%s\n' "trusted directory must be root-owned and non-writable" >&2
    exit 1
fi
trusted_root_parent=$(dirname -- "$trusted_root")
if [ "$(stat -c '%u' -- "$trusted_root_parent")" != "0" ] || find "$trusted_root_parent" -maxdepth 0 -perm /022 -print -quit | grep -q .; then
    printf '%s\n' "trusted directory parent must be root-owned and non-writable" >&2
    exit 1
fi
case "$trusted_digest" in
    "$release"/*) printf '%s\n' "trusted digest must be outside the release" >&2; exit 1 ;;
    "$trusted_root"/*) ;;
    *) printf '%s\n' "trusted digest must be under the protected trust directory" >&2; exit 1 ;;
esac
if [ -L "$trusted_digest" ] || [ "$(stat -c '%u' -- "$trusted_digest")" != "0" ] || find "$trusted_digest" -maxdepth 0 -perm /022 -print -quit | grep -q .; then
    printf '%s\n' "trusted digest must be a root-owned non-writable regular file" >&2
    exit 1
fi
trusted_digest_parent=$(dirname -- "$trusted_digest")
if [ "$(stat -c '%u' -- "$trusted_digest_parent")" != "0" ] || find "$trusted_digest_parent" -maxdepth 0 -perm /022 -print -quit | grep -q .; then
    printf '%s\n' "trusted digest directory must be root-owned and non-writable" >&2
    exit 1
fi
if [ ! -f "$release/SHA256SUMS" ]; then
    printf '%s\n' "release checksum manifest is missing" >&2
    exit 1
fi
release_id=$(basename "$release")
if [ -n "$expected_release_id" ]; then
    release_id=$expected_release_id
fi
case "$release_id" in
    ""|*[!A-Za-z0-9._-]*) printf '%s\n' "invalid release id" >&2; exit 1 ;;
esac
trusted_digest_name=$(basename "$trusted_digest")
if [ "$trusted_digest_name" != "$release_id.SHA256SUMS.sha256" ]; then
    printf '%s\n' "trusted digest filename does not match release id" >&2
    exit 1
fi
digest_line_count=$(awk 'END { print NR + 0 }' "$trusted_digest")
nonempty_digest_lines=$(awk 'NF { count++ } END { print count + 0 }' "$trusted_digest")
if [ "$digest_line_count" -ne 1 ] || [ "$nonempty_digest_lines" -ne 1 ] || ! grep -Eq '^[[:space:]]*[0-9a-fA-F]{64}[[:space:]]+SHA256SUMS[[:space:]]*$' "$trusted_digest"; then
    printf '%s\n' "trusted digest file must contain exactly one SHA-256 manifest digest" >&2
    exit 1
fi
expected_digest=$(awk 'NF { print tolower($1) }' "$trusted_digest")
if [ "${#expected_digest}" -ne 64 ]; then
    printf '%s\n' "trusted digest file must contain a SHA-256 digest" >&2
    exit 1
fi
actual_digest=$(/usr/bin/sha256sum -- "$release/SHA256SUMS" | awk '{print tolower($1)}')
if [ "$actual_digest" != "$expected_digest" ]; then
    printf '%s\n' "release checksum manifest is not trusted" >&2
    exit 1
fi
if ! grep -Fq "\"release_id\":\"$release_id\"" "$release/RELEASE.json"; then
    printf '%s\n' "release metadata id does not match release directory" >&2
    exit 1
fi
if find "$release" -type l -print -quit | grep -q .; then
    printf '%s\n' "release must not contain symbolic links" >&2
    exit 1
fi
special_path=$(find "$release" ! -type d ! -type f -print -quit)
if [ -n "$special_path" ]; then
    printf 'release contains a non-regular file: %s\n' "$special_path" >&2
    exit 1
fi
manifest_seen=$(mktemp)
release_files=$(mktemp)
manifest_sorted=$(mktemp)
cleanup() {
    rm -f -- "$manifest_seen" "$release_files" "$manifest_sorted"
}
trap cleanup EXIT HUP INT TERM
while IFS= read -r manifest_line || [ -n "$manifest_line" ]; do
    [ -z "$(printf '%s' "$manifest_line" | tr -d '[:space:]')" ] && continue
    manifest_hash=$(printf '%s\n' "$manifest_line" | awk '{print $1}')
    manifest_path=$(printf '%s\n' "$manifest_line" | sed -E 's/^[[:xdigit:]]{64}[[:space:]]+//')
    if ! printf '%s\n' "$manifest_hash" | grep -Eq '^[[:xdigit:]]{64}$' || [ -z "$manifest_path" ]; then
        printf '%s\n' "invalid checksum manifest entry" >&2
        exit 1
    fi
    case "$manifest_path" in
        ""|SHA256SUMS|/*|*'..'*|*'\\'*|*//*|*/) printf '%s\n' "unsafe checksum path" >&2; exit 1 ;;
    esac
    if ! printf '%s\n' "$manifest_path" | grep -Eq '^[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)*$'; then
        printf '%s\n' "unsafe checksum path" >&2
        exit 1
    fi
    if ! printf '%s\n' "$manifest_path" | grep -Fqx -- "$manifest_path" "$manifest_seen" 2>/dev/null; then
        printf '%s\n' "$manifest_path" >> "$manifest_seen"
    else
        printf '%s\n' "duplicate checksum manifest path" >&2
        exit 1
    fi
    if [ ! -f "$release/$manifest_path" ]; then
        printf 'checksum target is missing: %s\n' "$manifest_path" >&2
        exit 1
    fi
done < "$release/SHA256SUMS"
find "$release" -type f ! -path "$release/SHA256SUMS" -printf '%P\n' | sort > "$release_files"
sort "$manifest_seen" > "$manifest_sorted"
if ! cmp -s "$release_files" "$manifest_sorted"; then
    printf '%s\n' "checksum manifest does not cover exactly the release files" >&2
    exit 1
fi
for required in yul-vending-machine yul-core.so config.example.ini deploy/install.sh deploy/install-trusted.sh deploy/verify-release.sh deploy/verify-trusted-release.sh deploy/healthcheck.sh deploy/backup.sh deploy/restore.sh deploy/rollback.sh deploy/rollback-trusted.sh deploy/sqlite-maintenance.sh deploy/yul-vending-machine.service; do
    if [ ! -f "$release/$required" ]; then
        printf 'required release file is missing: %s\n' "$required" >&2
        exit 1
    fi
done
if ! (cd "$release" && /usr/bin/sha256sum --strict --check SHA256SUMS); then
    printf '%s\n' "release checksum verification failed before trusted installation" >&2
    exit 1
fi
post_digest=$(/usr/bin/sha256sum -- "$release/SHA256SUMS" | awk '{print tolower($1)}')
if [ "$post_digest" != "$expected_digest" ]; then
    printf '%s\n' "release checksum manifest changed during trusted verification" >&2
    exit 1
fi
if ! (cd "$release" && /usr/bin/sha256sum --strict --check SHA256SUMS); then
    printf '%s\n' "release checksum verification failed after trusted verification" >&2
    exit 1
fi
printf '%s\n' "trusted release verified"
