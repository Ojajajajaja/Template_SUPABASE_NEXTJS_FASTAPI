#!/bin/bash

# Main project configuration script
# Executes all configuration scripts in order

set -e  # Stop script if a command fails

echo "========================================"
echo "  PROJECT CONFIGURATION SCRIPT"
echo "========================================"
echo ""

# 1) Check dependencies
echo "1) Checking dependencies..."
echo "----------------------------------------"
.setup/scripts/01-check-dependencies.sh
echo ""
read -p "Press Enter to continue..."

echo ""

# 2) Initialize Supabase
echo "2) Initializing Supabase..."
echo "----------------------------------------"
.setup/scripts/02-init-supabase.sh
echo ""
read -p "Press Enter to continue..."

echo ""

# 3) Generate environment files
echo "3) Generating environment files..."
echo "----------------------------------------"
echo "Running environment generation script..."
uv run .setup/scripts/03-generate_env.py
echo ""
read -p "Press Enter to continue..."

echo ""

# 4) Build project
echo "4) Building project..."
echo "----------------------------------------"
.setup/scripts/04-build.sh
echo ""

echo "========================================"
echo "  CONFIGURATION COMPLETED SUCCESSFULLY !"
echo "========================================"
echo ""
echo "The following steps have been completed:"
echo "✓ Dependency check"
echo "✓ Supabase initialization"
echo "✓ Environment file generation"
echo "✓ Project build"
echo ""
echo "You can now start the project with the appropriate commands."