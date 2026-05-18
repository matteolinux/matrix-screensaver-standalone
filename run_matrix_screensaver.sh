#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOST_SOURCE="$SCRIPT_DIR/MatrixStandaloneHost.swift"
HOST_BINARY="$SCRIPT_DIR/.matrix-screensaver-host"
SAVER_BUNDLE="$SCRIPT_DIR/Matrix.saver"
MACOS_DEPLOYMENT_TARGET="12.0"

if [[ ! -d "$SAVER_BUNDLE" ]]; then
  echo "Matrix.saver non trovato in: $SCRIPT_DIR" >&2
  exit 1
fi

if [[ ! -x "$HOST_BINARY" || "$HOST_SOURCE" -nt "$HOST_BINARY" || "$0" -nt "$HOST_BINARY" ]]; then
  BUILD_DIR="$(mktemp -d)"
  trap 'rm -rf "$BUILD_DIR"' EXIT

  xcrun swiftc -target "arm64-apple-macosx$MACOS_DEPLOYMENT_TARGET" "$HOST_SOURCE" \
    -o "$BUILD_DIR/matrix-screensaver-host-arm64" \
    -framework Cocoa \
    -framework ScreenSaver \
    -framework LocalAuthentication

  xcrun swiftc -target "x86_64-apple-macosx$MACOS_DEPLOYMENT_TARGET" "$HOST_SOURCE" \
    -o "$BUILD_DIR/matrix-screensaver-host-x86_64" \
    -framework Cocoa \
    -framework ScreenSaver \
    -framework LocalAuthentication

  xcrun lipo -create \
    "$BUILD_DIR/matrix-screensaver-host-arm64" \
    "$BUILD_DIR/matrix-screensaver-host-x86_64" \
    -output "$HOST_BINARY"
  chmod +x "$HOST_BINARY"
fi

"$HOST_BINARY" "$@" "$SAVER_BUNDLE"
