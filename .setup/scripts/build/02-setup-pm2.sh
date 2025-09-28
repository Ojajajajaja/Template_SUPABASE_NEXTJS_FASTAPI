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

# Determine project root directory robustly
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're in the .setup/scripts/build directory structure
if [[ "$SCRIPT_DIR" == *"/.setup/scripts/build"* ]]; then
    # Standard case: script is in PROJECT/.setup/scripts/build/
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"
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

FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend"
SETUP_DIR="$PROJECT_ROOT/.setup"
ENV_CONFIG_FILE="$SETUP_DIR/.env.config"

log_info "=== PM2 Setup Process ==="
log_info "Project directory: $PROJECT_ROOT"

# Check if PM2 is installed globally
if ! command -v pm2 &> /dev/null; then
    log_error "PM2 is not installed"
    log_info "Please run 'make install-deps' or './.setup/scripts/00-install-dependencies.sh' first"
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

# Ensure we remove any existing configuration first
rm -f "$PROJECT_ROOT/ecosystem.config.js" 2>/dev/null || true

# Create our custom ecosystem configuration
log_info "Generating ecosystem.config.js with custom configuration..."
cat > "$PROJECT_ROOT/ecosystem.config.js" << 'EOF'
module.exports = {
  apps: [
    {
      name: 'frontend',
      cwd: './frontend',
      script: 'npm',
      args: 'start',
      env: {
        NODE_ENV: 'production',
        PORT: process.env.FRONTEND_PORT || 3000
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
      args: 'run.py prod',
      env: {
        PYTHONPATH: './backend',
        API_PORT: process.env.API_PORT || 2000
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
  ]
};
EOF

log_success "PM2 ecosystem configuration created"

# Create logs directory
log_info "Creating logs directory..."
mkdir -p "$PROJECT_ROOT/logs"
log_success "Logs directory created"

# Check if backend run.py exists
if [[ ! -f "$BACKEND_DIR/run.py" ]]; then
    log_error "Backend run.py not found in $BACKEND_DIR"
    exit 1
fi

# Stop any existing PM2 processes and clear configuration
log_info "Stopping any existing PM2 processes..."
pm2 delete all 2>/dev/null || true
pm2 kill 2>/dev/null || true

log_info "Starting with clean PM2 state"

log_success "=== PM2 setup completed successfully ==="
echo ""
log_info "PM2 configuration ready:"
log_info "  ✓ ecosystem.config.js - PM2 configuration file"
log_info "  ✓ logs/ - Directory for application logs"
echo ""
log_info "Ready to start applications with PM2!"