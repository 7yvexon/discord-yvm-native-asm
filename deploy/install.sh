#!/usr/bin/env sh
set -eu
printf '%s\n' "direct release installation is disabled; use a host-trusted deploy/install-trusted.sh with an external SHA256SUMS digest" >&2
exit 1
