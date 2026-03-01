#!/bin/bash

# Copy generalized .agent/ blueprint files to a sibling project directory
# Usage: ./scripts/copy_agent_blueprints.sh ../path/to/new-project

set -e

# Validate arguments
if [ $# -ne 1 ]; then
  echo "Usage: ./scripts/copy_agent_blueprints.sh ../path/to/new-project"
  echo ""
  echo "Example:"
  echo "  ./scripts/copy_agent_blueprints.sh ../another-flutter-app"
  exit 1
fi

TARGET_DIR="$1"
TARGET_AGENT_DIR="$TARGET_DIR/.agent"

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ Error: Target directory does not exist: $TARGET_DIR"
  exit 1
fi

# Create .agent directory if it doesn't exist
if [ ! -d "$TARGET_AGENT_DIR" ]; then
  mkdir -p "$TARGET_AGENT_DIR"
  echo "✅ Created $TARGET_AGENT_DIR"
fi

# Copy the three blueprint files
echo "📋 Copying blueprint files..."

if [ ! -d "$TARGET_AGENT_DIR/workflows" ]; then
  mkdir -p "$TARGET_AGENT_DIR/workflows"
fi

cp -v .agent/rules.md "$TARGET_AGENT_DIR/rules.md"
cp -v .agent/project_setup.md "$TARGET_AGENT_DIR/project_setup.md"
cp -v .agent/workflows/tdd.md "$TARGET_AGENT_DIR/workflows/tdd.md"

echo ""
echo "✅ Successfully copied 3 blueprint files to $TARGET_AGENT_DIR"
echo ""
echo "📝 Next steps:"
echo "  1. Edit the template variables in the copied files:"
echo "     - {{APP_NAME}} → your app display name"
echo "     - {{PACKAGE_NAME}} → your pubspec.yaml name"
echo "     - {{GCP_PROJECT_ID}} → your GCP project ID"
echo "     - {{GCP_REGION}} → your preferred region (e.g., europe-west1)"
echo "     - {{BUNDLE_ID}} → your iOS/Android bundle ID"
echo "     - {{PRIMARY_COLOR}} → your brand color hex"
echo "     - (See 'Template Variables' section in project_setup.md for full list)"
echo ""
echo "  2. Review the files for any project-specific customizations"
echo "  3. Update your project's .agent/ directory accordingly"
echo ""
