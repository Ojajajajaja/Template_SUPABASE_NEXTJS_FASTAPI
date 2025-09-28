#!/bin/bash

# =============================================================================
# Nginx Config Generation Script - Template SUPABASE NEXTJS FASTAPI
# =============================================================================
# Reads the .env.config file and generates nginx configurations
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

# Determine project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"
SETUP_DIR="$PROJECT_ROOT/.setup"
NGINX_TEMPLATES_DIR="$SETUP_DIR/nginx"
TARGET_NGINX_DIR="$PROJECT_ROOT/nginx"
ENV_CONFIG_FILE="$SETUP_DIR/.env.config"

log_info "Nginx Configuration Generation"
log_info "Project directory: $PROJECT_ROOT"
log_info "Templates directory: $NGINX_TEMPLATES_DIR"
log_info "Destination directory: $TARGET_NGINX_DIR"

if [[ ! -f "$ENV_CONFIG_FILE" ]]; then
    log_error "Configuration file $ENV_CONFIG_FILE does not exist"
    exit 1
fi

log_info "Loading configuration from $ENV_CONFIG_FILE"
source "$ENV_CONFIG_FILE"

if [[ -z "$FRONTEND_DOMAIN" || -z "$BACKEND_DOMAIN" || -z "$SUPABASE_DOMAIN" ]]; then
    log_error "Domains are not configured in .env.config file"
    exit 1
fi

if [[ -z "$FRONTEND_PORT" || -z "$API_PORT" || -z "$KONG_HTTP_PORT" ]]; then
    log_error "Ports are not configured in .env.config file"
    exit 1
fi

FRONTEND_DOMAIN=$(echo "$FRONTEND_DOMAIN" | sed 's/^"\(.*\)"$/\1/')
BACKEND_DOMAIN=$(echo "$BACKEND_DOMAIN" | sed 's/^"\(.*\)"$/\1/')
SUPABASE_DOMAIN=$(echo "$SUPABASE_DOMAIN" | sed 's/^"\(.*\)"$/\1/')

log_info "Configuration detected:"
log_info "  Frontend: $FRONTEND_DOMAIN:$FRONTEND_PORT"
log_info "  Backend: $BACKEND_DOMAIN:$API_PORT"
log_info "  Supabase: $SUPABASE_DOMAIN:$KONG_HTTP_PORT"

log_info "Creating nginx directory..."
mkdir -p "$TARGET_NGINX_DIR"

process_template() {
    local template_file="$1"
    local output_file="$2"
    local service_name="$3"
    
    log_info "Generating $service_name.conf..."
    
    sed -e "s/FRONTEND_DOMAIN/$FRONTEND_DOMAIN/g" \
        -e "s/BACKEND_DOMAIN/$BACKEND_DOMAIN/g" \
        -e "s/SUPABASE_DOMAIN/$SUPABASE_DOMAIN/g" \
        -e "s/FRONTEND_PORT/$FRONTEND_PORT/g" \
        -e "s/BACKEND_PORT/$API_PORT/g" \
        -e "s/API_PORT/$API_PORT/g" \
        -e "s/SUPABASE_PORT/$KONG_HTTP_PORT/g" \
        -e "s/KONG_HTTP_PORT/$KONG_HTTP_PORT/g" \
        "$template_file" > "$output_file"
    
    log_success "$service_name.conf generated"
}

if [[ -f "$NGINX_TEMPLATES_DIR/frontend.conf" ]]; then
    process_template "$NGINX_TEMPLATES_DIR/frontend.conf" "$TARGET_NGINX_DIR/frontend.conf" "Frontend"
else
    log_warning "frontend.conf template not found"
fi

if [[ -f "$NGINX_TEMPLATES_DIR/backend.conf" ]]; then
    process_template "$NGINX_TEMPLATES_DIR/backend.conf" "$TARGET_NGINX_DIR/backend.conf" "Backend"
else
    log_warning "backend.conf template not found"
fi

if [[ -f "$NGINX_TEMPLATES_DIR/supabase.conf" ]]; then
    process_template "$NGINX_TEMPLATES_DIR/supabase.conf" "$TARGET_NGINX_DIR/supabase.conf" "Supabase"
else
    log_warning "supabase.conf template not found"
fi

log_success "Nginx configurations generated successfully"