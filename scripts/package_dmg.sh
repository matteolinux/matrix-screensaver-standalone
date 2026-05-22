#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="$ROOT_DIR/Matrix Screensaver.app"
ICON_SOURCE="$ROOT_DIR/Assets/MatrixAppIcon.icns"
DIST_DIR="$ROOT_DIR/dist"
STAGING_DIR="$ROOT_DIR/.dmg-staging"
TMP_DMG="$DIST_DIR/Matrix-Screensaver-tmp.dmg"
FINAL_DMG="$DIST_DIR/Matrix-Screensaver.dmg"
VOL_NAME="Matrix Screensaver"

if [[ ! -d "$APP_BUNDLE" ]]; then
  echo "Missing app bundle: $APP_BUNDLE" >&2
  echo "Run scripts/build_app.sh first." >&2
  exit 1
fi

if [[ ! -f "$ICON_SOURCE" ]]; then
  echo "Missing icon: $ICON_SOURCE" >&2
  exit 1
fi

codesign --verify --deep --strict --verbose=4 "$APP_BUNDLE"

for mounted_volume in "/Volumes/$VOL_NAME" "/Volumes/$VOL_NAME 1"; do
  if [[ -d "$mounted_volume" ]]; then
    hdiutil detach "$mounted_volume" >/dev/null
  fi
done

rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR" "$DIST_DIR"
ditto "$APP_BUNDLE" "$STAGING_DIR/Matrix Screensaver.app"
ln -s /Applications "$STAGING_DIR/Applications"

rm -f "$TMP_DMG" "$FINAL_DMG"
hdiutil create -srcfolder "$STAGING_DIR" -volname "$VOL_NAME" -fs HFS+ -format UDRW "$TMP_DMG" >/dev/null
ATTACH_OUTPUT="$(hdiutil attach "$TMP_DMG" -readwrite -noverify -noautoopen)"
VOLUME_PATH="$(printf '%s\n' "$ATTACH_OUTPUT" | awk -F '\t' '/\/Volumes\// { print $NF; exit }')"
if [[ -z "$VOLUME_PATH" || ! -d "$VOLUME_PATH" ]]; then
  echo "Cannot determine mounted DMG volume path" >&2
  printf '%s\n' "$ATTACH_OUTPUT" >&2
  exit 1
fi

cp "$ICON_SOURCE" "$VOLUME_PATH/.VolumeIcon.icns"
SetFile -a V "$VOLUME_PATH/.VolumeIcon.icns"
SetFile -a C "$VOLUME_PATH"

osascript <<OSA
tell application "Finder"
  tell disk "$VOL_NAME"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set the bounds of container window to {100, 100, 620, 380}
    set arrangement of icon view options of container window to not arranged
    set icon size of icon view options of container window to 96
    set position of item "Matrix Screensaver.app" of container window to {160, 140}
    set position of item "Applications" of container window to {380, 140}
    close
  end tell
end tell
OSA

sync
hdiutil detach "$VOLUME_PATH" >/dev/null
sleep 1
hdiutil convert "$TMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$FINAL_DMG" >/dev/null
hdiutil verify "$FINAL_DMG" >/dev/null

rm -rf "$STAGING_DIR" "$TMP_DMG"

echo "Created: $FINAL_DMG"
