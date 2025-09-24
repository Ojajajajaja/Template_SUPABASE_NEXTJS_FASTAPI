#!/bin/bash

# Frontend build script
# Builds the Next.js frontend application for production

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

# Determine project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

log_info "=== Frontend Build Process ==="
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
cd "$FRONTEND_DIR"

# Check if node_modules exists, if not install dependencies
if [[ ! -d "node_modules" ]]; then
    log_info "Installing frontend dependencies..."
    npm install
    log_success "Dependencies installed successfully"
else
    log_info "Dependencies already installed"
fi

# Check if build script exists in package.json
if ! npm run --silent 2>/dev/null | grep -q "build"; then
    log_error "Build script not found in package.json"
    log_info "Please ensure your package.json has a 'build' script"
    exit 1
fi

# Build the frontend
log_info "Building frontend application..."
log_info "Running: npm run build"

if npm run build; then
    log_success "Frontend build completed successfully"
else
    log_error "Frontend build failed"
    exit 1
fi

# Check if build output exists
if [[ -d ".next" ]]; then
    log_success "Build output directory '.next' created"
    
    # Display build size information
    if command -v du &> /dev/null; then
        build_size=$(du -sh .next 2>/dev/null | cut -f1)
        log_info "Build size: $build_size"
    fi
else
    log_warning "Build output directory '.next' not found"
fi

# Check for static files
if [[ -d ".next/static" ]]; then
    static_files=$(find .next/static -type f | wc -l)
    log_info "Static files generated: $static_files files"
fi

log_success "=== Frontend build process completed ==="
echo ""
log_info "Next steps:"
log_info "- Frontend is ready for production deployment"
log_info "- You can start the production server with 'npm start'"
log_info "- Or use PM2 for process management"