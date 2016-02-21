#!/usr/bin/env bash

set -e

BUILDDIR="$PWD/build-prod"

xctool -project Crowdshipping.xcodeproj -scheme adhoc -sdk iphoneos -configuration Release OBJROOT=$BUILDDIR SYMROOT=$BUILDDIR ONLY_ACTIVE_ARCH=NO 'CODE_SIGN_RESOURCE_RULES_PATH=$(SDKROOT)/ResourceRules.plist' build


xctool -scheme adhoc clean

BUILDDIR="$PWD/build-dev"

/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $DEV_BUNDLE_ID" "Crowdshipping/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $DEV_BUNDLE_DISPLAY_NAME" "Crowdshipping/Info.plist"

xctool -project Crowdshipping.xcodeproj -scheme adhoc -sdk iphoneos -configuration Release OBJROOT=$BUILDDIR SYMROOT=$BUILDDIR ONLY_ACTIVE_ARCH=NO 'CODE_SIGN_RESOURCE_RULES_PATH=$(SDKROOT)/ResourceRules.plist' build

