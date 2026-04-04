#!/usr/bin/env bash
# Quick install script for diskdoc
# Usage: curl -fsSL https://raw.githubusercontent.com/javierjah/diskdoc/main/install.sh | bash
set -euo pipefail

REPO="javierjah/diskdoc"
INSTALL_DIR="/usr/local/bin"

echo "Installing diskdoc..."

# Download
curl -fsSL "https://raw.githubusercontent.com/${REPO}/main/bin/diskdoc" -o /tmp/diskdoc

# Install
if [[ -w "$INSTALL_DIR" ]]; then
  mv /tmp/diskdoc "$INSTALL_DIR/diskdoc"
else
  sudo mv /tmp/diskdoc "$INSTALL_DIR/diskdoc"
fi

chmod +x "$INSTALL_DIR/diskdoc"

echo "diskdoc installed to $INSTALL_DIR/diskdoc"
echo "Run 'diskdoc --scan' to try it out."
