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
