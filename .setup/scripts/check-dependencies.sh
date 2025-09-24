#!/bin/bash

# =============================================================================
# Dependencies Check Script
# =============================================================================
# Quick check to see which dependencies are installed/missing
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "============================================="
echo "   Dependencies Status Check"
echo "============================================="
echo ""

check_command() {
    local cmd="$1"
    local name="$2"
    local global_path="$3"
    
    if command -v "$cmd" &> /dev/null; then
        local version_cmd="$4"
        if [[ -n "$version_cmd" ]]; then
            local version=$($version_cmd 2>/dev/null || echo "unknown")
            echo -e "${GREEN}✓${NC} $name: $version"
        else
            echo -e "${GREEN}✓${NC} $name: installed"
        fi
        
        # Check if it's in the expected global location
        if [[ -n "$global_path" ]]; then
            local actual_path=$(which "$cmd")
            if [[ "$actual_path" == "$global_path" ]]; then
                echo -e "  ${BLUE}→${NC} Located at: $actual_path (correct)"
            else
                echo -e "  ${YELLOW}→${NC} Located at: $actual_path (expected: $global_path)"
            fi
        fi
    else
        echo -e "${RED}✗${NC} $name: not installed"
    fi
}

echo "System Dependencies:"
echo "===================="
check_command "node" "Node.js" "" "node --version"
check_command "npm" "npm" "" "npm --version"
check_command "python3" "Python 3" "" "python3 --version"
check_command "uv" "UV (Python manager)" "/usr/local/bin/uv" "uv --version"
check_command "docker" "Docker" "" "docker --version"
check_command "nginx" "Nginx" "" "nginx -v 2>&1"
check_command "certbot" "Certbot" "" "certbot --version"
check_command "pm2" "PM2" "" "pm2 --version"

echo ""
echo "System Services:"
echo "================"

# Check Docker service (Linux only)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if systemctl is-active --quiet docker; then
        echo -e "${GREEN}✓${NC} Docker service: running"
    else
        echo -e "${RED}✗${NC} Docker service: not running"
    fi
    
    if systemctl is-active --quiet nginx; then
        echo -e "${GREEN}✓${NC} Nginx service: running"
    else
        echo -e "${YELLOW}!${NC} Nginx service: not running (normal if not started yet)"
    fi
fi

echo ""
echo "Project Structure:"
echo "=================="
check_structure() {
    local path="$1"
    local name="$2"
    
    if [[ -e "$path" ]]; then
        echo -e "${GREEN}✓${NC} $name: present"
    else
        echo -e "${RED}✗${NC} $name: missing"
    fi
}

check_structure "frontend/" "Frontend directory"
check_structure "backend/" "Backend directory"
check_structure "supabase/" "Supabase directory"
check_structure ".setup/" "Setup directory"
check_structure ".setup/.env.config" "Configuration file"

echo ""
echo "Permissions:"
echo "============"

# Check if user is in docker group (Linux only)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if groups $USER | grep -q docker; then
        echo -e "${GREEN}✓${NC} User in docker group"
    else
        echo -e "${YELLOW}!${NC} User not in docker group (may need to log out/in)"
    fi
fi

# Check if important directories are writable
if [[ -w "/usr/local/bin" ]]; then
    echo -e "${GREEN}✓${NC} Can write to /usr/local/bin"
else
    echo -e "${YELLOW}!${NC} Cannot write to /usr/local/bin (may need sudo)"
fi

echo ""
echo "Summary:"
echo "========"

# Count missing dependencies
missing_count=0
critical_deps=("node" "python3" "uv" "docker" "nginx" "pm2")

for dep in "${critical_deps[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        ((missing_count++))
    fi
done

if [[ $missing_count -eq 0 ]]; then
    echo -e "${GREEN}✓ All critical dependencies are installed!${NC}"
    echo -e "You can proceed with: ${BLUE}make dev${NC} or ${BLUE}make prod${NC}"
else
    echo -e "${RED}✗ $missing_count dependencies missing${NC}"
    echo -e "Please run: ${BLUE}make install-deps${NC}"
fi

echo ""