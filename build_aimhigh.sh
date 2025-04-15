#!/bin/bash
# ==============================================
# AIMHIGH APK BUILDER (Production-Grade)
# Apache License 2.0
# ==============================================

set -eo pipefail

# Configuration
export ANDROID_SDK_ROOT="$HOME/android-sdk"
export BUILD_DIR="$HOME/aimhigh_build"
export ARTIFACTS_DIR="$BUILD_DIR/artifacts"
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export NC='\033[0m'

# Initialize directories
mkdir -p "$BUILD_DIR" "$ARTIFACTS_DIR"
cd "$BUILD_DIR"

# ----------------------------
# INSTALLATION PHASE
# ----------------------------
function install_dependencies() {
    echo -e "${GREEN}[1/4] Installing System Dependencies${NC}"
    sudo apt-get update -qq
    sudo apt-get install -y -qq \
        git zip unzip python3 python3-pip python3-dev \
        zlib1g-dev libncurses5-dev libssl-dev libffi-dev \
        liblzma-dev lzma ant ninja-build \
        libxml2-dev libxslt1-dev openjdk-17-jdk

    echo -e "${GREEN}[2/4] Setting Up Android SDK${NC}"
    mkdir -p "$ANDROID_SDK_ROOT"
    wget -q --show-progress https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
    unzip -q commandlinetools-linux-*.zip -d "$ANDROID_SDK_ROOT"
    mv "$ANDROID_SDK_ROOT/cmdline-tools" "$ANDROID_SDK_ROOT/cmdline-tools/latest"

    # Setup environment
    export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
    
    # Accept licenses
    mkdir -p "$ANDROID_SDK_ROOT/licenses"
    echo -e "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > "$ANDROID_SDK_ROOT/licenses/android-sdk-license"

    # Install components
    components=(
        "platform-tools"
        "build-tools;34.0.0"
        "platforms;android-33"
        "ndk;25.2.9519653"
    )
    
    for component in "${components[@]}"; do
        echo "Installing $component..."
        "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --install "$component"
    done
}

# ----------------------------
# BUILD CONFIGURATION PHASE
# ----------------------------
function configure_build() {
    echo -e "${GREEN}[3/4] Configuring Build Environment${NC}"
    python3 -m pip install --upgrade pip wheel
    python3 -m pip install \
        buildozer==1.5.0 \
        cython==0.29.36 \
        virtualenv==20.24.3 \
        setuptools==68.0.0

    # Initialize Buildozer with Apache License
    buildozer init
    cat > buildozer.spec <<EOL
[app]
title = AimHigh
package.name = aimhigh
package.domain = org.aimhigh
source.dir = .
version = 1.0.0
requirements = 
    python3==3.9.13,
    kivy==2.1.0,
    pyjnius==1.4.2,
    cryptography==38.0.1

[buildozer]
log_level = 2
warn_on_root = 1

# Android configuration
android.sdk_path = $ANDROID_SDK_ROOT
android.ndk_path = $ANDROID_SDK_ROOT/ndk/25.2.9519653
android.ndk_version = 25.2.9519653
android.sdk_version = 34
android.api_level = 33
android.accept_sdk_license = True
android.aidl_path = $ANDROID_SDK_ROOT/build-tools/34.0.0/aidl
android.ant_path = /usr/bin/ant

# Permissions
android.permissions = 
    INTERNET,
    CAMERA,
    NFC,
    READ_EXTERNAL_STORAGE

# Build settings
android.arch = armeabi-v7a
p4a.branch = develop

# License
license = Apache-2.0
EOL
}

# ----------------------------
# BUILD PHASE
# ----------------------------
function build_apk() {
    echo -e "${GREEN}[4/4] Building APK${NC}"
    set -x
    buildozer -v android clean
    if ! buildozer -v android debug 2>&1 | tee build.log; then
        echo -e "${RED}Build failed! Analyzing errors...${NC}"
        grep -A 20 -B 20 "ERROR\|CRITICAL" build.log || true
        exit 1
    fi

    # Verify output
    if ! ls bin/*.apk >/dev/null 2>&1; then
        echo -e "${RED}No APK file produced!${NC}"
        ls -la bin/
        exit 1
    fi

    # Prepare artifacts
    cp bin/*.apk "$ARTIFACTS_DIR/"
    cp build.log "$ARTIFACTS_DIR/"
    echo -e "${GREEN}Build successful! APK saved to: $ARTIFACTS_DIR${NC}"
}

# ----------------------------
# MAIN EXECUTION
# ----------------------------
function main() {
    install_dependencies
    configure_build
    build_apk
}

main
