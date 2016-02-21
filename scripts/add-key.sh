#!/bin/sh

#  add-key.sh
#  Crowdshipping
#
#  Created by Peter Prokop on 20/03/15.
#  Copyright (c) 2015 Whitescape. All rights reserved.

# Create a custom keychain
security create-keychain -p travis ios-build.keychain

# Make the custom keychain default, so xcodebuild will use it for signing
security default-keychain -s ios-build.keychain

# Unlock the keychain
security unlock-keychain -p travis ios-build.keychain

# Set keychain timeout to 1 hour for long builds
security set-keychain-settings -t 3600 -l ~/Library/Keychains/ios-build.keychain

# Add certificates to keychain and allow codesign to access them
security import ./scripts/certs/apple.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import "./scripts/certs/$CERTIFICATE_FILE.cer" -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import "./scripts/certs/$KEY_FILE.p12" -k ~/Library/Keychains/ios-build.keychain -P $KEY_PASSWORD -T /usr/bin/codesign


# Put the provisioning profile in place
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp "./scripts/profile/$PROFILE_NAME.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/
cp "./scripts/profile/$DEV_PROFILE_NAME.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/
