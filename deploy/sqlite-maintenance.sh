#!/usr/bin/env sh
set -eu

operation=${1:?SQLite maintenance operation is required}
database=${2:?database path is required}

sqlite_query() {
    query_database=$1
    query_text=$2
    if command -v sqlite3 >/dev/null 2>&1; then
        sqlite3 "$query_database" ".timeout 5000" "$query_text"
        return
    fi
    if command -v python3 >/dev/null 2>&1 && python3 -c 'import sqlite3' >/dev/null 2>&1; then
        python3 - "$query_database" "$query_text" <<'PY'
import sqlite3
import sys

database_path, query = sys.argv[1:3]
connection = sqlite3.connect(database_path, timeout=5)
try:
    for row in connection.execute(query):
        print(row[0] if len(row) == 1 else "|".join(str(value) for value in row))
finally:
    connection.close()
PY
        return
    fi
    printf '%s\n' "sqlite3 CLI or Python sqlite3 module is required" >&2
    exit 1
}

sqlite_backup() {
    source_database=$1
    target_database=$2
    if command -v sqlite3 >/dev/null 2>&1; then
        sqlite3 "$source_database" ".timeout 5000" ".backup '$target_database'"
        return
    fi
    if command -v python3 >/dev/null 2>&1 && python3 -c 'import sqlite3' >/dev/null 2>&1; then
        python3 - "$source_database" "$target_database" <<'PY'
import sqlite3
import sys

source_path, target_path = sys.argv[1:3]
source = sqlite3.connect(f"file:{source_path}?mode=ro", uri=True, timeout=5)
target = sqlite3.connect(target_path, timeout=5)
try:
    source.backup(target)
finally:
    target.close()
    source.close()
PY
        return
    fi
    printf '%s\n' "sqlite3 CLI or Python sqlite3 module is required" >&2
    exit 1
}

case "$operation" in
    integrity)
        sqlite_query "$database" "PRAGMA integrity_check;"
        ;;
    version)
        sqlite_query "$database" "PRAGMA user_version;"
        ;;
    backup)
        target=${3:?backup target path is required}
        sqlite_backup "$database" "$target"
        ;;
    *)
        printf '%s\n' "unsupported SQLite maintenance operation" >&2
        exit 1
        ;;
esac
