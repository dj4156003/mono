#!/bin/bash

targets=("arm64")

CURRENT_DIRECTORY="$(cd "$(dirname "$0")" && pwd)"

MONO_TAG="rg-mono-unity-0.0.3"
PYTHON_VERSION="3.11"
EMSDK_VERSION="1.39.9"
ANDROID_CMAKE_VERSION="3.10.2.4988404"
ANDROID_PLATFORM="android-30"
ANDROID_NDK_VERSION="23.2.8568313"
IOS_VERSION_MIN="10.0"
CONFIGURATION="release"

export DISABLE_NO_WEAK_IMPORTS=1
export MONO_SOURCE_ROOT="${CURRENT_DIRECTORY}/../../"

MONO_INSTALL_PATH="${CURRENT_DIRECTORY}/../install/"
MONO_CONFIG_PATH="${CURRENT_DIRECTORY}/../config/"

#mkdir -p "$MONO_INSTALL_PATH"
find "$MONO_INSTALL_PATH" -mindepth 1 -delete

for target in "${targets[@]}"
do
    echo "Building for target $target"
    python3 "$CURRENT_DIRECTORY"/patch_mono.py
    python3 "$CURRENT_DIRECTORY"/ios.py configure --target=$target -j 2 --ios-version-min=$IOS_VERSION_MIN  --configuration="$CONFIGURATION" --configure-dir="$MONO_CONFIG_PATH" --install-dir="$MONO_INSTALL_PATH"
    python3 "$CURRENT_DIRECTORY"/ios.py make --target=$target -j 2  --configuration="$CONFIGURATION" --configure-dir="$MONO_CONFIG_PATH" --install-dir="$MONO_INSTALL_PATH"
done
