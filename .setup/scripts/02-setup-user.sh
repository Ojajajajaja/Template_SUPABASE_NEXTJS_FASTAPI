#!/bin/bash

# User setup and project relocation script
# Creates production user, moves project to user home, and sets permissions

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

# Function to run commands with automatic sudo password
run_sudo() {
    if [[ $EUID -eq 0 ]]; then
        # Already running as root, execute directly
        "$@"
    else
        # Use sudo with password
        echo "$PROD_PASSWORD" | sudo -S "$@" 2>/dev/null
    fi
}

# Determine project root directory
# This script can be called from different locations, so we need to find the actual project root
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
    
    # If not found, check if .setup exists in current directory
    if [[ ! -d "$PROJECT_ROOT/.setup" ]]; then
        # Last resort: use current working directory if it contains .setup
        if [[ -d "$CURRENT_DIR/.setup" ]]; then
            PROJECT_ROOT="$CURRENT_DIR"
        else
            log_error "Cannot find .setup directory. Please run this script from the project root or ensure .setup directory exists."
            log_info "Current directory: $CURRENT_DIR"
            log_info "Script location: $SCRIPT_DIR"
            exit 1
        fi
    fi
fi

SETUP_DIR="$PROJECT_ROOT/.setup"
ENV_CONFIG_FILE="$SETUP_DIR/.env.config"

log_info "=== Production User Setup Process ==="
log_info "Script location: $SCRIPT_DIR"
log_info "Project directory: $PROJECT_ROOT"
log_info "Setup directory: $SETUP_DIR"
log_info "Config file: $ENV_CONFIG_FILE"

# Check root permissions
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run with sudo"
   log_info "Usage: sudo ./.setup/scripts/02-setup-user.sh"
   exit 1
fi

# Check if configuration file exists
if [[ ! -f "$ENV_CONFIG_FILE" ]]; then
    log_error "Configuration file $ENV_CONFIG_FILE does not exist"
    log_info "Please copy .env.config.example to .env.config and configure it"
    exit 1
fi

# Load environment variables
log_info "Loading configuration from $ENV_CONFIG_FILE"
source "$ENV_CONFIG_FILE"

# Check that user variables are defined
if [[ -z "$PROD_USERNAME" || -z "$PROD_PASSWORD" ]]; then
    log_error "Production user variables are not configured in .env.config"
    log_error "Missing variables: PROD_USERNAME or PROD_PASSWORD"
    exit 1
fi

# Compose home directory automatically
# We automatically use /home/USERNAME instead of requiring PROD_USER_HOME variable
PROD_USER_HOME="/home/$PROD_USERNAME"

log_info "Production user configuration:"
log_info "  Username: $PROD_USERNAME"
log_info "  Home directory: $PROD_USER_HOME"
log_info "  Password: [CONFIGURED]"

# Check if user already exists
if id "$PROD_USERNAME" &>/dev/null; then
    log_info "User $PROD_USERNAME already exists"
    EXISTING_USER=true
else
    log_info "Creating new user: $PROD_USERNAME"
    EXISTING_USER=false
fi

# Create user if it doesn't exist
if [[ "$EXISTING_USER" == "false" ]]; then
    log_info "Creating user $PROD_USERNAME..."
    
    # Create user with home directory
    useradd -m -d "$PROD_USER_HOME" -s /bin/bash "$PROD_USERNAME"
    
    # Set password
    echo "$PROD_USERNAME:$PROD_PASSWORD" | chpasswd
    
    log_success "User $PROD_USERNAME created successfully"
else
    log_info "Updating existing user configuration..."
    
    # Update password
    echo "$PROD_USERNAME:$PROD_PASSWORD" | chpasswd
    log_success "User password updated"
fi

# Add user to required groups
log_info "Adding user to required groups..."

# Add to sudo group
if groups "$PROD_USERNAME" | grep -q "\bsudo\b"; then
    log_info "User already in sudo group"
else
    usermod -aG sudo "$PROD_USERNAME"
    log_success "User added to sudo group"
