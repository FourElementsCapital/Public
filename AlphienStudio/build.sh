#!/usr/bin/env bash
set -e

# Script to build AlphienStudio from source
WORK_DIR="$PWD"
BUILD_DIR="$WORK_DIR/"

# Patching AlphienStudio
patch -Np1 -i "$WORK_DIR/patch/no-sso.patch"

# Create build folder
mkdir -pv "$BUILD_DIR"

# Change current working directory to build folder
cd "$BUILD_DIR"

# Install dependencies for building
bash ../dependencies/linux/install-dependencies-debian

# Prepare alphien studio for server release
cmake .. -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release | tee AlphienStudio-config.log

# Build and install
make -j 8 | tee AlphienStudio-make.log
make install |tee AlphienStudio-install.log

echo "Rstudio installed"