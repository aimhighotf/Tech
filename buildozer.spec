[app]
title = MyApp
package.name = myapp
package.domain = org.example
source.dir = .
version = 1.0
requirements = 
    python3,
    kivy==2.1.0,
    pyjnius,
    cryptography

[buildozer]
log_level = 2
warn_on_root = 1

# Android specific
android.sdk_path = /home/runner/android-sdk
android.ndk_path = /home/runner/android-sdk/ndk/25.2.9519653
android.ndk_version = 25.2.9519653
android.sdk_version = 34
android.api_level = 33
android.accept_sdk_license = True
android.aidl_path = /home/runner/android-sdk/build-tools/34.0.0/aidl
android.ant_path = /usr/bin/ant

# Permissions
android.permissions = 
    INTERNET,
    CAMERA,
    NFC,
    READ_EXTERNAL_STORAGE

# Apache License
license = Apache-2.0
