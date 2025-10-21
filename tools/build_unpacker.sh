#!/usr/bin/env bash
set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <cargo_project_root> <output_directory>"
    exit 1
fi

CARGO_ROOT="$1"
OUTPUT_PATH="$2"

echo "Building Rust project..."
echo "  Cargo root: $CARGO_ROOT"
echo "  Output path: $OUTPUT_PATH"

# Ensure directories exist
if [ ! -d "$CARGO_ROOT" ]; then
    echo "Error: Cargo project root '$CARGO_ROOT' does not exist." >&2
    exit 1
fi

mkdir -p "$OUTPUT_PATH"

# Detect target triple for the current OS
TARGET_TRIPLE=$(rustc -vV | grep "host:" | awk '{print $2}')
echo "Detected build target: $TARGET_TRIPLE"

# Build the crate in release mode
cd "$CARGO_ROOT"
cargo build --release --target "$TARGET_TRIPLE"

# Locate the built binary (assumes package name == crate name)
BINARY_NAME=$(basename "$(cargo metadata --no-deps --format-version 1 | jq -r '.packages[0].name')")
BINARY_PATH="$CARGO_ROOT/target/$TARGET_TRIPLE/release/$BINARY_NAME"

if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Build failed or binary not found at $BINARY_PATH" >&2
    exit 1
fi

# Copy built binary to output path
cp "$BINARY_PATH" "$OUTPUT_PATH/"
echo "Build successful. Binary copied to: $OUTPUT_PATH/$BINARY_NAME"
echo "Build process completed!"