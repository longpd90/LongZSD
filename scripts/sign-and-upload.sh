#!/usr/bin/env bash


# Dev

OUTPUTDIR="$PWD/build-dev/Release-iphoneos"
PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$DEV_PROFILE_NAME.mobileprovision"

xcrun -log -sdk iphoneos PackageApplication "$OUTPUTDIR/$APP_NAME.app" -o "$OUTPUTDIR/$APP_NAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

# ./Crashlytics.framework/submit $FABRIC_API_KEY $FABRIC_BUILD_SECRET -ipaPath "$OUTPUTDIR/$APP_NAME.dev.ipa" -groupAliases ﻿iphone -notifications YES

deliver testflight -a $ITUNES_DEV_APP_ID "$OUTPUTDIR/$APP_NAME.ipa"

# Prod

OUTPUTDIR="$PWD/build-prod/Release-iphoneos"
PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"

xcrun -log -sdk iphoneos PackageApplication "$OUTPUTDIR/$APP_NAME.app" -o "$OUTPUTDIR/$APP_NAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

#./Crashlytics.framework/submit $FABRIC_API_KEY $FABRIC_BUILD_SECRET -ipaPath "$OUTPUTDIR/$APP_NAME.ipa" -groupAliases ﻿iphone -notifications YES

deliver testflight -a $ITUNES_PROD_APP_ID "$OUTPUTDIR/$APP_NAME.ipa"

