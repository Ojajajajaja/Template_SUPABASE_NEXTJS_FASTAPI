#!/bin/bash

# Main project build script
# Executes all build scripts in order

set -e  # Stop script if a command fails

# Determine project root directory (go up two levels from .setup/scripts/)
# Handle both direct execution and symbolic links
if [[ -L "${BASH_SOURCE[0]}" ]]; then
    # If called via symbolic link, resolve the actual script location
    SCRIPT_DIR="$(cd "$(dirname "$(readlink "${BASH_SOURCE[0]}")")" && pwd)"
else
    # If called directly
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"

# Change to project root
cd "$PROJECT_ROOT"

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
read -p "Press Enter to continue..."

echo ""

# 2) Setup PM2
echo "2) Setting up PM2 process manager..."
echo "----------------------------------------"
./.setup/scripts/build/02-setup-pm2.sh
echo ""
read -p "Press Enter to continue..."

echo ""

# 3) Start services
echo "3) Starting all services..."
echo "----------------------------------------"
./.setup/scripts/build/03-start-services.sh
echo ""
read -p "Press Enter to continue..."

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