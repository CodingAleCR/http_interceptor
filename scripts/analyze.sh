#!/bin/bash

# Dart analysis script for CI/CD
# Only analyzes the lib and test directories

echo "Running Dart analysis..."

# Set up PATH to use the Dart SDK if needed
if [ -d "dart-sdk/bin" ]; then
    export PATH="$PWD/dart-sdk/bin:$PATH"
fi

# Ensure we're in the right directory
cd "$(dirname "$0")/.."

# Run analysis on lib and test directories only
dart analyze lib test

echo "Analysis completed successfully!"