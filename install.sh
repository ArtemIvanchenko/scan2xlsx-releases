#!/bin/bash
set -euo pipefail

REPO="${SCAN2XLSX_REPO:-ArtemIvanchenko/scan2xlsx-releases}"
VERSION="${SCAN2XLSX_VERSION:-latest}"
ASSET="Scan2XLSX-macos.zip"
APP_NAME="Scan2XLSX.app"
DEST_DIR="${SCAN2XLSX_DIR:-$HOME/Applications}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Scan2XLSX устанавливается только на macOS." >&2
  exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "Нужен Mac с Apple Silicon (M1/M2/M3/M4)." >&2
  exit 1
fi

if [[ "$VERSION" == "latest" ]]; then
  BASE_URL="https://github.com/$REPO/releases/latest/download"
else
  BASE_URL="https://github.com/$REPO/releases/download/$VERSION"
fi
BASE_URL="${SCAN2XLSX_URL:-$BASE_URL}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Скачиваю Scan2XLSX из $REPO..."
curl -fL --retry 3 --progress-bar -o "$TMP_DIR/$ASSET" "$BASE_URL/$ASSET"

if curl -fsSL -o "$TMP_DIR/$ASSET.sha256" "$BASE_URL/$ASSET.sha256"; then
  (cd "$TMP_DIR" && shasum -a 256 -c "$ASSET.sha256")
else
  echo "Контрольная сумма не найдена, продолжаю без проверки." >&2
fi

ditto -x -k "$TMP_DIR/$ASSET" "$TMP_DIR/unpacked"
SRC_APP="$TMP_DIR/unpacked/$APP_NAME"
if [[ ! -d "$SRC_APP" ]]; then
  echo "В архиве нет $APP_NAME." >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
pkill -f "$DEST_DIR/$APP_NAME/Contents/MacOS/Scan2XLSX" 2>/dev/null || true
rm -rf "$DEST_DIR/$APP_NAME"
ditto "$SRC_APP" "$DEST_DIR/$APP_NAME"
xattr -dr com.apple.quarantine "$DEST_DIR/$APP_NAME" 2>/dev/null || true

if ! codesign --verify --deep --strict "$DEST_DIR/$APP_NAME" >/dev/null 2>&1; then
  codesign --force --deep --sign - "$DEST_DIR/$APP_NAME"
fi

echo "Установлено: $DEST_DIR/$APP_NAME"
if [[ "${SCAN2XLSX_NO_LAUNCH:-0}" != "1" ]]; then
  open "$DEST_DIR/$APP_NAME"
fi
