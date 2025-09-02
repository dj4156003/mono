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

#
#if ! command -v autoconf >/dev/null 2>&1; then
#    brew install autoconf
#fi
#if ! command -v automake >/dev/null 2>&1; then
#    brew install automake
#fi
#if ! command -v libtool >/dev/null 2>&1; then
#    brew install libtool
#fi
#if ! command -v pkg-config >/dev/null 2>&1; then
#    brew install pkg-config
#fi
#if ! command -v cmake >/dev/null 2>&1; then
#    brew install cmake
#fi
#if ! command -v python3 >/dev/null 2>&1; then
#    brew install python3
#fi
#if ! command -v gettext >/dev/null 2>&1; then
#    brew install gettext
#fi
#
#if ! command -v curl >/dev/null 2>&1; then
#    brew install curl
#fi
#if ! command -v libtool-bin >/dev/null 2>&1; then
#    brew install libtool-bin
#fi

MONO_INSTALL_PATH="$CURRENT_DIRECTORY/../install/ios_bcl_arm64/"
MONO_CONFIG_PATH="$CURRENT_DIRECTORY/../config/ios_bcl_arm64/"

python3 patch_mono.py --mono-sources $MONO_SOURCE_ROOT
product="ios"
python3 bcl.py make --product=${product} -j 2 --mono-sources $MONO_SOURCE_ROOT --configure-dir $MONO_CONFIG_PATH --install-dir $MONO_INSTALL_PATH


