#!/usr/bin/env bash
set -euo pipefail

REPO="dyc5828/bkup-cli"
INSTALL_DIR="/usr/local/bin"

# Use sudo if needed
if [[ -w "$INSTALL_DIR" ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

echo "Installing bkup..."
curl -sSL "https://raw.githubusercontent.com/${REPO}/main/bkup" | $SUDO install -m 755 /dev/stdin "${INSTALL_DIR}/bkup"
echo "Installed bkup to ${INSTALL_DIR}/bkup"
