#!/usr/bin/env sh
set -eu
root=/root/yul-vending-machine
if [ "$(id -u)" -ne 0 ]; then
    printf '%s\n' "backup must run as root" >&2
    exit 1
fi
database="$root/shared/data/vending.db"
target=${1:-"$root/shared/backups/vending-$(date -u +%Y%m%dT%H%M%SZ).db"}
target=$(realpath -m -- "$target")
case "$target" in
    "$root/shared/backups/"*) ;;
    *) printf '%s\n' "backup target must be inside shared/backups" >&2; exit 1 ;;
esac
if [ "$target" = "$root/shared/backups" ]; then
    printf '%s\n' "backup target must be a file" >&2
    exit 1
fi
target_name=${target##*/}
case "$target_name" in
    ""|*[!A-Za-z0-9._-]*) printf '%s\n' "backup filename contains unsupported characters" >&2; exit 1 ;;
esac
if [ ! -f "$database" ]; then
    printf '%s\n' "database does not exist" >&2
    exit 1
fi
maintenance="$root/current/deploy/sqlite-maintenance.sh"
integrity=$(sh "$maintenance" integrity "$database")
if [ "$integrity" != "ok" ]; then
    printf 'database integrity check failed: %s\n' "$integrity" >&2
    exit 1
fi
install -d -m 0700 "$root/shared/backups"
temporary="$target.tmp.$$"
trap 'rm -f -- "$temporary"' EXIT HUP INT TERM
sh "$maintenance" backup "$database" "$temporary"
temporary_integrity=$(sh "$maintenance" integrity "$temporary")
if [ "$temporary_integrity" != "ok" ]; then
    printf 'backup integrity check failed: %s\n' "$temporary_integrity" >&2
    exit 1
fi
mv -f -- "$temporary" "$target"
trap - EXIT HUP INT TERM
chown root:root "$target"
chmod 0600 "$target"
printf '%s\n' "$target"
