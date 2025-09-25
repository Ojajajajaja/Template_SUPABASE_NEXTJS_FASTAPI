#!/bin/bash

# Main project deployment script
# Executes all deployment scripts in order

set -e  # Stop script if a command fails

# Determine project root directory robustly
# This script can be called from different locations
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're in the .setup/scripts directory structure
if [[ "$SCRIPT_DIR" == *"/.setup/scripts"* ]]; then
    # Standard case: script is in PROJECT/.setup/scripts/
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"
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

# Change to project root
cd "$PROJECT_ROOT"

echo "========================================"
echo "    PROJECT DEPLOYMENT SCRIPT"
echo "========================================"
echo "Project root: $PROJECT_ROOT"
echo ""

# 1) Generate Nginx configurations
echo "1) Generating Nginx configurations..."
echo "----------------------------------------"
./.setup/scripts/deploy/01-generate-nginx-configs.sh
echo ""

# 2) Install and configure Nginx
echo "2) Installing and configuring Nginx..."
echo "----------------------------------------"
echo "⚠️  This step requires sudo privileges"
echo "   The script will install: Nginx, Certbot, UFW"
echo "   And configure the generated configurations"
sudo "./.setup/scripts/deploy/02-install-nginx.sh"
echo ""

# 3) Setup HTTPS with Let's Encrypt
echo "3) Setting up HTTPS with Let's Encrypt..."
echo "----------------------------------------"
echo "⚠️  This step requires sudo privileges"
echo "   The script will configure SSL certificates for all domains"
echo "   Make sure your DNS records point to this server!"
sudo "./.setup/scripts/deploy/03-setup-https.sh"
echo ""

echo "========================================"
echo "  DEPLOYMENT COMPLETED SUCCESSFULLY !"
echo "========================================"
echo ""
echo "The following steps have been completed:"
echo "✓ Nginx configurations generation"
echo "✓ Nginx installation and configuration"
echo "✓ HTTPS/SSL certificates setup"
echo ""
echo "Your applications should now be accessible via HTTPS!"
echo "Next steps:"
echo "- Start your applications (frontend, backend, supabase)"
echo "- Test the HTTPS URLs in your browser"
echo "- Monitor SSL certificate auto-renewal"
echo ""
echo "Reloading Nginx to ensure all configurations are active..."
sudo systemctl reload nginx
echo "✓ Nginx reloaded successfully"