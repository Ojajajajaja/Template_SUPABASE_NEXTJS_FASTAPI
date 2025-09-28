#!/bin/bash

# =============================================================================
# Project Setup Script - Template SUPABASE NEXTJS FASTAPI
# =============================================================================
# Executes all configuration scripts in order
# =============================================================================

set -e  # Stop script if a command fails

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

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

echo "Project Setup"
echo "Project root: $PROJECT_ROOT"
echo

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
    echo "1) Development"
    echo "2) Production"
    echo
    read -p "Enter choice (1-2): " CHOICE

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
            echo "Invalid choice. Development mode selected."
            export DEPLOYMENT_MODE="development"
            ;;
    esac
fi

# Check if running as root in production mode
if [[ "$DEPLOYMENT_MODE" == "production" && $EUID -eq 0 ]]; then
        log_error "Cannot run setup script as root in production mode!"
        log_info "Switch to your production user and run the script again."
        exit 1
fi

echo ""

log_info "1) Checking dependencies..."
./.setup/scripts/setup/01-check-dependencies.sh "$DEPLOYMENT_MODE"
echo

log_info "2) Initializing Supabase..."
./.setup/scripts/setup/02-init-supabase.sh
echo

log_info "3) Generating environment files..."
uv run ./.setup/scripts/setup/03-generate_env.py "$DEPLOYMENT_MODE"
echo

log_info "4) Building project..."
./.setup/scripts/setup/04-build.sh
echo

log_success "Setup completed successfully"