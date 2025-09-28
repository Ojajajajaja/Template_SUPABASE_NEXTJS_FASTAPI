#!/bin/bash

# =============================================================================
# Nginx Installation Script - Template SUPABASE NEXTJS FASTAPI
# =============================================================================
# Installs Nginx, Let's Encrypt and configures sites
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
NGINX_CONFIG_DIR="$PROJECT_ROOT/nginx"

log_info "Nginx Installation and Configuration"
log_info "Project directory: $PROJECT_ROOT"
log_info "Configurations directory: $NGINX_CONFIG_DIR"

if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run with sudo"
   exit 1
fi

if [[ ! -d "$NGINX_CONFIG_DIR" ]]; then
    log_error "Nginx directory does not exist: $NGINX_CONFIG_DIR"
    exit 1
fi

if ! command -v nginx &> /dev/null; then
    log_error "Nginx is not installed"
    exit 1
else
    log_info "Nginx is already installed"
fi

if ! command -v certbot &> /dev/null; then
    log_error "Certbot is not installed"
    exit 1
else
    log_info "Certbot is already installed"
fi

log_info "Configuring Nginx service..."
systemctl enable nginx
systemctl start nginx
log_success "Nginx service enabled and started"

log_info "Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw --force enable
    ufw allow 'Nginx Full'
    ufw allow OpenSSH
    log_success "Firewall configured"
else
    log_warning "UFW not available, skipping firewall configuration"
fi

log_info "Copying Nginx configurations..."
for conf_file in "$NGINX_CONFIG_DIR"/*.conf; do
    if [[ -f "$conf_file" ]]; then
        filename=$(basename "$conf_file")
        cp "$conf_file" "/etc/nginx/sites-available/"
        log_success "Configuration $filename copied"
    fi
done

if [[ -f "/etc/nginx/sites-enabled/default" ]]; then
    log_info "Removing default configuration..."
    rm -f "/etc/nginx/sites-enabled/default"
    log_success "Default configuration removed"
fi

log_info "Cleaning up existing configurations..."
rm -f /etc/nginx/sites-enabled/*.conf
log_success "Existing configurations cleaned"

# Create symbolic links in sites-enabled (skip all configurations for now - will be handled by HTTPS script)
log_info "Preparing configurations (sites will be enabled during SSL setup)..."
# Don't create any symbolic links here - let the SSL script handle this

log_info "Testing Nginx configuration..."

if grep -r "ssl_certificate" /etc/nginx/sites-enabled/ 2>/dev/null; then
    log_warning "Found SSL references - removing them"
    rm -f /etc/nginx/sites-enabled/*.conf
fi

if nginx -t; then
    log_success "Nginx configuration is valid"
    
    log_info "Reloading Nginx..."
    systemctl reload nginx
    log_success "Nginx reloaded successfully"
else
    log_error "Nginx configuration test failed"
    exit 1
fi

log_success "Installation and configuration completed successfully"