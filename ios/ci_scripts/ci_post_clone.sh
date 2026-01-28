#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
# Traverse up to the root of the repository.
cd $CI_PRIMARY_REPOSITORY_PATH/

echo "Installing Flutter..."

# Clone Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install artifacts
flutter precache --ios

# Install dependencies
echo "Installing Flutter dependencies..."
flutter pub get

# Install CocoaPods
echo "Installing CocoaPods..."
cd ios
pod install
