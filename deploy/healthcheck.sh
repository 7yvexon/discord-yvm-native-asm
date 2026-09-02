#!/usr/bin/env sh
set -eu
root=/root/yul-vending-machine
service=yul-vending-machine.service
if [ "$(id -u)" -ne 0 ]; then
    printf '%s\n' "healthcheck must run as root" >&2
    exit 1
fi
active=$(systemctl is-active "$service" || true)
if [ "$active" != "active" ]; then
    printf 'service: %s\n' "$active" >&2
    systemctl --no-pager --full status "$service" || true
    exit 1
fi
if ! "$root/current/yul-vending-machine" --config "$root/shared/config/vending.ini" validate-config; then
    printf '%s\n' "native configuration validation failed" >&2
    exit 1
fi
database="$root/shared/data/vending.db"
if [ ! -f "$database" ]; then
    printf '%s\n' "database is missing" >&2
    exit 1
fi
integrity=$(sh "$root/current/deploy/sqlite-maintenance.sh" integrity "$database")
if [ "$integrity" != "ok" ]; then
    printf 'database integrity: %s\n' "$integrity" >&2
    exit 1
fi
version=$(sh "$root/current/deploy/sqlite-maintenance.sh" version "$database")
if [ "$version" -lt 2 ]; then
    printf 'database schema version is too old: %s\n' "$version" >&2
    exit 1
fi
main_pid=$(systemctl show -p MainPID --value "$service")
sub_state=$(systemctl show -p SubState --value "$service")
last_status=$(systemctl show -p ExecMainStatus --value "$service")
printf 'service=%s sub_state=%s pid=%s last_exit=%s schema_version=%s\n' "$active" "$sub_state" "$main_pid" "$last_status" "$version"
