#!/bin/bash
#!/bin/bash

# Main project configuration script
# Executes all configuration scripts in order

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
echo "  PROJECT CONFIGURATION SCRIPT"
echo "========================================"
echo "Project root: $PROJECT_ROOT"
echo ""

# 1) Check dependencies
echo "1) Checking dependencies..."
echo "----------------------------------------"
./.setup/scripts/setup/01-check-dependencies.sh
echo ""
read -p "Press Enter to continue..."

echo ""

# 2) Initialize Supabase
echo "2) Initializing Supabase..."
echo "----------------------------------------"
./.setup/scripts/setup/02-init-supabase.sh
echo ""
read -p "Press Enter to continue..."

echo ""

# 3) Generate environment files
echo "3) Generating environment files..."
echo "----------------------------------------"
echo "Running environment generation script..."
uv run ./.setup/scripts/setup/03-generate_env.py
echo ""
read -p "Press Enter to continue..."

echo ""

# 4) Build project
echo "4) Building project..."
echo "----------------------------------------"
./.setup/scripts/setup/04-build.sh
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