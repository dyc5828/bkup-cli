#!/usr/bin/env bash

set -euo pipefail

BKUP="$(cd "$(dirname "$0")" && pwd)/bkup"
TEST_DIR=""
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
}

teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

pass() {
    ((TESTS_PASSED++))
    printf "${GREEN}✓${NC} ${CYAN}[%-9s]${NC} %s\n" "$1" "$2"
}

fail() {
    ((TESTS_FAILED++))
    printf "${RED}✗${NC} ${CYAN}[%-9s]${NC} %s\n" "$1" "$2"
    echo "  Error: $3"
}

run_test() {
    local tag="$1"
    local desc="$2"
    local func="$3"
    ((TESTS_RUN++))

    setup
    if $func "$tag" "$desc"; then
        :
    fi
    teardown
}

# ============================================
# CLI Tests
# ============================================

test_cli_version() {
    local tag="$1" desc="$2"
    local output
    output=$("$BKUP" --version)
    if [[ "$output" == bkup\ v* ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Expected 'bkup v*', got: $output"
    fi
}

test_cli_help() {
    local tag="$1" desc="$2"
    local output
    output=$("$BKUP" --help)
    if [[ "$output" == *"Usage:"* ]] && [[ "$output" == *"Options:"* ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Help output missing Usage: or Options:"
    fi
}

test_cli_no_args() {
    local tag="$1" desc="$2"
    local output
    output=$("$BKUP" 2>&1) || true
    if [[ "$output" == *"Usage:"* ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Should show usage when no arguments provided"
    fi
}

test_cli_unknown_option() {
    local tag="$1" desc="$2"
    local output
    output=$("$BKUP" --invalid 2>&1) || true
    if [[ "$output" == *"unknown option"* ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Should error on unknown option"
    fi
}

# ============================================
# Copy Mode Tests
# ============================================

test_copy_basic() {
    local tag="$1" desc="$2"
    echo "test content" > file.txt
    "$BKUP" file.txt > /dev/null

    if [[ -f "file.txt" ]] && [[ -f "file.txt.bkup" ]] && [[ "$(cat file.txt.bkup)" == "test content" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Original or backup file missing/incorrect"
    fi
}

test_copy_directory() {
    local tag="$1" desc="$2"
    mkdir -p mydir
    echo "test" > mydir/file.txt
    "$BKUP" mydir > /dev/null

    if [[ -d "mydir.bkup" ]] && [[ -f "mydir.bkup/file.txt" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Directory not copied recursively"
    fi
}

test_copy_multiple_files() {
    local tag="$1" desc="$2"
    echo "a" > a.txt
    echo "b" > b.txt
    "$BKUP" a.txt b.txt > /dev/null

    if [[ -f "a.txt.bkup" ]] && [[ -f "b.txt.bkup" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Not all files were backed up"
    fi
}

# ============================================
# Move Mode Tests
# ============================================

test_move_deletes_original() {
    local tag="$1" desc="$2"
    echo "test content" > file.txt
    "$BKUP" -d file.txt > /dev/null

    if [[ ! -f "file.txt" ]] && [[ -f "file.txt.bkup" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Original should be deleted, backup should exist"
    fi
}

test_move_directory() {
    local tag="$1" desc="$2"
    mkdir -p mydir
    echo "test" > mydir/file.txt
    "$BKUP" -d mydir > /dev/null

    if [[ ! -d "mydir" ]] && [[ -d "mydir.bkup" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Original dir should be gone, backup should exist"
    fi
}

# ============================================
# Restore Mode Tests
# ============================================

test_restore_basic() {
    local tag="$1" desc="$2"
    echo "test content" > file.txt.bkup
    "$BKUP" -r file.txt.bkup > /dev/null

    if [[ -f "file.txt" ]] && [[ ! -f "file.txt.bkup" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Should create original and remove backup"
    fi
}

test_restore_by_original_name() {
    local tag="$1" desc="$2"
    echo "test content" > file.txt.bkup
    "$BKUP" -r file.txt > /dev/null

    if [[ -f "file.txt" ]] && [[ ! -f "file.txt.bkup" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Should find file.txt.bkup when given file.txt"
    fi
}

test_restore_strips_timestamp() {
    local tag="$1" desc="$2"
    echo "test content" > "file.txt.2024-01-15_120000.bkup"
    "$BKUP" -r "file.txt.2024-01-15_120000.bkup" > /dev/null

    if [[ -f "file.txt" ]] && [[ ! -f "file.txt.2024-01-15_120000.bkup" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Should strip timestamp from restored filename"
    fi
}

test_restore_finds_timestamped() {
    local tag="$1" desc="$2"
    echo "test content" > "file.txt.2024-01-15_120000.bkup"
    "$BKUP" -r file.txt > /dev/null

    if [[ -f "file.txt" ]] && [[ ! -f "file.txt.2024-01-15_120000.bkup" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Should find timestamped backup for file.txt"
    fi
}

test_restore_directory() {
    local tag="$1" desc="$2"
    mkdir -p mydir.bkup
    echo "test" > mydir.bkup/file.txt
    "$BKUP" -r mydir.bkup > /dev/null

    if [[ -d "mydir" ]] && [[ ! -d "mydir.bkup" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Directory not restored correctly"
    fi
}

test_restore_custom_extension() {
    local tag="$1" desc="$2"
    echo "test" > file.txt.backup
    "$BKUP" -r -e .backup file.txt.backup > /dev/null

    if [[ -f "file.txt" ]] && [[ ! -f "file.txt.backup" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Should restore using custom extension"
    fi
}

# ============================================
# Timestamp Tests
# ============================================

test_timestamp_adds_timestamp() {
    local tag="$1" desc="$2"
    echo "test" > file.txt
    "$BKUP" -t file.txt > /dev/null

    local found=0
    for f in file.txt.????-??-??_??????.bkup; do
        [[ -e "$f" ]] && found=1 && break
    done

    if [[ $found -eq 1 ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "No timestamped backup found"
    fi
}

# ============================================
# Extension Tests
# ============================================

test_extension_custom() {
    local tag="$1" desc="$2"
    echo "test" > file.txt
    "$BKUP" -e .backup file.txt > /dev/null

    if [[ -f "file.txt.backup" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "file.txt.backup should exist"
    fi
}

test_extension_auto_adds_dot() {
    local tag="$1" desc="$2"
    echo "test" > file.txt
    "$BKUP" -e backup file.txt > /dev/null

    if [[ -f "file.txt.backup" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Should auto-add dot prefix to extension"
    fi
}

# ============================================
# Dry-Run Tests
# ============================================

test_dryrun_no_filesystem_changes() {
    local tag="$1" desc="$2"
    echo "test" > file.txt
    local output
    output=$("$BKUP" -n file.txt)

    if [[ ! -f "file.txt.bkup" ]] && [[ "$output" == *"[dry-run]"* ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Should not create backup, should show [dry-run]"
    fi
}

test_dryrun_shows_plus_for_creates() {
    local tag="$1" desc="$2"
    echo "test" > file.txt
    local output
    output=$("$BKUP" -n file.txt)

    if [[ "$output" == *"+ file.txt.bkup"* ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Output should include '+ file.txt.bkup'"
    fi
}

test_dryrun_shows_minus_for_deletes() {
    local tag="$1" desc="$2"
    echo "test" > file.txt
    local output
    output=$("$BKUP" -n -d file.txt)

    if [[ "$output" == *"- file.txt"* ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Output should include '- file.txt'"
    fi
}

# ============================================
# Force Tests
# ============================================

test_force_overwrites_existing() {
    local tag="$1" desc="$2"
    echo "original" > file.txt
    echo "old backup" > file.txt.bkup
    "$BKUP" -f file.txt > /dev/null

    if [[ "$(cat file.txt.bkup)" == "original" ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Backup should contain 'original'"
    fi
}

# ============================================
# Error Handling Tests
# ============================================

test_error_nonexistent_file() {
    local tag="$1" desc="$2"
    local output
    output=$("$BKUP" nonexistent.txt 2>&1) || true

    if [[ "$output" == *"does not exist"* ]]; then
        pass "$tag" "$desc"
    else
        fail "$tag" "$desc" "Should warn about missing file"
    fi
}

# ============================================
# Run All Tests
# ============================================

echo "Running bkup tests..."
echo

run_test "cli"       "--version outputs version string"              test_cli_version
run_test "cli"       "--help shows Usage: and Options:"              test_cli_help
run_test "cli"       "no arguments shows usage info"                 test_cli_no_args
run_test "cli"       "invalid option shows error"                    test_cli_unknown_option

run_test "copy"      "creates .bkup and preserves original"          test_copy_basic
run_test "copy"      "directories copied recursively"                test_copy_directory
run_test "copy"      "multiple files in one command"                 test_copy_multiple_files

run_test "move"      "-d creates backup and removes original"        test_move_deletes_original
run_test "move"      "-d moves entire directory"                     test_move_directory

run_test "restore"   "-r restores backup to original name"           test_restore_basic
run_test "restore"   "-r finds backup given original filename"       test_restore_by_original_name
run_test "restore"   "-r strips timestamp from filename"             test_restore_strips_timestamp
run_test "restore"   "-r finds timestamped backup by name"           test_restore_finds_timestamped
run_test "restore"   "directories restored correctly"                test_restore_directory
run_test "restore"   "-r works with custom extension"                test_restore_custom_extension

run_test "timestamp" "-t adds YYYY-MM-DD_HHMMSS to filename"         test_timestamp_adds_timestamp

run_test "extension" "-e .backup uses custom extension"              test_extension_custom
run_test "extension" "-e backup auto-adds dot prefix"                test_extension_auto_adds_dot

run_test "dry-run"   "-n shows preview without changes"              test_dryrun_no_filesystem_changes
run_test "dry-run"   "-n shows + for created files"                  test_dryrun_shows_plus_for_creates
run_test "dry-run"   "-n -d shows - for deleted files"               test_dryrun_shows_minus_for_deletes

run_test "force"     "-f overwrites existing backup"                 test_force_overwrites_existing

run_test "error"     "warns about nonexistent files"                 test_error_nonexistent_file

echo
echo "================================"
echo "Tests: $TESTS_RUN | Passed: $TESTS_PASSED | Failed: $TESTS_FAILED"
echo "================================"

if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1
fi
