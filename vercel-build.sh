#!/bin/bash
# Exit immediately if a pipeline, which may consist of a single simple command, a list, or a compound command returns a non-zero status
set -e

echo "Downloading Flutter SDK..."
if [ ! -d "flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PATH:`pwd`/flutter/bin"

echo "Generating .env file from Vercel Environment Variables..."
touch .env
echo "SUPABASE_URL=$SUPABASE_URL" >> .env
echo "SUPABASE_KEY=$SUPABASE_KEY" >> .env
echo "TEST_MODE=$TEST_MODE" >> .env

echo "Building Flutter Web Application..."
flutter --version
flutter build web --release
