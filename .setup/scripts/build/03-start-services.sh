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

# Determine project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"
ECOSYSTEM_CONFIG="$PROJECT_ROOT/ecosystem.config.js"

log_info "=== Services Launch Process ==="
log_info "Project directory: $PROJECT_ROOT"

# Check if we're running as production user or with proper permissions
if [[ -n "$SUDO_USER" ]]; then
    log_warning "Running with sudo. PM2 processes will be owned by $SUDO_USER"
    log_info "Consider running as the production user directly for better PM2 management"
fi

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    log_error "PM2 is not installed"
    log_info "Please run the PM2 setup script first"
    exit 1
fi

# Check if ecosystem configuration exists
if [[ ! -f "$ECOSYSTEM_CONFIG" ]]; then
    log_error "PM2 ecosystem configuration not found: $ECOSYSTEM_CONFIG"
    log_info "Please run the PM2 setup script first"
    exit 1
fi

# Function to check if a service is running
check_service_status() {
    local service_name="$1"
    if pm2 describe "$service_name" &>/dev/null; then
        local status=$(pm2 describe "$service_name" | grep -o 'status.*' | head -1 | cut -d':' -f2 | tr -d ' ')
        echo "$status"
    else
        echo "stopped"
    fi
}

# Function to wait for service to start
wait_for_service() {
    local service_name="$1"
    local max_attempts=30
    local attempt=0
    
    log_info "Waiting for $service_name to start..."
    
    while [[ $attempt -lt $max_attempts ]]; do
        local status=$(check_service_status "$service_name")
        if [[ "$status" == "online" ]]; then
            log_success "$service_name is running"
            return 0
        fi
        
        sleep 2
        ((attempt++))
        echo -n "."
    done
    
    echo ""
    log_error "$service_name failed to start within timeout"
    return 1
}

# Start all applications using PM2
log_info "Starting applications with PM2..."

# Start using ecosystem configuration
if pm2 start "$ECOSYSTEM_CONFIG"; then
    log_success "PM2 start command executed successfully"
else
    log_error "Failed to start applications with PM2"
    exit 1
fi

echo ""
log_info "Checking service status..."

# Wait for frontend to start
if wait_for_service "frontend"; then
    frontend_status="✓"
else
    frontend_status="✗"
fi

# Wait for backend to start
if wait_for_service "backend"; then
    backend_status="✓"
else
    backend_status="✗"
fi

echo ""

# Display PM2 status
log_info "Current PM2 status:"
echo "----------------------------------------"
pm2 status
echo "----------------------------------------"

# Display service URLs
log_info "Service URLs:"
source "$PROJECT_ROOT/.setup/.env.config" 2>/dev/null || true
FRONTEND_PORT=${FRONTEND_PORT:-3000}
API_PORT=${API_PORT:-2000}

echo ""
log_info "Applications status:"
log_info "  $frontend_status Frontend: http://localhost:$FRONTEND_PORT"
log_info "  $backend_status Backend:  http://localhost:$API_PORT"

# Check if all services are running
if [[ "$frontend_status" == "✓" && "$backend_status" == "✓" ]]; then
    echo ""
    log_success "=== All services started successfully! ==="
    echo ""
    log_info "Useful PM2 commands:"
    log_info "  pm2 status          - Show process status"
    log_info "  pm2 logs            - Show all logs"
    log_info "  pm2 logs frontend   - Show frontend logs"
    log_info "  pm2 logs backend    - Show backend logs"
    log_info "  pm2 restart all     - Restart all processes"
    log_info "  pm2 stop all        - Stop all processes"
    log_info "  pm2 delete all      - Delete all processes"
    echo ""
    log_info "Your applications are now running in production mode!"
else
    echo ""
    log_warning "Some services failed to start properly"
    log_info "Check the logs with: pm2 logs"
    log_info "Check individual service status with: pm2 describe <service-name>"
    exit 1
fi