#!/usr/bin/env sh
set -eu
release=${1:?release directory is required}
case "$release" in
    /*) ;;
    *) printf '%s\n' "release must be an absolute path" >&2; exit 1 ;;
esac
release=$(realpath -e -- "$release")
if [ ! -f "$release/SHA256SUMS" ] || [ ! -f "$release/RELEASE.json" ]; then
    printf '%s\n' "release manifest or metadata is missing" >&2
    exit 1
fi
if ! grep -Eq '"schema"[[:space:]]*:[[:space:]]*1([,}])' "$release/RELEASE.json" || ! grep -Fq '"architecture":"linux-aarch64"' "$release/RELEASE.json"; then
    printf '%s\n' "release metadata is not for Linux AArch64" >&2
    exit 1
fi
if ! grep -Eq '"source_commit":"[0-9a-fA-F]{40}"' "$release/RELEASE.json"; then
    printf '%s\n' "release source commit metadata is invalid" >&2
    exit 1
fi
release_id=$(basename "$release")
case "$release_id" in
    ""|*[!A-Za-z0-9._-]*) printf '%s\n' "invalid release id" >&2; exit 1 ;;
esac
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
verify_dir=""
cleanup() {
    if [ -n "$verify_dir" ]; then
        rm -rf -- "$verify_dir"
    fi
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
rm -f -- "$manifest_sorted"
if ! (cd "$release" && sha256sum --strict --check SHA256SUMS); then
    printf '%s\n' "release checksum verification failed" >&2
    exit 1
fi
for required in yul-vending-machine yul-core.so config.example.ini deploy/install.sh deploy/install-trusted.sh deploy/verify-release.sh deploy/verify-trusted-release.sh deploy/healthcheck.sh deploy/backup.sh deploy/restore.sh deploy/rollback.sh deploy/rollback-trusted.sh deploy/sqlite-maintenance.sh deploy/yul-vending-machine.service; do
    if [ ! -f "$release/$required" ]; then
        printf 'required release file is missing: %s\n' "$required" >&2
        exit 1
    fi
done
if [ ! -x "$release/yul-vending-machine" ]; then
    printf '%s\n' "native launcher is not executable" >&2
    exit 1
fi
if ! command -v file >/dev/null 2>&1; then
    printf '%s\n' "file utility is required for architecture verification" >&2
    exit 1
fi
launcher_type=$(file -Lb "$release/yul-vending-machine")
core_type=$(file -Lb "$release/yul-core.so")
if ! printf '%s\n' "$launcher_type" | grep -Eiq 'ELF.*(aarch64|ARM)'; then
    printf 'unexpected launcher type: %s\n' "$launcher_type" >&2
    exit 1
fi
if ! printf '%s\n' "$core_type" | grep -Eiq 'ELF.*(aarch64|ARM)'; then
    printf 'unexpected core type: %s\n' "$core_type" >&2
    exit 1
fi
if printf '%s\n' "$launcher_type" | grep -Eiq 'not stripped|debug_info'; then
    printf '%s\n' "native launcher must be stripped" >&2
    exit 1
fi
if printf '%s\n' "$core_type" | grep -Eiq 'not stripped|debug_info'; then
    printf '%s\n' "native core must be stripped" >&2
    exit 1
fi
if ! command -v readelf >/dev/null 2>&1; then
    printf '%s\n' "readelf is required for ELF hardening verification" >&2
    exit 1
fi
launcher_elf=$(readelf -h -l -d "$release/yul-vending-machine")
core_elf=$(readelf -h -l -d "$release/yul-core.so")
if ! printf '%s\n' "$launcher_elf" | grep -Eq 'Type:[[:space:]]+DYN|Elf file type is DYN'; then
    printf '%s\n' "native launcher must be a position-independent executable" >&2
    exit 1
fi
if ! printf '%s\n' "$launcher_elf" | grep -q 'GNU_RELRO'; then
    printf '%s\n' "native launcher is missing GNU_RELRO" >&2
    exit 1
fi
stack_line=$(printf '%s\n' "$launcher_elf" | grep 'GNU_STACK' || true)
if [ -z "$stack_line" ] || printf '%s\n' "$stack_line" | grep -Eq 'RWE|RWX'; then
    printf '%s\n' "native launcher has an executable GNU_STACK" >&2
    exit 1
fi
if ! printf '%s\n' "$launcher_elf" | grep -Eq 'BIND_NOW|FLAGS_1.*NOW'; then
    printf '%s\n' "native launcher is missing immediate symbol binding" >&2
    exit 1
fi
if ! printf '%s\n' "$core_elf" | grep -Eq 'Type:[[:space:]]+DYN|Elf file type is DYN'; then
    printf '%s\n' "native core must be a shared ELF object" >&2
    exit 1
fi
if ! printf '%s\n' "$core_elf" | grep -q 'GNU_RELRO'; then
    printf '%s\n' "native core is missing GNU_RELRO" >&2
    exit 1
fi
core_stack_line=$(printf '%s\n' "$core_elf" | grep 'GNU_STACK' || true)
if [ -z "$core_stack_line" ] || printf '%s\n' "$core_stack_line" | grep -Eq 'RWE|RWX'; then
    printf '%s\n' "native core has an executable GNU_STACK" >&2
    exit 1
fi
if ! printf '%s\n' "$core_elf" | grep -Eq 'BIND_NOW|FLAGS_1.*NOW'; then
    printf '%s\n' "native core is missing immediate symbol binding" >&2
    exit 1
fi
if readelf -S "$release/yul-vending-machine" | grep -Eq '\.symtab|\.debug_'; then
    printf '%s\n' "native launcher must not contain local symbol or debug sections" >&2
    exit 1
fi
if readelf -S "$release/yul-core.so" | grep -Eq '\.symtab|\.debug_'; then
    printf '%s\n' "native core must not contain local symbol or debug sections" >&2
    exit 1
fi
if ! command -v ldconfig >/dev/null 2>&1; then
    printf '%s\n' "ldconfig is required for native dependency verification" >&2
    exit 1
fi
if ! ldconfig -p 2>/dev/null | grep -Fq 'libcurl.so.4'; then
    printf '%s\n' "libcurl.so.4 is not available on the target" >&2
    exit 1
fi
if ! ldconfig -p 2>/dev/null | grep -Fq 'libsqlite3.so.0'; then
    printf '%s\n' "libsqlite3.so.0 is not available on the target" >&2
    exit 1
fi
if ! command -v timeout >/dev/null 2>&1; then
    printf '%s\n' "timeout is required for native validation smoke" >&2
    exit 1
fi
if ! command -v sqlite3 >/dev/null 2>&1; then
    if ! command -v python3 >/dev/null 2>&1 || ! python3 -c 'import sqlite3' >/dev/null 2>&1; then
        printf '%s\n' "sqlite3 CLI or Python sqlite3 module is required for healthcheck and backup" >&2
        exit 1
    fi
fi
verify_dir=$(mktemp -d "${TMPDIR:-/tmp}/yul-release-verify.XXXXXX")
mkdir -p "$verify_dir/data"
{
    printf '%s\n' 'DISCORD_BOT_TOKEN=release-verify-token'
    printf '%s\n' 'DISCORD_APPLICATION_ID=123456789012345678'
    printf '%s\n' 'DISCORD_GUILD_ID=223456789012345678'
    printf '%s\n' 'DISCORD_PANEL_CHANNEL_ID=323456789012345678'
    printf '%s\n' 'DISCORD_ADMIN_USER_ID=423456789012345678'
    printf '%s\n' 'DISCORD_GATEWAY_URL=wss://127.0.0.1/'
    printf '%s\n' 'DISCORD_INTENTS=1'
    printf '%s\n' 'PUSHBULLET_ACCESS_TOKEN=release-verify-push-token'
    printf '%s\n' 'PUSHBULLET_STREAM_URL=wss://127.0.0.1/'
    printf '%s\n' 'BANK_NAME=release-verify-bank'
    printf '%s\n' 'BANK_ACCOUNT_NUMBER=1234567890'
    printf '%s\n' 'BANK_ACCOUNT_HOLDER=release-verify-holder'
    printf '%s\n' 'BANK_PACKAGE_NAME=com.release.verify'
    printf '%s\n' 'BANK_APPLICATION_NAME=ReleaseVerify'
    printf '%s\n' 'BANK_TITLE_PREFIX='
    printf '%s\n' 'BANK_TITLE_PATTERN=^[0-9][0-9,]*원\s*입금$'
    printf '%s\n' 'BANK_AMOUNT_PATTERN=([0-9][0-9,]*)원\s*입금'
    printf '%s\n' 'BANK_NAME_PATTERN=^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$'
    printf '%s\n' 'ORDER_TTL_SECONDS=1800'
    printf '%s\n' 'AUTO_CREDIT=1'
    printf 'DATABASE_PATH=%s\n' "$verify_dir/data/vending.db"
} > "$verify_dir/complete.ini"
if ! timeout 5 "$release/yul-vending-machine" --config "$verify_dir/complete.ini" validate-config >/dev/null 2>&1; then
    printf '%s\n' "native validate-config smoke failed" >&2
    exit 1
fi
sed '/^DISCORD_BOT_TOKEN=/d' "$verify_dir/complete.ini" > "$verify_dir/missing.ini"
if timeout 5 "$release/yul-vending-machine" --config "$verify_dir/missing.ini" validate-config >/dev/null 2>&1; then
    printf '%s\n' "native validate-config accepted a missing required value" >&2
    exit 1
fi
sed 's/^DISCORD_BOT_TOKEN=.*/DISCORD_BOT_TOKEN=/' "$verify_dir/complete.ini" > "$verify_dir/empty.ini"
if timeout 5 "$release/yul-vending-machine" --config "$verify_dir/empty.ini" validate-config >/dev/null 2>&1; then
    printf '%s\n' "native validate-config accepted an empty required value" >&2
    exit 1
fi
sed 's/^ORDER_TTL_SECONDS=.*/ORDER_TTL_SECONDS=not-a-number/' "$verify_dir/complete.ini" > "$verify_dir/invalid-number.ini"
if timeout 5 "$release/yul-vending-machine" --config "$verify_dir/invalid-number.ini" validate-config >/dev/null 2>&1; then
    printf '%s\n' "native validate-config accepted an invalid numeric value" >&2
    exit 1
fi
printf '%s\n' "release verified: Linux AArch64"
