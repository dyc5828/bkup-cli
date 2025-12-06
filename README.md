# bkup

A simple CLI tool for backing up files and directories.

```bash
bkup config.yaml           # creates config.yaml.bkup
bkup -r config.yaml.bkup   # restores to config.yaml
```

## Install

```bash
brew tap dyc5828/tap
brew install bkup
```

Or via script:

```bash
curl -fsSL https://raw.githubusercontent.com/dyc5828/bkup-cli/main/install.sh | bash
```

## Usage

```bash
# Copy (default)
bkup file.txt                    # file.txt.bkup

# Move instead of copy
bkup -m file.txt                 # moves to file.txt.bkup

# Restore
bkup -r file.txt.bkup            # restores to file.txt

# With timestamp
bkup -t file.txt                 # file.txt.2024-12-06_143022.bkup

# Custom extension
bkup -e .backup file.txt         # file.txt.backup

# Delete original after backup
bkup -d file.txt                 # creates backup, deletes original

# Dry run (preview)
bkup -n *.txt                    # shows what would happen

# Force overwrite
bkup -f file.txt                 # overwrites existing .bkup

# Directories work too
bkup my_folder/                  # recursively copies to my_folder.bkup
```

## Options

| Flag | Description |
|------|-------------|
| `-m, --move` | Move instead of copy |
| `-r, --restore` | Restore backup to original name |
| `-t, --timestamp` | Add timestamp to filename |
| `-d, --delete` | Delete original after backup |
| `-e, --extension <ext>` | Custom extension (default: `.bkup`) |
| `-n, --dry-run` | Preview without making changes |
| `-f, --force` | Overwrite without prompting |
| `-h, --help` | Show help |
| `-v, --version` | Show version |

## License

MIT
