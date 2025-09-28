#!/bin/bash

# Services launch script
# Starts all applications using PM2

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

ECOSYSTEM_CONFIG="$PROJECT_ROOT/ecosystem.config.js"

log_info "=== Services Launch Process ==="
log_info "Project directory: $PROJECT_ROOT"

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    log_error "PM2 is not installed"
    log_info "Please run 'make install-deps' first"
    exit 1
fi

# Start all applications using PM2
log_info "Starting applications with PM2..."

# First, ensure we're in the project root directory
cd "$PROJECT_ROOT"

# Stop and delete any existing PM2 processes to avoid conflicts
log_info "Cleaning up any existing PM2 processes..."

pm2 delete all 2>/dev/null || true
pm2 kill 2>/dev/null || true

# Remove PM2 cache and any default ecosystem files that might interfere
rm -f "$HOME/.pm2/dump.pm2" 2>/dev/null || true

# Wait a moment for cleanup
sleep 2

# Always create a fresh, correct ecosystem configuration
log_info "Creating fresh ecosystem configuration..."

# Ensure logs directory exists
mkdir -p "$PROJECT_ROOT/logs"

# Verify UV is available
if ! command -v uv &> /dev/null; then
    log_error "UV not found. Please install UV first with 'make install-deps'."
    exit 1
fi

# Load configuration to get ports
if [[ -f "$PROJECT_ROOT/.setup/.env.config" ]]; then
    source "$PROJECT_ROOT/.setup/.env.config"
fi

# Set defaults if not defined
FRONTEND_PORT=${FRONTEND_PORT:-3000}
API_PORT=${API_PORT:-2000}

log_info "Using UV for backend execution"

cat > "$ECOSYSTEM_CONFIG" << EOF
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
      error_file: '../logs/frontend-error.log',
      out_file: '../logs/frontend-out.log',
      log_file: '../logs/frontend-combined.log',
      time: true
    },
    {
      name: 'backend',
      cwd: './backend',
      script: 'uv',
      args: 'run run.py',
      env: {
        API_PORT: $API_PORT
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      error_file: '../logs/backend-error.log',
      out_file: '../logs/backend-out.log',
      log_file: '../logs/backend-combined.log',
      time: true
    }
  ]
};
EOF
log_success "Fresh ecosystem configuration created"

# Start fresh with our ecosystem configuration
log_info "Starting fresh PM2 processes with ecosystem config..."

# Start with our specific ecosystem file, using absolute path
if pm2 start "$(realpath "$ECOSYSTEM_CONFIG")" --env production; then
    log_success "PM2 start command executed successfully"
else
    log_error "Failed to start applications with PM2"
    log_info "Ecosystem config file: $ECOSYSTEM_CONFIG"
    log_info "Current directory: $(pwd)"
    if [[ -f "$ECOSYSTEM_CONFIG" ]]; then
        log_info "Ecosystem config exists, checking contents..."
        head -20 "$ECOSYSTEM_CONFIG"
    else
        log_error "Ecosystem config file not found!"
    fi
    exit 1
fi

echo ""
log_info "Checking service status..."

# Display PM2 status
log_info "Current PM2 status:"
echo "----------------------------------------"
pm2 status
echo "----------------------------------------"

# Load configuration to get the actual ports
if [[ -f "$PROJECT_ROOT/.setup/.env.config" ]]; then
    source "$PROJECT_ROOT/.setup/.env.config"
fi
FRONTEND_PORT=${FRONTEND_PORT:-3000}
API_PORT=${API_PORT:-2000}

# Check if services are actually running
if pm2 status | grep -q "frontend.*online" && pm2 status | grep -q "backend.*online"; then
    echo ""
    log_success "=== All services started successfully! ==="
    echo ""
    log_info "Your applications are now running:"
    log_success "Frontend: http://localhost:$FRONTEND_PORT"
    log_success "Backend:  http://localhost:$API_PORT"
    echo ""
    log_info "Useful PM2 commands:"
    log_info "  pm2 status    - Show process status"
    log_info "  pm2 logs      - Show all logs"
    log_info "  pm2 restart all - Restart all processes"
else
    echo ""
    log_warning "Some services failed to start properly"
    log_info "Check the logs with: pm2 logs"
    exit 1
fi