#!/bin/bash

# PM2 setup script
# Configures PM2 for both backend and frontend services

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
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend"
SETUP_DIR="$PROJECT_ROOT/.setup"
ENV_CONFIG_FILE="$SETUP_DIR/.env.config"

log_info "=== PM2 Setup Process ==="
log_info "Project directory: $PROJECT_ROOT"

# Check if PM2 is installed globally
if ! command -v pm2 &> /dev/null; then
    log_error "PM2 is not installed"
    log_info "Please run 'make install-deps' or './.setup/scripts/install-dependencies.sh' first"
    exit 1
else
    log_info "PM2 is already installed"
fi

# Load environment configuration if it exists
if [[ -f "$ENV_CONFIG_FILE" ]]; then
    log_info "Loading configuration from $ENV_CONFIG_FILE"
    source "$ENV_CONFIG_FILE"
    
    # Clean domain values (remove quotes)
    FRONTEND_DOMAIN=$(echo "$FRONTEND_DOMAIN" | sed 's/^"\(.*\)"$/\1/' 2>/dev/null || echo "localhost")
    BACKEND_DOMAIN=$(echo "$BACKEND_DOMAIN" | sed 's/^"\(.*\)"$/\1/' 2>/dev/null || echo "localhost")
else
    log_warning "Configuration file not found, using default values"
    FRONTEND_PORT=3000
    API_PORT=2000
    FRONTEND_DOMAIN="localhost"
    BACKEND_DOMAIN="localhost"
fi

# Set default values if not defined
FRONTEND_PORT=${FRONTEND_PORT:-3000}
API_PORT=${API_PORT:-2000}

log_info "Configuration:"
log_info "  Frontend: $FRONTEND_DOMAIN:$FRONTEND_PORT"
log_info "  Backend: $BACKEND_DOMAIN:$API_PORT"

# Create PM2 ecosystem configuration
log_info "Creating PM2 ecosystem configuration..."

cat > "$PROJECT_ROOT/ecosystem.config.js" << EOF
module.exports = {
  apps: [
    {
      name: 'frontend',
      cwd: './frontend',
      script: 'npm',
      args: 'start',
      env: {
        NODE_ENV: 'production',
        PORT: $FRONTEND_PORT
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      log_file: './logs/frontend-combined.log',
      time: true
    },
    {
      name: 'backend',
      cwd: './backend',
      script: 'python',
      args: 'main.py',
      env: {
        PYTHONPATH: './backend',
        API_PORT: $API_PORT
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      log_file: './logs/backend-combined.log',
      time: true
    }
  ],

  deploy: {
    production: {
      user: 'node',
      host: '$BACKEND_DOMAIN',
      ref: 'origin/main',
      repo: 'git@github.com:repo.git',
      path: '/var/www/production',
      'pre-deploy-local': '',
      'post-deploy': 'npm install && pm2 reload ecosystem.config.js --env production',
      'pre-setup': ''
    }
  }
};
EOF

log_success "PM2 ecosystem configuration created"

# Create logs directory
log_info "Creating logs directory..."
mkdir -p "$PROJECT_ROOT/logs"
log_success "Logs directory created"

# Check if frontend build exists
if [[ ! -d "$FRONTEND_DIR/.next" ]]; then
    log_warning "Frontend build not found. Please run the build script first."
fi

# Check if backend main.py exists
if [[ ! -f "$BACKEND_DIR/main.py" ]]; then
    log_error "Backend main.py not found in $BACKEND_DIR"
    exit 1
fi

# Stop any existing PM2 processes
log_info "Stopping any existing PM2 processes..."
pm2 delete all 2>/dev/null || true
log_info "Existing processes stopped"

# Validate ecosystem configuration
log_info "Validating PM2 ecosystem configuration..."
if pm2 ecosystem "$PROJECT_ROOT/ecosystem.config.js" &>/dev/null; then
    log_success "PM2 ecosystem configuration is valid"
else
    log_error "PM2 ecosystem configuration validation failed"
    exit 1
fi

log_success "=== PM2 setup completed successfully ==="
echo ""
log_info "PM2 configuration created:"
log_info "  ✓ ecosystem.config.js - PM2 configuration file"
log_info "  ✓ logs/ - Directory for application logs"
echo ""
log_info "Applications configured:"
log_info "  ✓ frontend - Next.js application (port $FRONTEND_PORT)"
log_info "  ✓ backend - FastAPI application (port $API_PORT)"
echo ""
log_info "Ready to start applications with PM2!"