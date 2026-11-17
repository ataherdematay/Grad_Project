#!/bin/bash
# Local test run (needs PostgreSQL 14+ binaries). Usage: bash run_all.sh   (run as a user allowed to run initdb, e.g. postgres)
set -e
DIR="$(cd "$(dirname "$0")/.." && pwd)"; S=${PGTEST_DIR:-/var/tmp/pgtest}; B=${PGBIN:-/usr/lib/postgresql/16/bin}
rm -rf $S; mkdir -p $S
$B/initdb -D $S/data -A trust -E UTF8 >/dev/null; $B/pg_ctl -D $S/data -o "-p 5544 -k $S" -l $S/log start >/dev/null; sleep 2
Q="$B/psql -h $S -p 5544 -v ON_ERROR_STOP=1 -q"
$Q -d postgres -c 'create database bitadilat'
$Q -d bitadilat -f $DIR/test/00_stub_supabase.sql -f $DIR/01_schema.sql
$Q -d bitadilat -c 'GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role'
$Q -d bitadilat -f $DIR/02_functions.sql -f $DIR/03_security.sql -f $DIR/04_storage.sql -f $DIR/05_seed_categories.sql
$B/psql -h $S -p 5544 -d bitadilat -q -f $DIR/test/01_tests.sql 2>&1 | grep -E "PASS|FAIL|passed|failed|^ +[0-9]+ +\|" || true
$B/pg_ctl -D $S/data stop -m fast >/dev/null; rm -rf $S
