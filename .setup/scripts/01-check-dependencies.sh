#!/bin/bash

# Script to check required project dependencies
# Checks for uv, docker compose and npm

echo "Checking required dependencies..."

# Check uv
echo "=== Checking uv ==="
if command -v uv &> /dev/null; then
    echo "✅ uv is installed"
    uv --version
else
    echo "❌ uv is not installed"
    echo "Please install uv : https://docs.astral.sh/uv/"
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
        echo "Please install Docker Compose : https://docs.docker.com/compose/install/"
    fi
else
    echo "❌ Docker is not installed"
    echo "Please install Docker : https://docs.docker.com/get-docker/"
fi

echo ""

# Check npm
echo "=== Checking npm ==="
if command -v npm &> /dev/null; then
    echo "✅ npm is installed"
    npm --version
else
    echo "❌ npm is not installed"
    echo "Please install Node.js (which includes npm) : https://nodejs.org/"
fi

echo ""
echo "Dependency check completed."