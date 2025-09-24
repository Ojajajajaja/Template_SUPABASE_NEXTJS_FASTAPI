#!/bin/bash

# Script to check required project dependencies
# Checks for uv, docker compose and npm

echo "Checking required dependencies..."
echo "If any dependency is missing, please run: make install-deps"
echo "Or directly: ./.setup/scripts/install-dependencies.sh"
echo ""

# Initialize error count
ERROR_COUNT=0

# Check uv
echo "=== Checking uv ==="
if command -v uv &> /dev/null; then
    echo "✅ uv is installed"
    uv --version
else
    echo "❌ uv is not installed"
    echo "Please run: make install-deps"
    ((ERROR_COUNT++))
fi

echo ""

# Check docker compose
echo "=== Checking docker compose ==="
if command -v docker &> /dev/null; then
    echo "✅ Docker is installed"
    docker --version
    
    if docker compose version &> /dev/null; then
        echo "✅ Docker Compose is available"
        docker compose version
    else
        echo "❌ Docker Compose is not available"
        echo "Please run: make install-deps"
        ((ERROR_COUNT++))
    fi
else
    echo "❌ Docker is not installed"
    echo "Please run: make install-deps"
    ((ERROR_COUNT++))
fi

echo ""

# Check npm
echo "=== Checking npm ==="
if command -v npm &> /dev/null; then
    echo "✅ npm is installed"
    npm --version
else
    echo "❌ npm is not installed"
    echo "Please run: make install-deps"
    ((ERROR_COUNT++))
fi

echo ""
echo "Dependency check completed."

# Exit with error if any dependency is missing
if [ $ERROR_COUNT -gt 0 ]; then
    echo ""
    echo "❌ $ERROR_COUNT dependencies are missing!"
    echo "Please run: make install-deps"
    echo "Or directly: ./.setup/scripts/install-dependencies.sh"
    exit 1
else
    echo "✅ All required dependencies are installed!"
fi