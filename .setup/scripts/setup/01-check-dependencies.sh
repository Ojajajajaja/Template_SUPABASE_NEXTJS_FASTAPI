#!/bin/bash

# =============================================================================
# Dependencies Check Script - Template SUPABASE NEXTJS FASTAPI
# =============================================================================
# Checks for uv, docker compose and npm
# In production mode, also checks for PM2
# =============================================================================

set -e  # Stop script on error

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

# Get deployment mode from environment variable or argument
DEPLOYMENT_MODE="${DEPLOYMENT_MODE:-development}"
if [ $# -eq 1 ]; then
    DEPLOYMENT_MODE="$1"
fi

log_info "Checking dependencies for $DEPLOYMENT_MODE mode..."
echo

# Initialize error count
ERROR_COUNT=0

# Check if .env.config exists in .setup directory
log_info "=== Checking .env.config file ==="
if [ -f "./.setup/.env.config" ]; then
    log_success ".env.config file exists"
else
    log_error ".env.config file is missing in .setup directory"
    ((ERROR_COUNT++))
fi
echo

log_info "=== Checking uv ==="
if command -v uv &> /dev/null; then
    log_success "uv is installed: $(uv --version)"
else
    log_error "uv is not installed"
    ((ERROR_COUNT++))
fi
echo

log_info "=== Checking docker ==="
if command -v docker &> /dev/null; then
    log_success "Docker is installed: $(docker --version)"
    
    if docker compose version &> /dev/null; then
        log_success "Docker Compose is available"
    else
        log_error "Docker Compose is not available"
        ((ERROR_COUNT++))
    fi
else
    log_error "Docker is not installed"
    ((ERROR_COUNT++))
fi
echo

log_info "=== Checking npm ==="
if command -v npm &> /dev/null; then
    log_success "npm is installed: $(npm --version)"
else
    log_error "npm is not installed"
    ((ERROR_COUNT++))
fi
echo

if [ "$DEPLOYMENT_MODE" = "production" ]; then
    log_info "=== Checking PM2 (Production mode) ==="
    if command -v pm2 &> /dev/null; then
        log_success "PM2 is installed: $(pm2 --version)"
    else
        log_error "PM2 is not installed"
        ((ERROR_COUNT++))
    fi
    echo
    
    log_info "=== Checking Nginx (Production mode) ==="
    if command -v nginx &> /dev/null; then
        log_success "Nginx is installed"
    else
        log_error "Nginx is not installed"
        ((ERROR_COUNT++))
    fi
    echo
    
    log_info "=== Checking Certbot (Production mode) ==="
    if command -v certbot &> /dev/null; then
        log_success "Certbot is installed"
    else
        log_error "Certbot is not installed"
        ((ERROR_COUNT++))
    fi
    echo
    
    log_info "=== Checking Python 3 (Production mode) ==="
    if command -v python3 &> /dev/null; then
        log_success "Python 3 is installed: $(python3 --version)"
    else
        log_error "Python 3 is not installed"
        ((ERROR_COUNT++))
    fi
    echo
fi

if [ $ERROR_COUNT -gt 0 ]; then
    log_error "$ERROR_COUNT dependencies are missing!"
    exit 1
else
    log_success "All required dependencies are installed!"
fi