#!/bin/bash

# Main project build script
# Executes all build scripts in order

set -e  # Stop script if a command fails

# Determine project root directory robustly
# This script can be called from different locations
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're in the .setup/scripts directory structure
if [[ "$SCRIPT_DIR" == *"/.setup/scripts"* ]]; then
    # Standard case: script is in PROJECT/.setup/scripts/
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"
else
    # Fallback: search for .setup directory from current working directory
    CURRENT_DIR="$(pwd)"
    PROJECT_ROOT="$CURRENT_DIR"
    
    # Search upward for .setup directory
    while [[ "$PROJECT_ROOT" != "/" ]]; do
        if [[ -d "$PROJECT_ROOT/.setup" ]]; then
            break
        fi
        PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
    done
    
    # If not found, use current working directory if it contains .setup
    if [[ ! -d "$PROJECT_ROOT/.setup" ]]; then
        if [[ -d "$CURRENT_DIR/.setup" ]]; then
            PROJECT_ROOT="$CURRENT_DIR"
        else
            echo "Error: Cannot find .setup directory. Please run from project root."
            exit 1
        fi
    fi
fi

# Change to project root
cd "$PROJECT_ROOT"

# Check if running as root (not recommended for build operations)
if [[ $EUID -eq 0 ]]; then
    echo "Warning: Running build script as root is not recommended!"
    echo "For production environments, please use a dedicated user account."
    echo "If you need to create a production user, run:"
    echo "  sudo ./.setup/scripts/00-setup-user.sh"
    echo ""
    read -p "Do you want to continue anyway? (y/N): " CONTINUE
    if [[ "$CONTINUE" != "y" && "$CONTINUE" != "Y" ]]; then
        echo "Build cancelled."
        exit 1
    fi
    echo ""
fi

echo "========================================"
echo "     PROJECT BUILD SCRIPT"
echo "========================================"
echo "Project root: $PROJECT_ROOT"
echo ""

# 1) Build frontend
echo "1) Building frontend application..."
echo "----------------------------------------"
./.setup/scripts/build/01-build-frontend.sh
echo ""

# 2) Setup PM2
echo "2) Setting up PM2 process manager..."
echo "----------------------------------------"
./.setup/scripts/build/02-setup-pm2.sh
echo ""

# 3) Start services
echo "3) Starting all services..."
echo "----------------------------------------"
./.setup/scripts/build/03-start-services.sh
echo ""

echo "========================================"
echo "   BUILD COMPLETED SUCCESSFULLY !"
echo "========================================"
echo ""
echo "The following steps have been completed:"
echo "✓ Frontend application build"
echo "✓ PM2 process manager setup"
echo "✓ Services started with PM2"
echo ""
echo "Your applications are now running in production mode!"
echo "Access your applications:"
echo "- Frontend: Check the URLs displayed above"
echo "- Backend API: Check the URLs displayed above"
echo "- Use 'pm2 status' to monitor your applications"