#!/bin/bash

# Nginx installation and configuration script
# Installs Nginx, Let's Encrypt and configures sites

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

log_info "=== Nginx Installation and Configuration ==="
log_info "Project directory: $PROJECT_ROOT"
log_info "Configurations directory: $NGINX_CONFIG_DIR"

# Check root permissions
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run with sudo"
   log_info "Usage: sudo .setup/scripts/deploy/02-install-nginx.sh"
   exit 1
fi

# Check that nginx directory exists
if [[ ! -d "$NGINX_CONFIG_DIR" ]]; then
    log_error "Nginx directory does not exist: $NGINX_CONFIG_DIR"
    log_info "Please first run the configuration generation script"
    exit 1
fi

# Check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    log_error "Nginx is not installed"
    log_info "Please run 'make install-deps' or './.setup/scripts/install-dependencies.sh' first"
    exit 1
else
    log_info "Nginx is already installed"
fi

# Check if Certbot is installed
if ! command -v certbot &> /dev/null; then
    log_error "Certbot is not installed"
    log_info "Please run 'make install-deps' or './.setup/scripts/install-dependencies.sh' first"
    exit 1
else
    log_info "Certbot is already installed"
fi

# Start and enable Nginx
log_info "Configuring Nginx service..."
systemctl enable nginx
systemctl start nginx
log_success "Nginx service enabled and started"

# Configure basic firewall (if UFW is available)
log_info "Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw --force enable
    ufw allow 'Nginx Full'
    ufw allow OpenSSH
    log_success "Firewall configured"
else
    log_warning "UFW not available, skipping firewall configuration"
fi

# Copy configurations to sites-available
log_info "Copying Nginx configurations..."
for conf_file in "$NGINX_CONFIG_DIR"/*.conf; do
    if [[ -f "$conf_file" ]]; then
        filename=$(basename "$conf_file")
        cp "$conf_file" "/etc/nginx/sites-available/"
        log_success "Configuration $filename copied"
    fi
done

# Remove default configuration if it exists
if [[ -f "/etc/nginx/sites-enabled/default" ]]; then
    log_info "Removing default configuration..."
    rm -f "/etc/nginx/sites-enabled/default"
    log_success "Default configuration removed"
fi

# Create symbolic links in sites-enabled
log_info "Creating symbolic links..."
for conf_file in /etc/nginx/sites-available/*.conf; do
    if [[ -f "$conf_file" ]]; then
        filename=$(basename "$conf_file")
        service_name="${filename%.conf}"
        
        # Create symbolic link
        ln -sf "/etc/nginx/sites-available/$filename" "/etc/nginx/sites-enabled/$filename"
        log_success "Site $service_name enabled"
    fi
done

# Test Nginx configuration
log_info "Testing Nginx configuration..."
if nginx -t; then
    log_success "Nginx configuration is valid"
    
    # Reload Nginx
    log_info "Reloading Nginx..."
    systemctl reload nginx
    log_success "Nginx reloaded successfully"
else
    log_error "Error in Nginx configuration"
    log_warning "Check configurations in /etc/nginx/sites-available/"
    exit 1
fi

# Display service status
log_info "Service status:"
echo "----------------------------------------"
systemctl status nginx --no-pager -l
echo "----------------------------------------"

log_success "=== Installation and configuration completed successfully ==="
echo ""
log_info "Installed and configured services:"
log_info "  ✓ Nginx (web server)"
log_info "  ✓ Certbot (Let's Encrypt SSL)"
log_info "  ✓ UFW (firewall)"
echo ""
log_info "Enabled Nginx configurations:"
for conf_file in /etc/nginx/sites-enabled/*.conf; do
    if [[ -f "$conf_file" ]]; then
        filename=$(basename "$conf_file" .conf)
        log_info "  ✓ $filename"
    fi
done
echo ""