#!/bin/bash

# =============================================================================
# Project Build Script - Template SUPABASE NEXTJS FASTAPI
# =============================================================================
# Executes synchronization commands for backend, frontend and supabase
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

log_info "Starting build process..."

log_info "Synchronizing backend..."
cd backend/
uv sync
cd ../

log_info "Installing frontend dependencies..."
cd frontend/
npm install
cd ../

log_info "Updating Docker images for Supabase..."
cd supabase/

if ! docker info >/dev/null 2>&1; then
    log_warning "Docker access denied. This might be due to permissions."
    log_warning "Attempting to continue..."
fi

docker compose pull
docker compose up -d

log_info "Waiting for database to be available..."
sleep 20

log_info "Checking database availability..."
if ! docker compose exec -T db pg_isready -U postgres -d postgres; then
    log_warning "Database not ready. Waiting additional time..."
    sleep 10
    docker compose exec -T db pg_isready -U postgres -d postgres
fi

log_info "Copying seed script to database..."
if ! docker compose cp ../.setup/supabase-setup/seed-oja.sql db:/tmp/seed-oja.sql; then
    log_error "Could not copy seed script. Check Docker permissions."
    exit 1
fi

log_info "Executing database seed script..."
if ! docker compose exec -T db psql -U postgres -d postgres -f /tmp/seed-oja.sql; then
    log_error "Could not execute seed script. Check database connection."
    exit 1
fi

cd ../

log_success "Build completed successfully!"