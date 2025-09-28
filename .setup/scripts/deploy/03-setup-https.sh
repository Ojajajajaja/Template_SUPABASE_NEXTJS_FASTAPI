#!/bin/bash

# =============================================================================
# HTTPS Setup Script - Template SUPABASE NEXTJS FASTAPI
# =============================================================================
# Configures SSL certificates for all domains with Let's Encrypt
# =============================================================================

set +e  # Don't exit on errors - we want to try all domains

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

log_info "HTTPS Configuration with Let's Encrypt"
log_info "Project directory: $PROJECT_ROOT"

if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run with sudo"
   exit 1
fi

if [[ ! -f "$ENV_CONFIG_FILE" ]]; then
    log_error "Configuration file $ENV_CONFIG_FILE does not exist"
    exit 1
fi

if ! command -v certbot &> /dev/null; then
    log_error "Certbot is not installed"
    exit 1
fi

if ! systemctl is-active --quiet nginx; then
    log_error "Nginx is not active"
    exit 1
fi

log_info "Loading configuration from $ENV_CONFIG_FILE"
source "$ENV_CONFIG_FILE"

FRONTEND_DOMAIN=$(echo "$FRONTEND_DOMAIN" | sed 's/^"\(.*\)"$/\1/')
BACKEND_DOMAIN=$(echo "$BACKEND_DOMAIN" | sed 's/^"\(.*\)"$/\1/')
SUPABASE_DOMAIN=$(echo "$SUPABASE_DOMAIN" | sed 's/^"\(.*\)"$/\1/')

if [[ -z "$FRONTEND_DOMAIN" || -z "$BACKEND_DOMAIN" || -z "$SUPABASE_DOMAIN" ]]; then
    log_error "Domains are not configured in .env.config file"
    exit 1
fi

log_info "Detected domains:"
log_info "  Frontend: $FRONTEND_DOMAIN"
log_info "  Backend: $BACKEND_DOMAIN"
log_info "  Supabase: $SUPABASE_DOMAIN"

create_temp_http_config() {
    local domain="$1"
    local service="$2"
    local port="$3"
    
    local temp_config="/etc/nginx/sites-available/${service}-temp.conf"
    
    cat > "$temp_config" << EOF
server {
    listen 80;
    server_name $domain;
    
    location / {
        proxy_pass http://127.0.0.1:$port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    
    ln -sf "$temp_config" "/etc/nginx/sites-enabled/${service}-temp.conf"
    log_info "Created temporary HTTP configuration for $domain"
}

setup_ssl_for_domain() {
    local domain="$1"
    local service="$2"
    local port="$3"
    
    log_info "Configuring SSL for $domain ($service)..."
    
    if [[ ! -f "/etc/nginx/sites-available/${service}.conf" ]]; then
        log_warning "Nginx configuration not found for $service"
        return 1
    fi
    
    create_temp_http_config "$domain" "$service" "$port"
    
    nginx -t && systemctl reload nginx
    
    if certbot --nginx -d "$domain" --non-interactive --agree-tos --email "admin@$domain" --redirect; then
        rm -f "/etc/nginx/sites-enabled/${service}-temp.conf"
        ln -sf "/etc/nginx/sites-available/${service}.conf" "/etc/nginx/sites-enabled/${service}.conf"
        log_success "SSL configured successfully for $domain"
        return 0
    else
        rm -f "/etc/nginx/sites-enabled/${service}-temp.conf"
        log_error "Failed to configure SSL for $domain"
        return 1
    fi
}

log_info "Starting SSL configuration..."

source "$ENV_CONFIG_FILE"
FRONTEND_PORT=${FRONTEND_PORT:-3000}
API_PORT=${API_PORT:-2000}
KONG_HTTP_PORT=${KONG_HTTP_PORT:-8000}

success_count=0
total_count=3
failed_domains=()

if setup_ssl_for_domain "$FRONTEND_DOMAIN" "frontend" "$FRONTEND_PORT"; then
    ((success_count++))
else
    failed_domains+=("$FRONTEND_DOMAIN (frontend)")
fi

if setup_ssl_for_domain "$BACKEND_DOMAIN" "backend" "$API_PORT"; then
    ((success_count++))
else
    failed_domains+=("$BACKEND_DOMAIN (backend)")
fi

if setup_ssl_for_domain "$SUPABASE_DOMAIN" "supabase" "$KONG_HTTP_PORT"; then
    ((success_count++))
else
    failed_domains+=("$SUPABASE_DOMAIN (supabase)")
fi

log_info "Testing Nginx configuration after SSL..."
if nginx -t; then
    log_success "Nginx configuration valid after SSL"
    systemctl reload nginx
    log_success "Nginx reloaded successfully"
else
    log_warning "Some Nginx configuration issues detected"
fi

log_info "Configuring automatic certificate renewal..."
if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
    log_success "Automatic renewal configured"
else
    log_info "Automatic renewal already configured"
fi

if [[ $success_count -gt 0 ]]; then
    log_success "HTTPS setup completed with $success_count/$total_count domains configured"
    exit 0
else
    log_error "No domains were successfully configured with SSL"
    exit 1
fi