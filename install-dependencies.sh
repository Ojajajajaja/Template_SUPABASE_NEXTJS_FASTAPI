#!/bin/bash

# =============================================================================
# Dependencies Installation Script
# =============================================================================
# This script installs all system dependencies required by the template
# Should be run BEFORE setup.sh, build.sh, or deploy.sh
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Check if running as root for system installations
check_sudo() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root directly."
        log_info "It will use sudo when needed for specific installations."
        exit 1
    fi

    if ! sudo -n true 2>/dev/null; then
        log_info "This script requires sudo privileges for system installations."
        log_info "You may be prompted for your password."
    fi
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/debian_version ]]; then
            OS="debian"
            log_info "Detected Debian/Ubuntu system"
        elif [[ -f /etc/redhat-release ]]; then
            OS="redhat"
            log_info "Detected RedHat/CentOS/Fedora system"
        else
            OS="linux"
            log_info "Detected generic Linux system"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_info "Detected macOS system"
    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Install system packages
install_system_packages() {
    log_info "Installing system packages..."
    
    case $OS in
        "debian")
            sudo apt-get update
            sudo apt-get install -y curl wget git build-essential software-properties-common apt-transport-https ca-certificates gnupg lsb-release
            ;;
        "redhat")
            sudo yum update -y
            sudo yum groupinstall -y "Development Tools"
            sudo yum install -y curl wget git
            ;;
        "macos")
            # Check if Homebrew is installed
            if ! command -v brew &> /dev/null; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew update
            ;;
    esac
    
    log_success "System packages installed"
}

# Install Node.js
install_nodejs() {
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        log_info "Node.js already installed: $NODE_VERSION"
        return
    fi

    log_info "Installing Node.js..."
    
    case $OS in
        "debian")
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        "redhat")
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
            sudo yum install -y nodejs
            ;;
        "macos")
            brew install node
            ;;
    esac
    
    log_success "Node.js installed: $(node --version)"
}

# Install Python 3
install_python() {
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version)
        log_info "Python 3 already installed: $PYTHON_VERSION"
    else
        log_info "Installing Python 3..."
        
        case $OS in
            "debian")
                sudo apt-get install -y python3 python3-pip python3-venv
                ;;
            "redhat")
                sudo yum install -y python3 python3-pip
                ;;
            "macos")
                brew install python@3.11
                ;;
        esac
        
        log_success "Python 3 installed: $(python3 --version)"
    fi
}

# Install UV (Python package manager)
install_uv() {
    log_info "Installing UV (Python package manager)..."
    
    # Install UV to home directory first
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Move UV to global location for system-wide access
    if [[ -f "$HOME/.cargo/bin/uv" ]]; then
        sudo cp "$HOME/.cargo/bin/uv" /usr/local/bin/uv
        sudo chmod +x /usr/local/bin/uv
        log_success "UV installed globally at /usr/local/bin/uv"
    else
        log_error "UV installation failed"
        exit 1
    fi
    
    # Verify installation
    UV_VERSION=$(/usr/local/bin/uv --version)
    log_success "UV installed: $UV_VERSION"
}

# Install Docker
install_docker() {
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version)
        log_info "Docker already installed: $DOCKER_VERSION"
    else
        log_info "Installing Docker..."
        
        case $OS in
            "debian")
                # Add Docker's official GPG key
                sudo mkdir -p /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                
                # Add the repository
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                
                sudo apt-get update
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            "redhat")
                sudo yum install -y yum-utils
                sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            "macos")
                log_info "Please install Docker Desktop manually from https://www.docker.com/products/docker-desktop"
                return
                ;;
        esac
        
        # Start and enable Docker service
        if [[ "$OS" != "macos" ]]; then
            sudo systemctl start docker
            sudo systemctl enable docker
        fi
        
        log_success "Docker installed: $(docker --version)"
    fi
    
    # Add current user to docker group (Linux only)
    if [[ "$OS" != "macos" ]]; then
        sudo usermod -aG docker $USER
        log_info "Added $USER to docker group. You may need to log out and back in."
    fi
}