fi

# Add to docker group (if docker is installed)
if command -v docker &> /dev/null; then
    if groups "$PROD_USERNAME" | grep -q "\bdocker\b"; then
        log_info "User already in docker group"
    else
        usermod -aG docker "$PROD_USERNAME"
        log_success "User added to docker group"
    fi
else
    log_warning "Docker not installed, skipping docker group"
fi

# Determine project name (directory name)
PROJECT_NAME=$(basename "$PROJECT_ROOT")
NEW_PROJECT_PATH="$PROD_USER_HOME/$PROJECT_NAME"

log_info "Project relocation:"
log_info "  Current path: $PROJECT_ROOT"
log_info "  New path: $NEW_PROJECT_PATH"

# Check if we need to move the project
if [[ "$PROJECT_ROOT" == "$NEW_PROJECT_PATH" ]]; then
    log_info "Project is already in the correct location"
    MOVE_NEEDED=false
else
    log_info "Project needs to be relocated"
    MOVE_NEEDED=true
fi

# Move project if needed
if [[ "$MOVE_NEEDED" == "true" ]]; then
    log_info "Moving project to user home directory..."
    
    # Create backup if destination exists
    if [[ -d "$NEW_PROJECT_PATH" ]]; then
        log_warning "Destination directory exists, creating backup..."
        mv "$NEW_PROJECT_PATH" "${NEW_PROJECT_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backup created"
    fi
    
    # Ensure parent directory exists
    mkdir -p "$(dirname "$NEW_PROJECT_PATH")"
    
    # Move project
    mv "$PROJECT_ROOT" "$NEW_PROJECT_PATH"
    log_success "Project moved to $NEW_PROJECT_PATH"
    
    # Update PROJECT_ROOT for subsequent operations
    PROJECT_ROOT="$NEW_PROJECT_PATH"
fi

# Set ownership and permissions
log_info "Setting ownership and permissions..."

# Change ownership to production user
chown -R "$PROD_USERNAME:$PROD_USERNAME" "$NEW_PROJECT_PATH"
log_success "Ownership set to $PROD_USERNAME"

# Set appropriate permissions
find "$NEW_PROJECT_PATH" -type f -name "*.sh" -exec chmod +x {} \;
chmod 755 "$NEW_PROJECT_PATH"
log_success "Permissions set correctly"

# Create necessary directories with correct ownership
log_info "Creating additional directories..."

# Logs directory
mkdir -p "$NEW_PROJECT_PATH/logs"
chown "$PROD_USERNAME:$PROD_USERNAME" "$NEW_PROJECT_PATH/logs"

# Nginx directory (if it exists)
if [[ -d "$NEW_PROJECT_PATH/nginx" ]]; then
    chown -R "$PROD_USERNAME:$PROD_USERNAME" "$NEW_PROJECT_PATH/nginx"
fi

log_success "Additional directories configured"

# Configure sudo access for the user (if not already configured)
SUDOERS_FILE="/etc/sudoers.d/$PROD_USERNAME"
if [[ ! -f "$SUDOERS_FILE" ]]; then
    log_info "Configuring sudo access..."
    echo "$PROD_USERNAME ALL=(ALL) NOPASSWD: /usr/bin/systemctl, /usr/bin/nginx, /usr/bin/certbot, /usr/bin/ufw" > "$SUDOERS_FILE"
    chmod 440 "$SUDOERS_FILE"
    log_success "Sudo access configured for specific commands"
fi

# Create a simple login script for the user
USER_PROFILE="$PROD_USER_HOME/.profile_project"
cat > "$USER_PROFILE" << EOF
#!/bin/bash
# Project environment setup

# Navigate to project directory
cd "$NEW_PROJECT_PATH"

