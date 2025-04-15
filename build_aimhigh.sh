function install_android_sdk() {
    echo -e "${GREEN}[2/4] Setting Up Android SDK${NC}"
    SDK_ROOT="$HOME/android-sdk"
    CMDLINE_TOOLS_DIR="$SDK_ROOT/cmdline-tools"
    
    # Clean previous installation
    rm -rf "$SDK_ROOT"
    mkdir -p "$SDK_ROOT"
    
    # Download and extract command line tools
    wget -q --show-progress https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip
    unzip -q cmdline-tools.zip -d "$SDK_ROOT"
    rm cmdline-tools.zip
    
    # Fix directory structure (critical fix)
    if [ -d "$SDK_ROOT/cmdline-tools" ]; then
        mkdir -p "$CMDLINE_TOOLS_DIR/latest"
        mv "$SDK_ROOT/cmdline-tools"/* "$CMDLINE_TOOLS_DIR/latest/"
        rm -rf "$SDK_ROOT/cmdline-tools"
    fi
    
    # Verify tool structure
    if [ ! -f "$CMDLINE_TOOLS_DIR/latest/bin/sdkmanager" ]; then
        echo -e "${RED}Error: SDK Manager not found!${NC}"
        ls -la "$CMDLINE_TOOLS_DIR"
        exit 1
    fi

    # Setup environment
    export ANDROID_SDK_ROOT="$SDK_ROOT"
    export PATH="$CMDLINE_TOOLS_DIR/latest/bin:$PATH"
    
    # Accept licenses
    mkdir -p "$SDK_ROOT/licenses"
    echo -e "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > "$SDK_ROOT/licenses/android-sdk-license"

    # Install components with verification
    components=(
        "platform-tools"
        "build-tools;34.0.0" 
        "platforms;android-33"
        "ndk;25.2.9519653"
    )
    
    for component in "${components[@]}"; do
        echo "Installing $component..."
        if ! "$CMDLINE_TOOLS_DIR/latest/bin/sdkmanager" --install "$component"; then
            echo -e "${RED}Failed to install $component${NC}"
            exit 1
        fi
    done

    # Final verification
    verify_android_tools
}

function verify_android_tools() {
    echo -e "${GREEN}Verifying Android tools...${NC}"
    required_tools=(
        "$ANDROID_SDK_ROOT/build-tools/34.0.0/aidl"
        "$ANDROID_SDK_ROOT/platform-tools/adb"
        "$ANDROID_SDK_ROOT/ndk/25.2.9519653/ndk-build"
    )
    
    for tool in "${required_tools[@]}"; do
        if [ ! -f "$tool" ]; then
            echo -e "${RED}Missing tool: $tool${NC}"
            exit 1
        fi
    done
}