# Install Nginx
install_nginx() {
    if command -v nginx &> /dev/null; then
        NGINX_VERSION=$(nginx -v 2>&1)
        log_info "Nginx already installed: $NGINX_VERSION"
        return
    fi

    log_info "Installing Nginx..."
    
    case $OS in
        "debian")
            sudo apt-get install -y nginx
            ;;
        "redhat")
            sudo yum install -y nginx
            ;;
        "macos")
            brew install nginx
            ;;
    esac
    
    # Start and enable Nginx service
    if [[ "$OS" != "macos" ]]; then
        sudo systemctl start nginx
        sudo systemctl enable nginx
    else
        sudo brew services start nginx
    fi
    
    log_success "Nginx installed and started"
}

# Install Certbot for SSL certificates
install_certbot() {
    if command -v certbot &> /dev/null; then
        log_info "Certbot already installed"
        return
    fi

    log_info "Installing Certbot for SSL certificates..."
    
    case $OS in
        "debian")
            sudo apt-get install -y certbot python3-certbot-nginx
            ;;
        "redhat")
            sudo yum install -y certbot python3-certbot-nginx
            ;;
        "macos")
            brew install certbot
            ;;
    esac
    
    log_success "Certbot installed"
}

# Install PM2 (Node.js process manager)
install_pm2() {
    if command -v pm2 &> /dev/null; then
        PM2_VERSION=$(pm2 --version)
        log_info "PM2 already installed: $PM2_VERSION"
        return
    fi

    log_info "Installing PM2 globally..."
    sudo npm install -g pm2
    log_success "PM2 installed: $(pm2 --version)"
}

# Create necessary directories
create_directories() {
    log_info "Creating necessary directories..."
    
    # Create logs directory
    sudo mkdir -p /var/log/template-app
    sudo chown $USER:$USER /var/log/template-app
    
    # Create application directory
    sudo mkdir -p /opt/template-app
    sudo chown $USER:$USER /opt/template-app
    
    log_success "Directories created"
}

# Configure firewall (Linux only)
configure_firewall() {
    if [[ "$OS" == "macos" ]]; then
        return
    fi

    log_info "Configuring firewall..."
    
    case $OS in
        "debian")
            if command -v ufw &> /dev/null; then
                sudo ufw allow 22/tcp    # SSH
                sudo ufw allow 80/tcp    # HTTP
                sudo ufw allow 443/tcp   # HTTPS
                sudo ufw allow 3000/tcp  # Frontend dev
                sudo ufw allow 8000/tcp  # Backend dev
                log_success "UFW firewall configured"
            fi
            ;;
        "redhat")
            if command -v firewall-cmd &> /dev/null; then
                sudo firewall-cmd --permanent --add-service=ssh
                sudo firewall-cmd --permanent --add-service=http
                sudo firewall-cmd --permanent --add-service=https
                sudo firewall-cmd --permanent --add-port=3000/tcp
                sudo firewall-cmd --permanent --add-port=8000/tcp
                sudo firewall-cmd --reload
                log_success "Firewalld configured"
            fi
            ;;
    esac
}

# Verify installations
verify_installations() {
    log_info "Verifying installations..."
    
    FAILED=()
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        FAILED+=("Node.js")
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        FAILED+=("Python 3")
    fi
    
    # Check UV
    if ! command -v uv &> /dev/null; then
        FAILED+=("UV")
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        FAILED+=("Docker")
    fi
    
    # Check Nginx
    if ! command -v nginx &> /dev/null; then
        FAILED+=("Nginx")
    fi
    
    # Check PM2
    if ! command -v pm2 &> /dev/null; then
        FAILED+=("PM2")
    fi
    
    if [[ ${#FAILED[@]} -eq 0 ]]; then
        log_success "All dependencies installed successfully!"
    else
        log_error "Failed to install: ${FAILED[*]}"
        exit 1
    fi
}

# Main execution
main() {
    echo "============================================="
    echo "   Template Dependencies Installation"
    echo "============================================="
    echo ""
    
    check_sudo
    detect_os
    
    log_info "Starting dependencies installation..."
    
    install_system_packages
    install_nodejs
    install_python
    install_uv
    install_docker
    install_nginx
    install_certbot
    install_pm2
    create_directories
    configure_firewall
    
    verify_installations
    
    echo ""
    log_success "Dependencies installation completed!"
    echo ""
    log_info "Next steps:"
    echo "  1. Log out and back in (for Docker group membership)"
    echo "  2. Run: make setup (or ./setup.sh)"
    echo "  3. Run: make build (or ./build.sh)"
    echo "  4. Run: make deploy (or ./deploy.sh)"
    echo ""
    log_info "Or simply run: make prod (for full production setup)"
}

# Run main function
main "$@"