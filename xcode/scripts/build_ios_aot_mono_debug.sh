#!/bin/bash

targets=("cross-arm64")

CURRENT_DIRECTORY="$(cd "$(dirname "$0")" && pwd)"

MONO_TAG="rg-mono-unity-0.0.3"
PYTHON_VERSION="3.11"
EMSDK_VERSION="1.39.9"
ANDROID_CMAKE_VERSION="3.10.2.4988404"
ANDROID_PLATFORM="android-30"
ANDROID_NDK_VERSION="23.2.8568313"
IOS_VERSION_MIN="10.0"
CONFIGURATION="debug"

export DISABLE_NO_WEAK_IMPORTS=1
export MONO_SOURCE_ROOT="${CURRENT_DIRECTORY}/../../"

if ! command -v autoconf >/dev/null 2>&1; then
    brew install autoconf
fi
if ! command -v automake >/dev/null 2>&1; then
    brew install automake
fi
if ! command -v libtool >/dev/null 2>&1; then
    brew install libtool
fi
if ! command -v pkg-config >/dev/null 2>&1; then
    brew install pkg-config
fi
if ! command -v cmake >/dev/null 2>&1; then
    brew install cmake
fi
if ! command -v python3 >/dev/null 2>&1; then
    brew install python3
fi

MONO_INSTALL_PATH="${CURRENT_DIRECTORY}/../install/ios_aot_mono_debug/"
MONO_CONFIG_PATH="${CURRENT_DIRECTORY}/../config/ios_aot_mono_debug/"

mkdir -p "$MONO_CONFIG_PATH"
mkdir -p "$MONO_INSTALL_PATH"
#find "$MONO_INSTALL_PATH" -mindepth 1 -delete

XCODE_DEVELOPER_DIR=$(xcode-select -p)
if [ -z "$XCODE_DEVELOPER_DIR" ]; then
    echo "Error：Can't find Xcode Command Tool，please run xcode-select -s /Applications/Xcode.app/Contents/Developer"
    exit 1
fi

IOS_PLATFORM_DIR="$XCODE_DEVELOPER_DIR/Platforms/iPhoneOS.platform/Developer/SDKs"
if [ -d "$IOS_PLATFORM_DIR" ]; then
    IOS_SDK_PATH=$(ls -d "$IOS_PLATFORM_DIR"/iPhoneOS*.sdk | sort -V | tail -1)
    echo "iOS SDK directory: $IOS_SDK_PATH"
else
    echo "Can't find iOS SDK directory: $IOS_PLATFORM_DIR"
    exit 1
fi

MACOS_PLATFORM_DIR="$XCODE_DEVELOPER_DIR/Platforms/MacOSX.platform/Developer/SDKs"
if [ -d "$MACOS_PLATFORM_DIR" ]; then
    MACOS_SDK_PATH=$(ls -d "$MACOS_PLATFORM_DIR"/MacOSX*.sdk | sort -V | tail -1)
    echo "macOS SDK directory: $MACOS_SDK_PATH"
else
    echo "Can't find macOS SDK directory: $MACOS_PLATFORM_DIR"
    exit 1
fi

for target in "${targets[@]}"
do
    echo "Building ios aot mono"
    python3 "$CURRENT_DIRECTORY"/patch_mono.py --mono-sources $MONO_SOURCE_ROOT
    python3 "$CURRENT_DIRECTORY"/ios.py configure --target="arm64" -j 2 --ios-version-min=$IOS_VERSION_MIN  --configuration="debug" --configure-dir="$MONO_CONFIG_PATH" --install-dir="$MONO_INSTALL_PATH"
    python3 "$CURRENT_DIRECTORY"/ios.py configure --target=$target -j 2 --ios-version-min=$IOS_VERSION_MIN  --ios-sdk="$IOS_SDK_PATH" --osx-sdk="$MACOS_SDK_PATH" --configuration="$CONFIGURATION" --configure-dir="$MONO_CONFIG_PATH" --install-dir="$MONO_INSTALL_PATH"
    python3 "$CURRENT_DIRECTORY"/ios.py make --target=$target -j 2  --configuration="$CONFIGURATION" --configure-dir="$MONO_CONFIG_PATH" --install-dir="$MONO_INSTALL_PATH"
done
