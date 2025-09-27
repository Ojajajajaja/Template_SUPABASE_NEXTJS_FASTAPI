#!/bin/bash

# Script to check required project dependencies
# Checks for uv, docker compose and npm
# In production mode, also checks for PM2

# Get deployment mode from environment variable or argument
DEPLOYMENT_MODE="${DEPLOYMENT_MODE:-development}"
if [ $# -eq 1 ]; then
    DEPLOYMENT_MODE="$1"
fi

echo "Checking required dependencies for $DEPLOYMENT_MODE mode..."
if [ "$DEPLOYMENT_MODE" = "production" ]; then
    echo "If any dependency is missing, please run: make install-deps"
    echo "Or directly: ./.setup/scripts/install-dependencies.sh"
fi
echo ""

# Initialize error count
ERROR_COUNT=0

# Check if .env.config exists in .setup directory
echo "=== Checking .env.config file ==="
if [ -f "./.setup/.env.config" ]; then
    echo "✅ .env.config file exists in .setup directory"
else
    echo "❌ .env.config file is missing in .setup directory"
    echo "Please create .env.config file in .setup directory"
    echo "You can copy from .env.config.example: cp ./.setup/.env.config.example ./.setup/.env.config"
    ((ERROR_COUNT++))
fi

echo ""

# Check uv
echo "=== Checking uv ==="
if command -v uv &> /dev/null; then
    echo "✅ uv is installed"
    uv --version
else
    echo "❌ uv is not installed"
    if [ "$DEPLOYMENT_MODE" = "production" ]; then
        echo "Please run: make install-deps"
    fi
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
        if [ "$DEPLOYMENT_MODE" = "production" ]; then
            echo "Please run: make install-deps"
        fi
        ((ERROR_COUNT++))
    fi
else
    echo "❌ Docker is not installed"
    if [ "$DEPLOYMENT_MODE" = "production" ]; then
        echo "Please run: make install-deps"
    fi
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
    if [ "$DEPLOYMENT_MODE" = "production" ]; then
        echo "Please run: make install-deps"
    fi
    ((ERROR_COUNT++))
fi

echo ""

# Check PM2 for production mode only
if [ "$DEPLOYMENT_MODE" = "production" ]; then
    echo "=== Checking PM2 (Production mode) ==="
    if command -v pm2 &> /dev/null; then
        echo "✅ PM2 is installed"
        pm2 --version
    else
        echo "❌ PM2 is not installed"
        echo "PM2 is required for production deployment"
        echo "Please run: make install-deps"
        ((ERROR_COUNT++))
    fi
    echo ""
    
    echo "=== Checking Nginx (Production mode) ==="
    if command -v nginx &> /dev/null; then
        echo "✅ Nginx is installed"
        nginx -v
    else
        echo "❌ Nginx is not installed"
        echo "Nginx is required for production deployment"
        echo "Please run: make install-deps"
        ((ERROR_COUNT++))
    fi
    echo ""
    
    echo "=== Checking Certbot (Production mode) ==="
    if command -v certbot &> /dev/null; then
        echo "✅ Certbot is installed"
        certbot --version
    else
        echo "❌ Certbot is not installed"
        echo "Certbot is required for SSL certificates in production"
        echo "Please run: make install-deps"
        ((ERROR_COUNT++))
    fi
    echo ""
    
    echo "=== Checking Python 3 (Production mode) ==="
    if command -v python3 &> /dev/null; then
        echo "✅ Python 3 is installed"
        python3 --version
    else
        echo "❌ Python 3 is not installed"
        echo "Python 3 is required for production deployment"
        echo "Please run: make install-deps"
        ((ERROR_COUNT++))
    fi
    echo ""
fi

echo "Dependency check completed."

# Exit with error if any dependency is missing
if [ $ERROR_COUNT -gt 0 ]; then
    echo ""
    echo "❌ $ERROR_COUNT dependencies are missing!"
    if [ "$DEPLOYMENT_MODE" = "production" ]; then
        echo "Please run: make install-deps"
        echo "Or directly: ./.setup/scripts/install-dependencies.sh"
    fi
    exit 1
else
    echo "✅ All required dependencies are installed!"
fi