# Display project status
echo "==============================================="
echo "Welcome to $PROJECT_NAME production environment"
echo "==============================================="
echo "Project location: $NEW_PROJECT_PATH"
echo ""
echo "Available commands:"
echo "  make setup           - Initial project setup (if not done)"
echo "  make build           - Build and start with PM2"
echo "  make deploy          - Deploy with Nginx/HTTPS"
echo "  make prod            - Full production workflow"
echo ""
echo "Or use individual scripts:"
echo "  ./.setup/scripts/01-setup.sh   - Project setup"
echo "  ./.setup/scripts/03-build.sh   - Build and PM2"
echo "  ./.setup/scripts/04-deploy.sh  - Nginx deployment"
echo ""
EOF

chown "$PROD_USERNAME:$PROD_USERNAME" "$USER_PROFILE"
chmod +x "$USER_PROFILE"

# Add to .bashrc if not already present
if ! grep -q "source.*\.profile_project" "$PROD_USER_HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$PROD_USER_HOME/.bashrc"
    echo "# Project environment" >> "$PROD_USER_HOME/.bashrc"
    echo "source ~/.profile_project" >> "$PROD_USER_HOME/.bashrc"
    chown "$PROD_USERNAME:$PROD_USERNAME" "$PROD_USER_HOME/.bashrc"
fi

log_success "User profile configured"

# Display final information
echo ""
log_success "=== User setup completed successfully ==="
echo ""
log_info "Production environment configured:"
log_info "  ✓ User: $PROD_USERNAME"
log_info "  ✓ Home: $PROD_USER_HOME"
log_info "  ✓ Project: $NEW_PROJECT_PATH"
log_info "  ✓ Groups: sudo, docker (if available)"
log_info "  ✓ Permissions: configured"
echo ""
log_info "To switch to the production user:"
log_info "  su - $PROD_USERNAME"
echo ""
log_info "The user will automatically be in the project directory"
log_info "and have access to all project scripts."
echo ""

# Initialize sudo session for the production user to avoid password prompts
log_info "Initializing sudo session for user $PROD_USERNAME..."
if sudo -u "$PROD_USERNAME" sudo -n true 2>/dev/null; then
    log_success "Sudo session already active for $PROD_USERNAME"
else
    log_info "Activating sudo session for $PROD_USERNAME..."
    # Use the production user password to initialize sudo session (silent)
    if echo "$PROD_PASSWORD" | sudo -u "$PROD_USERNAME" -S sudo -v 2>/dev/null; then
        log_success "Sudo session initialized for $PROD_USERNAME"
    else
        # Try alternative method with timeout
        if timeout 10 bash -c "echo '$PROD_PASSWORD' | sudo -u '$PROD_USERNAME' -S sudo -v" 2>/dev/null; then
            log_success "Sudo session initialized for $PROD_USERNAME"
        else
            log_warning "Could not initialize sudo session automatically. User may need to enter password later."
        fi
    fi
fi

# If project was moved, automatically switch to the new location
if [[ "$MOVE_NEEDED" == "true" ]]; then
    echo ""
    log_info "=== Project has been relocated ==="
    log_info "Project moved to: $NEW_PROJECT_PATH"
    log_info "Automatically switching to the new location..."
    echo ""
    
    # Verify the new directory exists and is accessible
    if [[ ! -d "$NEW_PROJECT_PATH" ]]; then
        log_error "New project directory does not exist: $NEW_PROJECT_PATH"
        exit 1
    fi
    
    # Change to the new project directory
    if cd "$NEW_PROJECT_PATH"; then
        log_success "Successfully switched to relocated project directory"
        log_info "Current directory: $(pwd)"
    else
        log_error "Failed to change to new project directory"
        exit 1
    fi
    
    log_info "Sudo session is initialized - no password required for next steps!"
    echo ""
    log_info "You can now continue with:"
    log_info "  make build    # Build and start with PM2"
    log_info "  make deploy   # Deploy with Nginx/HTTPS"
    log_info "  make build && make deploy   # Or both together"
    echo ""
    
    # Start a new shell in the correct directory to maintain the working directory
    log_info "Starting new shell session in the project directory..."
    exec $SHELL
else
    log_info "Project was not moved. You can continue with the workflow normally."
    log_success "Sudo session is initialized for $PROD_USERNAME - no password required!"
fi