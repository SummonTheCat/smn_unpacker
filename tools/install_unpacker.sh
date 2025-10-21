#!/usr/bin/env bash
set -e

echo "Starting installation of prerequisites..."

# Detect package manager and install essentials
if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y curl build-essential pkg-config libssl-dev
elif command -v yum >/dev/null 2>&1; then
    yum install -y curl gcc gcc-c++ make openssl-devel
elif command -v dnf >/dev/null 2>&1; then
    dnf install -y curl gcc gcc-c++ make openssl-devel
else
    echo "Error: Unsupported system or no known package manager found (apt, yum, dnf)." >&2
    exit 1
fi

echo "Starting installation of Rust..."

# Check if rustup is already installed
if command -v rustup >/dev/null 2>&1; then
    echo "Rustup is already installed. Updating Rust toolchain..."
    rustup update
else
    echo "Installing Rustup (Rust toolchain manager)..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
fi

# Verify installation
echo "Verifying Rust installation..."
if command -v rustc >/dev/null 2>&1; then
    rustc --version
    echo "Rust installation successful."
else
    echo "Error: Rust installation failed." >&2
    exit 1
fi

echo "-----------------------------------------"
echo "Building unpacker crate from parent directory..."
echo "-----------------------------------------"

# Resolve script and project directories
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CARGO_ROOT="$(dirname "$SCRIPT_DIR")"
BIN_DIR="$CARGO_ROOT/bin"

echo "Script directory: $SCRIPT_DIR"
echo "Cargo project root: $CARGO_ROOT"
echo "Output directory: $BIN_DIR"

# Ensure bin directory exists
mkdir -p "$BIN_DIR"

# Detect target triple for current system
TARGET_TRIPLE=$(rustc -vV | grep "host:" | awk '{print $2}')

cd "$CARGO_ROOT"
echo "Running cargo build --release --target $TARGET_TRIPLE ..."
cargo build --release --target "$TARGET_TRIPLE"

# Locate the crate name and binary
if command -v jq >/dev/null 2>&1; then
    BINARY_NAME=$(basename "$(cargo metadata --no-deps --format-version 1 | jq -r '.packages[0].name')")
else
    BINARY_NAME=$(grep '^name\s*=' Cargo.toml | head -n 1 | cut -d '"' -f2)
fi

BINARY_PATH="$CARGO_ROOT/target/$TARGET_TRIPLE/release/$BINARY_NAME"

if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Build failed or binary not found at $BINARY_PATH" >&2
    exit 1
fi

cp "$BINARY_PATH" "$BIN_DIR/"
echo "Build complete. Binary copied to: $BIN_DIR/$BINARY_NAME"
