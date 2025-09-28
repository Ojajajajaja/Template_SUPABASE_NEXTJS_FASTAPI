#!/bin/bash

# =============================================================================
# Project Deployment Script - Template SUPABASE NEXTJS FASTAPI
# =============================================================================
# Executes all deployment scripts in order
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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    log_error "Deploy script should not be run as root!"
    log_info "Switch to your production user and run the script again."
    exit 1
fi

echo "Project Deployment"
echo "Project root: $PROJECT_ROOT"
echo

log_info "1) Generating Nginx configurations..."
./.setup/scripts/deploy/01-generate-nginx-configs.sh
echo

log_info "2) Installing and configuring Nginx..."
log_warning "This step requires sudo privileges"
sudo "./.setup/scripts/deploy/02-install-nginx.sh"
echo

log_info "3) Setting up HTTPS with Let's Encrypt..."
log_warning "This step requires sudo privileges"
sudo "./.setup/scripts/deploy/03-setup-https.sh"
echo

log_success "Deployment completed successfully"

log_info "Reloading Nginx..."
sudo systemctl reload nginx
log_success "Nginx reloaded"