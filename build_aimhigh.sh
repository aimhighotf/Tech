#!/bin/bash
# ==============================================
# AIMHIGH APK BUILDER (GitHub Optimized)
# ==============================================

# Config
APK_NAME="AimHigh"
WORK_DIR="$GITHUB_WORKSPACE/build"
ARTIFACTS_DIR="$GITHUB_WORKSPACE/artifacts"

# Setup
mkdir -p "$WORK_DIR" "$ARTIFACTS_DIR"
cd "$WORK_DIR" || exit

echo "::group::📦 Installing Dependencies"
sudo apt-get update -qq
sudo apt-get install -y -qq \
    git zip unzip python3-pip openjdk-17-jdk \
    zlib1g-dev libncurses5-dev libgdbm-dev \
    libnss3-dev libssl-dev libsqlite3-dev \
    libreadline-dev libffi-dev libbz2-dev
echo "::endgroup::"

echo "::group::🚀 Setting Up Buildozer"
pip3 install --quiet --upgrade pip
pip3 install --quiet buildozer cython==0.29.36 virtualenv
buildozer init
echo "::endgroup::"

echo "::group::🔧 Configuring buildozer.spec"
cat > buildozer.spec <<EOL
[app]
title = $APK_NAME
package.name = aimhigh
package.domain = org.aimhigh
source.dir = $GITHUB_WORKSPACE
version = 0.1
requirements = python3,kivy

android.permissions = INTERNET,CAMERA,NFC
android.api = 33
android.ndk = 23b
p4a.branch = develop
EOL
echo "::endgroup::"

echo "::group::🔨 Building APK (Timeout: 30m)"
timeout 30m buildozer -v android debug 2>&1 | tee "$GITHUB_WORKSPACE/build.log"
echo "::endgroup::"

echo "::group::📦 Collecting Artifacts"
find "$WORK_DIR/bin" -name "*.apk" -exec cp {} "$ARTIFACTS_DIR" \;
echo "APK(s) generated:"
ls -lh "$ARTIFACTS_DIR"/*.apk || echo "No APKs found"
echo "::endgroup::"
