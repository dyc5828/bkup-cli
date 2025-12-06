# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

bkup is a single-file bash CLI tool for backing up files and directories by copying/moving them with a `.bkup` extension.

## Running the Tool

```bash
./bkup [OPTIONS] <file|directory>...
./bkup --help
```

## Code Structure

The entire tool is in `bkup` - a self-contained bash script with:
- Argument parsing via `case` statements (lines 59-112)
- Three modes: `copy` (default), `move`, and `restore`
- File processing loop that handles both files and directories recursively

## Key Implementation Details

- Uses `set -euo pipefail` for strict error handling
- Timestamps use format `YYYY-MM-DD_HHMMSS`
- Restore mode strips both extension and optional timestamp pattern via regex
- Extensions auto-prefix with `.` if user omits it
