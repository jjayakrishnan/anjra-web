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
# Create a dummy .env file to satisfy build requirements (secrets should be injected via environment variables if needed)
echo "SUPABASE_URL=https://placeholder.supabase.co" > .env
echo "SUPABASE_ANON_KEY=placeholder" >> .env
flutter pub get

# Install CocoaPods
echo "Installing CocoaPods..."
cd ios
# Retry logic for pod install to bypass transient Xcode Cloud network issues
pod install || pod install --repo-update || (sleep 10 && pod install --repo-update)
