#!/bin/bash
# Exit on error
set -e

echo "Building the app APK..."
pushd android
./gradlew app:assembleDebug -Ptarget=../integration_test/app_test.dart
echo "Building the test APK..."
./gradlew app:assembleDebugAndroidTest
popd

echo "Running tests on Firebase Test Lab..."

# Assumes gcloud is authenticated and project is set to neonvoyager-dev
gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --device model=Pixel3,version=30,locale=en,orientation=portrait \
  --timeout 5m \
  --project neonvoyager-dev

echo "Firebase Test Lab execution completed successfully."
