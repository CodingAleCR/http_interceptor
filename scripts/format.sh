#!/bin/bash

# Format script for HTTP Interceptor library
# Only formats lib/ and test/ directories to avoid SDK file issues

set -e

echo "🎯 Formatting Dart code in lib/ and test/ directories..."

# Check if dart is available
if ! command -v dart &> /dev/null; then
    echo "❌ Error: dart command not found"
    echo "Please ensure Dart SDK is installed and available in PATH"
    exit 1
fi

# Format lib directory
if [ -d "lib" ]; then
    echo "📁 Formatting lib/ directory..."
    dart format lib/ --set-exit-if-changed
    lib_status=$?
else
    echo "⚠️  Warning: lib/ directory not found"
    lib_status=0
fi

# Format test directory
if [ -d "test" ]; then
    echo "📁 Formatting test/ directory..."
    dart format test/ --set-exit-if-changed
    test_status=$?
else
    echo "⚠️  Warning: test/ directory not found"
    test_status=0
fi

# Check results
if [ $lib_status -eq 0 ] && [ $test_status -eq 0 ]; then
    echo "✅ All Dart files are properly formatted!"
    exit 0
else
    echo "❌ Some files were not properly formatted"
    echo "Files have been reformatted. Please review and commit the changes."
    exit 1
fi