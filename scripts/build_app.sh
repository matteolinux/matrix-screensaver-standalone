#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Matrix Screensaver"
APP_BUNDLE="$ROOT_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
EXECUTABLE="$MACOS_DIR/MatrixScreensaverLauncher"
SAVER_BUNDLE="$ROOT_DIR/Matrix.saver"
ICON_SOURCE="$ROOT_DIR/Assets/MatrixAppIcon.icns"
MACOS_DEPLOYMENT_TARGET="12.0"

if [[ ! -d "$SAVER_BUNDLE" ]]; then
  echo "Missing Matrix.saver at: $SAVER_BUNDLE" >&2
  echo "Download the original Matrix.saver from https://github.com/monroewilliams/MatrixDownload/releases" >&2
  exit 1
fi

if [[ ! -f "$ICON_SOURCE" ]]; then
  echo "Missing icon at: $ICON_SOURCE" >&2
  echo "Run: swift generate_icon.swift Assets/MatrixAppIcon-1024.png && iconutil -c icns Assets/MatrixAppIcon.iconset -o Assets/MatrixAppIcon.icns" >&2
  exit 1
fi

mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

xcrun swiftc -target "arm64-apple-macosx$MACOS_DEPLOYMENT_TARGET" "$ROOT_DIR/MatrixStandaloneHost.swift" \
  -o "$BUILD_DIR/MatrixScreensaverLauncher-arm64" \
  -framework Cocoa \
  -framework ScreenSaver \
  -framework LocalAuthentication

xcrun swiftc -target "x86_64-apple-macosx$MACOS_DEPLOYMENT_TARGET" "$ROOT_DIR/MatrixStandaloneHost.swift" \
  -o "$BUILD_DIR/MatrixScreensaverLauncher-x86_64" \
  -framework Cocoa \
  -framework ScreenSaver \
  -framework LocalAuthentication

xcrun lipo -create \
  "$BUILD_DIR/MatrixScreensaverLauncher-arm64" \
  "$BUILD_DIR/MatrixScreensaverLauncher-x86_64" \
  -output "$EXECUTABLE"
chmod +x "$EXECUTABLE"

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>MatrixScreensaverLauncher</string>
	<key>CFBundleIconFile</key>
	<string>MatrixAppIcon.icns</string>
	<key>CFBundleIconName</key>
	<string>MatrixAppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>local.matrix.screensaver.launcher</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>Matrix Screensaver</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>$MACOS_DEPLOYMENT_TARGET</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSHighResolutionCapable</key>
	<true/>
</dict>
</plist>
PLIST

rm -rf "$RESOURCES_DIR/Matrix.saver"
ditto "$SAVER_BUNDLE" "$RESOURCES_DIR/Matrix.saver"
xattr -dr com.apple.quarantine "$RESOURCES_DIR/Matrix.saver" 2>/dev/null || true

cp "$ICON_SOURCE" "$RESOURCES_DIR/MatrixAppIcon.icns"

codesign --force --sign - "$APP_BUNDLE"
codesign --verify --deep --strict --verbose=4 "$APP_BUNDLE"

echo "Built: $APP_BUNDLE"
