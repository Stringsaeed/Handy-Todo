#!/bin/bash
set -euo pipefail
TASK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TASK_BUILD="$(mktemp -d "${TMPDIR:-/tmp}/handy-migration.XXXXXX")"
trap 'rm -rf "$TASK_BUILD"' EXIT
xcrun momc "$TASK_ROOT/Tests/Fixtures/HandyTodo.xcdatamodeld" "$TASK_BUILD/HandyTodo.momd"
xcrun swiftc -parse-as-library \
  "$TASK_ROOT/HandyTodo/Models/TodoItem.swift" \
  "$TASK_ROOT/Tests/StorageMigrationTests.swift" \
  -o "$TASK_BUILD/storage-tests"
"$TASK_BUILD/storage-tests" "$TASK_BUILD/HandyTodo.momd"
