# Development Sessions

## 2025-12-06: Initial Release (v1.0.0 → v1.1.0)

### Created
- `bkup` - Bash CLI tool for backing up files/directories
- `install.sh` - One-line install script
- `Formula/bkup.rb` - Homebrew formula
- MIT License

### Homebrew Distribution
- Tap repo: `github.com/dyc5828/homebrew-tap`
- Install: `brew tap dyc5828/tap && brew install bkup`
- Direct install: `curl -fsSL https://raw.githubusercontent.com/dyc5828/bkup-cli/main/install.sh | bash`

### Features Implemented
| Flag | Description |
|------|-------------|
| (default) | Copy file, keep original |
| `-d, --delete` | Move file (delete original) |
| `-r, --restore` | Restore backup to original name |
| `-t, --timestamp` | Add timestamp to filename |
| `-e, --extension` | Custom extension (default: .bkup) |
| `-n, --dry-run` | Preview with `[create]`/`[keep]`/`[delete]` labels |
| `-f, --force` | Overwrite without prompting |

### Key Decisions
- Default behavior is copy (keeps original safe)
- `-d` does move instead of copy (removed redundant `-m` flag)
- Dry-run shows directory contents with `+`/`-` prefixes
- Timestamps use format `YYYY-MM-DD_HHMMSS`
- Restore strips both extension and timestamp pattern

### Release Process
1. Update `VERSION` in `bkup`
2. Commit and push
3. Tag: `git tag vX.Y.Z && git push --tags`
4. Get SHA256: `curl -sL https://github.com/dyc5828/bkup-cli/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256`
5. Update `homebrew-tap/Formula/bkup.rb` with new version and SHA256
6. Push homebrew-tap

## 2025-12-18: Output & Restore Enhancements

### Simplified Output Format
- Replaced verbose labels with git-style `+`/`-` markers
- Copy mode: `+ file.bkup` (silence means original kept)
- Move mode: `+ file.bkup` and `- file`
- Restore mode: `+ original` and `- original.bkup`
- Dry-run shows `[dry-run]` header once at start
- Applies to both dry-run and actual operations

### Smarter Restore
- `bkup -r file.txt` now auto-finds `file.txt.bkup`
- Falls back to timestamped backups if exact match not found
- Picks most recent when multiple timestamped backups exist
- Works with custom extensions (`-e`)
- Shows warning if no backup found

## 2025-12-19: Test Suite

### Added Test Suite
- Created `test_bkup.sh` with 23 tests covering all functionality
- Run via `bkup --test` or `./test_bkup.sh`
- Tests organized by category tags for easy scanning:

| Category  | Tests |
|-----------|-------|
| cli       | --version, --help, no args, unknown option |
| copy      | basic copy, directory, multiple files |
| move      | deletes original, directory move |
| restore   | basic, by original name, strips timestamp, finds timestamped, directory, custom extension |
| timestamp | adds YYYY-MM-DD_HHMMSS |
| extension | custom extension, auto-adds dot |
| dry-run   | no changes, shows +/- markers |
| force     | overwrites existing |
| error     | nonexistent file warning |

### Cleanup
- Removed `Formula/` directory from this repo
- Formula now maintained only in `homebrew-tap` repo

## 2025-12-19: Zsh Completions (v1.3.0)

### Added
- `completions/_bkup` - Zsh tab completion for all flags and file/directory arguments

### Completions Support
| Flag | Completion Behavior |
|------|---------------------|
| `-d, --delete` | Mutually exclusive with `-r` |
| `-r, --restore` | Mutually exclusive with `-d` |
| `-t, --timestamp` | Toggle |
| `-e, --extension` | Expects extension argument |
| `-n, --dry-run` | Toggle |
| `-f, --force` | Toggle |
| `-h, --help` | Toggle |
| `-v, --version` | Toggle |
| `--test` | Toggle |
| `*` | Files and directories |

### Homebrew Integration
- Updated formula: `zsh_completion.install "completions/_bkup"`
- Completions auto-install to `$(brew --prefix)/share/zsh/site-functions/_bkup`
- Users get completions automatically on `brew install bkup`

### Released v1.3.0
- SHA256: `be4864941aabfe302a96dce6480ec7e399814de3b771c290dab0f1dc89377c7e`
