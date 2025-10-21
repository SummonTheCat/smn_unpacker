#!/usr/bin/env bash
set -e

echo "Starting installation of prerequisites..."

# Detect package manager and install curl if missing
if ! command -v curl >/dev/null 2>&1; then
    echo "curl not found. Installing curl..."
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y curl
    elif command -v yum >/dev/null 2>&1; then
        yum install -y curl
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y curl
    else
        echo "Error: Unsupported system or no known package manager found (apt, yum, dnf)." >&2
        exit 1
    fi
else
    echo "curl already installed."
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
