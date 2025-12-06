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
- Argument parsing via `case` statements
- Two modes: `copy` (default) and `move` (via `-d` flag), plus `restore`
- File processing loop that handles both files and directories recursively

## Key Implementation Details

- Uses `set -euo pipefail` for strict error handling
- Timestamps use format `YYYY-MM-DD_HHMMSS`
- Restore mode strips both extension and optional timestamp pattern via regex
- Extensions auto-prefix with `.` if user omits it
- Dry-run shows `[create]`/`[keep]`/`[delete]` labels with `+`/`-` for directory contents

## Homebrew Distribution

- Tap repo: `/Users/danielchen/projects/homebrew-tap`
- Formula: `Formula/bkup.rb`
- Users install via: `brew tap dyc5828/tap && brew install bkup`

## Release Process

1. Update `VERSION` in `bkup`
2. Commit and push: `git add bkup && git commit -m "Bump version" && git push`
3. Tag: `git tag vX.Y.Z && git push --tags`
4. Get SHA256: `curl -sL https://github.com/dyc5828/bkup-cli/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256`
5. Update `homebrew-tap/Formula/bkup.rb` with new version and SHA256
6. Commit and push homebrew-tap
