#!/bin/bash

# HTTPS configuration script with Let's Encrypt
# Configures SSL certificates for all domains

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
ENV_CONFIG_FILE="$SETUP_DIR/.env.config"

log_info "=== HTTPS Configuration with Let's Encrypt ==="
log_info "Project directory: $PROJECT_ROOT"

# Check root permissions
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run with sudo"
   log_info "Usage: sudo .setup/scripts/deploy/03-setup-https.sh"
   exit 1
fi

# Check that configuration file exists
if [[ ! -f "$ENV_CONFIG_FILE" ]]; then
    log_error "Configuration file $ENV_CONFIG_FILE does not exist"
    log_info "Please first run the configuration generation script"
    exit 1
fi

# Check that certbot is installed
if ! command -v certbot &> /dev/null; then
    log_error "Certbot is not installed"
    log_info "Please first run the Nginx installation script"
    exit 1
fi

# Check that Nginx is installed and running
if ! systemctl is-active --quiet nginx; then
    log_error "Nginx is not active"
    log_info "Please first install and start Nginx"
    exit 1
fi

# Load environment variables
log_info "Loading configuration from $ENV_CONFIG_FILE"
source "$ENV_CONFIG_FILE"

# Clean domains (remove quotes)
FRONTEND_DOMAIN=$(echo "$FRONTEND_DOMAIN" | sed 's/^"\(.*\)"$/\1/')
BACKEND_DOMAIN=$(echo "$BACKEND_DOMAIN" | sed 's/^"\(.*\)"$/\1/')
SUPABASE_DOMAIN=$(echo "$SUPABASE_DOMAIN" | sed 's/^"\(.*\)"$/\1/')

# Check that domains are configured
if [[ -z "$FRONTEND_DOMAIN" || -z "$BACKEND_DOMAIN" || -z "$SUPABASE_DOMAIN" ]]; then
    log_error "Domains are not configured in .env.config file"
    exit 1
fi

log_info "Detected domains:"
log_info "  Frontend: $FRONTEND_DOMAIN"
log_info "  Backend: $BACKEND_DOMAIN"
log_info "  Supabase: $SUPABASE_DOMAIN"

# Function to configure SSL for a domain
setup_ssl_for_domain() {
    local domain="$1"
    local service="$2"
    
    log_info "Configuring SSL for $domain ($service)..."
    
    # Check that Nginx configuration exists
    if [[ ! -f "/etc/nginx/sites-enabled/${service}.conf" ]]; then
        log_warning "Nginx configuration not found for $service"
        return 1
    fi
    
    # Attempt to configure SSL with certbot
    if certbot --nginx -d "$domain" --non-interactive --agree-tos --email "admin@$domain" --redirect; then
        log_success "SSL configured successfully for $domain"
        return 0
    else
        log_error "Failed to configure SSL for $domain"
        return 1
    fi
}

# SSL configuration for each domain
log_info "Starting SSL configuration..."
echo ""

# Variables to track results
success_count=0
total_count=3
failed_domains=()

# Frontend
echo "========================================="
if setup_ssl_for_domain "$FRONTEND_DOMAIN" "frontend"; then
    ((success_count++))
else
    failed_domains+=("$FRONTEND_DOMAIN (frontend)")
fi
echo ""

# Backend
echo "========================================="
if setup_ssl_for_domain "$BACKEND_DOMAIN" "backend"; then
    ((success_count++))
else
    failed_domains+=("$BACKEND_DOMAIN (backend)")
fi
echo ""

# Supabase
echo "========================================="
if setup_ssl_for_domain "$SUPABASE_DOMAIN" "supabase"; then
    ((success_count++))
else
    failed_domains+=("$SUPABASE_DOMAIN (supabase)")
fi
echo ""

# Test Nginx configuration after SSL modifications
log_info "Testing Nginx configuration after SSL..."
if nginx -t; then
    log_success "Nginx configuration valid after SSL"
    systemctl reload nginx
    log_success "Nginx reloaded successfully"
else
    log_error "Error in Nginx configuration after SSL"
    exit 1
fi

# Configure automatic certificate renewal
log_info "Configuring automatic certificate renewal..."
if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
    log_success "Automatic renewal configured (daily at 12pm)"
else
    log_info "Automatic renewal already configured"
fi

# Final summary
echo ""
log_success "=== HTTPS Configuration Completed ==="
echo ""
log_info "SSL configuration results:"
log_info "  Success: $success_count/$total_count domains"

if [[ ${#failed_domains[@]} -gt 0 ]]; then
    log_warning "Failed domains:"
    for domain in "${failed_domains[@]}"; do
        log_warning "  ✗ $domain"
    done
    echo ""
    log_info "Possible failure causes:"
    log_info "  - DNS not configured correctly"
    log_info "  - Domain not accessible from Internet"
    log_info "  - Firewall blocking ports 80/443"
    log_info "  - Incorrect Nginx configuration"
fi

if [[ $success_count -gt 0 ]]; then
    echo ""
    log_info "SSL certificates configured successfully!"
    log_info "  ✓ Automatic renewal enabled"
    log_info "  ✓ HTTPS enforced (HTTP → HTTPS redirect)"
    echo ""
    log_info "Your sites are now accessible via HTTPS:"
    [[ $success_count -eq 3 ]] && log_info "  🌐 https://$FRONTEND_DOMAIN"
    [[ $success_count -eq 3 ]] && log_info "  🔧 https://$BACKEND_DOMAIN"
    [[ $success_count -eq 3 ]] && log_info "  🗄️ https://$SUPABASE_DOMAIN"
fi

echo ""