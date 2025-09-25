#!/bin/bash
#!/bin/bash

# Main project configuration script
# Executes all configuration scripts in order

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

echo "========================================"
echo "  PROJECT CONFIGURATION SCRIPT"
echo "========================================"
echo "Project root: $PROJECT_ROOT"
echo ""

# Check if deployment mode is provided as argument
if [ $# -eq 1 ]; then
    case $1 in
        dev|development)
            export DEPLOYMENT_MODE="development"
            echo "Development mode selected (from argument)"
            ;;
        prod|production)
            export DEPLOYMENT_MODE="production"
            echo "Production mode selected (from argument)"
            ;;
        *)
            echo "Invalid argument: $1"
            echo "Usage: $0 [dev|development|prod|production]"
            echo "Falling back to interactive mode..."
            echo ""
            # Fall through to interactive mode
            ;;
    esac
fi

# Interactive mode if no valid argument provided
if [ -z "$DEPLOYMENT_MODE" ]; then
    echo "Choose deployment mode:"
    echo "1) Development (localhost)"
    echo "2) Production (configured domains)"
    echo ""
    read -p "Enter your choice (1 or 2): " CHOICE

    case $CHOICE in
        1)
            export DEPLOYMENT_MODE="development"
            echo "Development mode selected"
            ;;
        2)
            export DEPLOYMENT_MODE="production"
            echo "Production mode selected"
            ;;
        *)
            echo "Invalid choice. Development mode selected by default."
            export DEPLOYMENT_MODE="development"
            ;;
    esac
fi
echo ""

# 1) Check dependencies
echo "1) Checking dependencies..."
echo "----------------------------------------"
./.setup/scripts/setup/01-check-dependencies.sh "$DEPLOYMENT_MODE"
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
uv run ./.setup/scripts/setup/03-generate_env.py "$DEPLOYMENT_MODE"
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