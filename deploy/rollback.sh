#!/usr/bin/env sh
set -eu
printf '%s\n' "direct release rollback is disabled; use a host-trusted deploy/rollback-trusted.sh with an external SHA256SUMS digest" >&2
exit 1
