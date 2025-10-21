#!/usr/bin/env bash
set -e

echo "Starting installation of Rust..."

# Check if rustup is already installed
if command -v rustup >/dev/null 2>&1; then
    echo "Rustup is already installed. Updating Rust toolchain..."
    rustup update
else
    echo "Installing Rustup (Rust toolchain manager)..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
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
