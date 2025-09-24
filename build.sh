#!/bin/bash

# Main project build script
# Executes all build scripts in order

set -e  # Stop script if a command fails

echo "========================================"
echo "     PROJECT BUILD SCRIPT"
echo "========================================"
echo ""

# 1) Setup production user
echo "1) Setting up production user and environment..."
echo "----------------------------------------"
echo "⚠️  This step requires sudo privileges"
echo "   The script will create a production user and move the project"
read -p "Press Enter to continue or Ctrl+C to skip..."
sudo .setup/scripts/build/00-setup-user.sh
echo ""
read -p "Press Enter to continue..."

echo ""

# 2) Build frontend
echo "2) Building frontend application..."
echo "----------------------------------------"
.setup/scripts/build/01-build-frontend.sh
echo ""
read -p "Press Enter to continue..."

echo ""

# 3) Setup PM2
echo "3) Setting up PM2 process manager..."
echo "----------------------------------------"
.setup/scripts/build/02-setup-pm2.sh
echo ""
read -p "Press Enter to continue..."

echo ""

# 4) Start services
echo "4) Starting all services..."
echo "----------------------------------------"
.setup/scripts/build/03-start-services.sh
echo ""
read -p "Press Enter to continue..."

echo ""

echo "========================================"
echo "   BUILD COMPLETED SUCCESSFULLY !"
echo "========================================"
echo ""
echo "The following steps have been completed:"
echo "✓ Production user setup and project relocation"
echo "✓ Frontend application build"
echo "✓ PM2 process manager setup"
echo "✓ Services started with PM2"
echo ""
echo "Your applications are now running in production mode!"
echo "Access your applications:"
echo "- Frontend: Check the URLs displayed above"
echo "- Backend API: Check the URLs displayed above"
echo "- Use 'pm2 status' to monitor your applications"