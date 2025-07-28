#!/bin/bash

#targets=("arm64" "x86_64" "arm64-sim")
targets=("arm64" )

CURRENT_DIRECTORY="$(cd "$(dirname "$0")" && pwd)"

MONO_TAG="rg-mono-unity-0.0.3"
PYTHON_VERSION="3.11"
EMSDK_VERSION="1.39.9"
ANDROID_CMAKE_VERSION="3.10.2.4988404"
ANDROID_PLATFORM="android-30"
ANDROID_NDK_VERSION="23.2.8568313"
IOS_VERSION_MIN="10.0"

export DISABLE_NO_WEAK_IMPORTS=1
export MONO_SOURCE_ROOT="$CURRENT_DIRECTORY/../../"

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

MONO_INSTALL_PATH="$CURRENT_DIRECTORY/../install/osx_arm64_release/"
MONO_CONFIG_PATH="$CURRENT_DIRECTORY/../config/osx_arm64_release/"

mkdir -p $MONO_INSTALL_PATH
mkdir -p $MONO_CONFIG_PATH

find $MONO_INSTALL_PATH -mindepth 1 -delete

for target in "${targets[@]}"
do
    echo "Building for target $target"
    python3 $CURRENT_DIRECTORY/patch_mono.py --mono-sources $MONO_SOURCE_ROOT
    python3 $CURRENT_DIRECTORY/osx.py configure --target=$target -j 2 --configuration 'release' --mono-sources $MONO_SOURCE_ROOT --configure-dir $MONO_CONFIG_PATH --install-dir $MONO_INSTALL_PATH
    python3 $CURRENT_DIRECTORY/osx.py make --target=$target -j 2 --configuration 'release' --mono-sources $MONO_SOURCE_ROOT --configure-dir $MONO_CONFIG_PATH --install-dir $MONO_INSTALL_PATH
    
    # mkdir -p $MONO_SOURCE_ROOT/../mono-installs-artifacts
    # (cd "$MONO_SOURCE_ROOT/mono-installs" && zip -ry "$MONO_SOURCE_ROOT/mono-installs-artifacts/ios-$target.zip" "ios-$target-release")
done
