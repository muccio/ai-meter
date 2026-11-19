#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

APP_NAME="AIMeter"
BUILD_DIR="$PROJECT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "==> Compiling $APP_NAME in Release mode..."
swift build -c release

RELEASE_BIN="$PROJECT_DIR/.build/release/$APP_NAME"
if [[ ! -f "$RELEASE_BIN" ]]; then
    echo "Error: Release binary not found at $RELEASE_BIN"
    exit 1
fi

echo "==> Creating macOS App Bundle structure..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

cp "$RELEASE_BIN" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

if [[ -f "$PROJECT_DIR/Resources/Info.plist" ]]; then
    cp "$PROJECT_DIR/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
fi

if [[ -f "$PROJECT_DIR/Resources/AppIcon.icns" ]]; then
    cp "$PROJECT_DIR/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

echo "==> Applying ad-hoc codesign..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo "==> Packaging zip archive for distribution..."
cd "$BUILD_DIR"
ZIP_NAME="$APP_NAME-macOS-v1.0.0.zip"
rm -f "$ZIP_NAME"
zip -qry "$ZIP_NAME" "$APP_NAME.app"

echo "==> Build and packaging complete!"
echo "    App bundle: $APP_BUNDLE"
echo "    Zip archive: $BUILD_DIR/$ZIP_NAME"
