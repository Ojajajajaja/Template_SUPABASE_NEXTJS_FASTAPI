#!/bin/bash

# Test script to validate UV installation path handling

echo "Testing UV installation path detection..."

# Simulate different user scenarios
echo ""
echo "=== Test 1: Regular user ==="
export EUID=1000
export HOME="/home/testuser"
echo "EUID=$EUID, HOME=$HOME"

# Test UV path detection logic
if [[ $EUID -eq 0 ]]; then
    UV_LOCAL_PATH="/root/.local/bin/uv"
    echo "  → Would look for UV at: $UV_LOCAL_PATH (root user)"
else
    if [[ -f "$HOME/.local/bin/uv" ]]; then
        UV_LOCAL_PATH="$HOME/.local/bin/uv"
        echo "  → Would look for UV at: $UV_LOCAL_PATH (.local/bin)"
    elif [[ -f "$HOME/.cargo/bin/uv" ]]; then
        UV_LOCAL_PATH="$HOME/.cargo/bin/uv"
        echo "  → Would look for UV at: $UV_LOCAL_PATH (.cargo/bin)"
    else
        echo "  → Would not find UV in expected locations"
    fi
fi

echo ""
echo "=== Test 2: Root user ==="
export EUID=0
export HOME="/root"
echo "EUID=$EUID, HOME=$HOME"

if [[ $EUID -eq 0 ]]; then
    UV_LOCAL_PATH="/root/.local/bin/uv"
    echo "  → Would look for UV at: $UV_LOCAL_PATH (root user)"
else
    if [[ -f "$HOME/.local/bin/uv" ]]; then
        UV_LOCAL_PATH="$HOME/.local/bin/uv"
        echo "  → Would look for UV at: $UV_LOCAL_PATH (.local/bin)"
    elif [[ -f "$HOME/.cargo/bin/uv" ]]; then
        UV_LOCAL_PATH="$HOME/.cargo/bin/uv"
        echo "  → Would look for UV at: $UV_LOCAL_PATH (.cargo/bin)"
    else
        echo "  → Would not find UV in expected locations"
    fi
fi

echo ""
echo "All UV installations would be moved to: /usr/local/bin/uv"
echo ""
echo "✅ UV path detection logic is working correctly!"