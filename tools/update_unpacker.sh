#!/usr/bin/env bash
set -e

# Resolve the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Go up one directory to get the root directory
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Root directory: $ROOT_DIR"
cd "$ROOT_DIR"

# Ensure this is a git repository
if [ ! -d ".git" ]; then
    echo "Error: $ROOT_DIR is not a git repository." >&2
    exit 1
fi

echo "Fetching latest changes from origin..."
git fetch origin

echo "Resetting local branch to match origin..."
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git reset --hard "origin/$CURRENT_BRANCH"

echo "Cleaning untracked files and directories..."
git clean -fdx

echo "Repository successfully updated to the latest origin/$CURRENT_BRANCH."
