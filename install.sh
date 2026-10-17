#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# ==============================================================================
# Configuration - UPDATE THESE VARIABLES
# ==============================================================================
GITHUB_OWNER="movva-tech"
GITHUB_REPO="movva-cli"
BINARY_NAME="movva"
INSTALL_DIR="/usr/local/bin"
# ==============================================================================

echo "Installing $BINARY_NAME..."

# 1. Check for required dependencies
for cmd in curl tar grep; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "Error: Required command '$cmd' is not installed."
    exit 1
  fi
done

# 2. Detect Operating System
OS=$(uname -s)
if [ "$OS" != "Linux" ] && [ "$OS" != "Darwin" ]; then
  echo "Error: Unsupported operating system: $OS"
  exit 1
fi

# 3. Detect Architecture
RAW_ARCH=$(uname -m)
case "$RAW_ARCH" in
  x86_64)
    ARCH="x86_64"
    ;;
  aarch64 | arm64)
    ARCH="arm64"
    ;;
  i386 | i686)
    ARCH="i386"
    ;;
  *)
    echo "Error: Unsupported architecture: $RAW_ARCH"
    exit 1
    ;;
esac

echo "Detected system: ${OS} (${ARCH})"

# 4. Fetch the latest release tag via HTTP redirect (Bypasses API rate limits)
echo "Fetching latest release version..."
LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} "https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/latest")
VERSION=$(basename "$LATEST_URL")

if [ -z "$VERSION" ] || [ "$VERSION" = "latest" ]; then
  echo "Error: Could not determine latest version from GitHub."
  exit 1
fi

echo "Latest version found: $VERSION"

# 5. Construct the download URL based on GoReleaser's name_template
# Expected format: mycli_Linux_x86_64.tar.gz or mycli_Darwin_arm64.tar.gz
FILENAME="${BINARY_NAME}_${OS}_${ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/download/${VERSION}/${FILENAME}"

# 6. Download and Extract
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "Downloading $FILENAME..."
if ! curl -sL -f -o "$FILENAME" "$DOWNLOAD_URL"; then
  echo "Error: Failed to download artifact from $DOWNLOAD_URL"
  exit 1
fi

echo "Extracting..."
tar -xzf "$FILENAME"

# 7. Install the binary
echo "Installing to $INSTALL_DIR (may require sudo password)..."

# Use sudo only if the user doesn't have write permissions to the install directory
if [ -w "$INSTALL_DIR" ]; then
  mv "$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
else
  sudo mv "$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
fi

# 8. Cleanup
cd - > /dev/null
rm -rf "$TMP_DIR"

echo "========================================"
echo "$BINARY_NAME $VERSION was successfully installed!"
echo "Run '$BINARY_NAME --help' to get started."
echo "========================================"
