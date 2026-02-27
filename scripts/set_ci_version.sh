#!/bin/bash
set -e

# This script is meant to be run in Cloud Build to set the build number
# based on the total git commit count.

echo "Fetching git history to determine commit count..."
# Cloud Build performs a shallow clone, fetch depth we need to count all commits
git fetch --unshallow || true

COMMIT_COUNT=$(git rev-list --count HEAD || echo "1")

if [ -z "$COMMIT_COUNT" ]; then
  echo "Error: Could not determine commit count."
  exit 1
fi

echo "Total commit count: $COMMIT_COUNT"

# Update pubspec.yaml
# We look for "version: X.Y.Z+W" and replace the "+W" with "+$COMMIT_COUNT"

if [ ! -f "pubspec.yaml" ]; then
    echo "Error: pubspec.yaml not found."
    exit 1
fi

# Use sed to replace the version dynamically. 
# Works on both GNU and BSD (macOS) sed by using a backup extension then deleting it.
sed -i.bak -E "s/^(version: [0-9]+\.[0-9]+\.[0-9]+)\+[0-9]+/\1+${COMMIT_COUNT}/" pubspec.yaml
rm -f pubspec.yaml.bak

NEW_VERSION=$(grep "^version:" pubspec.yaml)
echo "Updated pubspec.yaml to: $NEW_VERSION"
