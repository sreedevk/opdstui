#!/usr/bin/env bash
set -euo pipefail

REPO="sreedevk/opdstui"
APP_NAME="opdstui"
INSTALL_DIR="${HOME}/.local/bin"
MIN_PYTHON="3.12"

if ! command -v python3 &> /dev/null; then
  echo "Error: python3 is not installed."
  echo "Install Python ${MIN_PYTHON}+ first: https://www.python.org/downloads/"
  exit 1
fi

PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
if python3 -c "import sys; exit(0 if sys.version_info >= (${MIN_PYTHON//\./, }) else 1)"; then
  echo "Found Python ${PYTHON_VERSION} [✓]"
else
  echo "Error: Python ${MIN_PYTHON}+ is required, but found ${PYTHON_VERSION}"
  exit 1
fi

URL=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" \
  | grep "browser_download_url.*\.pyz" \
  | cut -d '"' -f 4)

if [ -z "$URL" ]; then
  echo "Error: Could not find .pyz in latest release"
  exit 1
fi

mkdir -p "$INSTALL_DIR"
echo "Downloading ${APP_NAME} from ${URL}..."
curl -fSL "$URL" -o "${INSTALL_DIR}/${APP_NAME}"
chmod +x "${INSTALL_DIR}/${APP_NAME}"

echo "Installed to ${INSTALL_DIR}/${APP_NAME}"

if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
  echo ""
  echo "⚠ ${INSTALL_DIR} is not in your PATH. Add it with:"
  echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
  echo "Or add that line to your ~/.bashrc or ~/.zshrc"
fi
