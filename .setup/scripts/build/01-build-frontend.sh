#!/bin/bash

# =============================================================================
# Frontend Build Script - Template SUPABASE NEXTJS FASTAPI
# =============================================================================
# Builds the Next.js frontend application for production
# =============================================================================

set -e  # Stop script on error

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions to display messages
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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're in the .setup/scripts/build directory structure
if [[ "$SCRIPT_DIR" == *"/.setup/scripts/build"* ]]; then
    # Standard case: script is in PROJECT/.setup/scripts/build/
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"
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

FRONTEND_DIR="$PROJECT_ROOT/frontend"

log_info "Frontend Build Process"
log_info "Project directory: $PROJECT_ROOT"
log_info "Frontend directory: $FRONTEND_DIR"

# Check if frontend directory exists
if [[ ! -d "$FRONTEND_DIR" ]]; then
    log_error "Frontend directory does not exist: $FRONTEND_DIR"
    exit 1
fi

# Check if package.json exists
if [[ ! -f "$FRONTEND_DIR/package.json" ]]; then
    log_error "package.json not found in frontend directory"
    exit 1
fi

# Navigate to frontend directory
log_info "Navigating to frontend directory..."
cd "$FRONTEND_DIR"

if [[ ! -d "node_modules" ]]; then
    log_info "Installing frontend dependencies..."
    npm install
    log_success "Dependencies installed"
else
    log_info "Dependencies already installed"
fi

if ! npm run 2>/dev/null | grep -q "build"; then
    log_error "Build script not found in package.json"
    exit 1
fi

log_info "Building frontend application..."

if npm run build; then
    log_success "Frontend build completed successfully"
else
    log_error "Frontend build failed"
    exit 1
fi