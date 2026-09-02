#!/usr/bin/env sh
set -eu
root=/root/yul-vending-machine
source=${1:?backup file is required}
if [ "$(id -u)" -ne 0 ]; then
    printf '%s\n' "restore must run as root" >&2
    exit 1
fi
source=$(realpath -e -- "$source") || {
    printf '%s\n' "backup file does not exist" >&2
    exit 1
}
case "$source" in
    "$root/shared/backups/"*) ;;
    *) printf '%s\n' "backup must be inside shared/backups" >&2; exit 1 ;;
esac
if [ ! -f "$source" ]; then
    printf '%s\n' "backup file does not exist" >&2
    exit 1
fi
maintenance="$root/current/deploy/sqlite-maintenance.sh"
integrity=$(sh "$maintenance" integrity "$source")
if [ "$integrity" != "ok" ]; then
    printf 'backup integrity check failed: %s\n' "$integrity" >&2
    exit 1
fi
pre_restore="$root/shared/backups/pre-restore-$(date -u +%Y%m%dT%H%M%SZ).db"
"$root/current/deploy/backup.sh" "$pre_restore" >/dev/null
restore_previous() {
    systemctl stop yul-vending-machine.service || true
    install -o root -g root -m 0600 "$pre_restore" "$root/shared/data/vending.db"
    systemctl start yul-vending-machine.service || true
}
systemctl stop yul-vending-machine.service || true
if ! install -o root -g root -m 0600 "$source" "$root/shared/data/vending.db"; then
    restore_previous
    exit 1
fi
if ! systemctl start yul-vending-machine.service; then
    restore_previous
    exit 1
fi
if ! sh "$root/current/deploy/healthcheck.sh"; then
    restore_previous
    exit 1
fi
