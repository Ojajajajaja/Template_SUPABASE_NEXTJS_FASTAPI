#!/bin/bash

# Main project deployment script
# Executes all deployment scripts in order

set -e  # Stop script if a command fails

echo "========================================"
echo "    PROJECT DEPLOYMENT SCRIPT"
echo "========================================"
echo ""

# 1) Generate Nginx configurations
echo "1) Generating Nginx configurations..."
echo "----------------------------------------"
.setup/scripts/deploy/01-generate-nginx-configs.sh
echo ""
read -p "Press Enter to continue..."

echo ""

# 2) Install and configure Nginx
echo "2) Installing and configuring Nginx..."
echo "----------------------------------------"
echo "⚠️  This step requires sudo privileges"
echo "   The script will install: Nginx, Certbot, UFW"
echo "   And configure the generated configurations"
read -p "Press Enter to continue or Ctrl+C to skip..."
sudo .setup/scripts/deploy/02-install-nginx.sh
echo ""
read -p "Press Enter to continue..."

echo ""

# 3) Setup HTTPS with Let's Encrypt
echo "3) Setting up HTTPS with Let's Encrypt..."
echo "----------------------------------------"
echo "⚠️  This step requires sudo privileges"
echo "   The script will configure SSL certificates for all domains"
echo "   Make sure your DNS records point to this server!"
read -p "Press Enter to continue or Ctrl+C to skip..."
sudo .setup/scripts/deploy/03-setup-https.sh
echo ""
read -p "Press Enter to continue..."

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