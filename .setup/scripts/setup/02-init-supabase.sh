#!/bin/bash

# =============================================================================
# Supabase Init Script - Template SUPABASE NEXTJS FASTAPI
# =============================================================================
# Script to initialize Supabase Docker
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

log_info "Initializing Supabase Docker..."

if [ -d "supabase" ]; then
    log_warning "Directory 'supabase' exists. Renaming to 'supabase_old'..."
    mv supabase supabase_old
    log_success "Renamed successfully"
fi

log_info "Cloning Supabase repository..."
git clone --depth 1 https://github.com/supabase/supabase

log_info "Creating Supabase project directory..."
mkdir supabase-project

log_info "Copying Docker files..."
cp -rf supabase/docker/* supabase-project

log_info "Copying environment file..."
cp supabase/docker/.env.example supabase-project/.env.example
cp supabase/docker/.env.example supabase-project/.env

log_info "Cleaning up cloned repository..."
rm -rf supabase/

log_info "Finalizing setup..."
mv supabase-project supabase

log_info "Copying additional files..."
cp .setup/supabase/.gitignore supabase/

log_success "Supabase initialization completed successfully!"