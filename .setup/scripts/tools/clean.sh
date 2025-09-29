#!/bin/bash

# =============================================================================
# Clean Script - Template SUPABASE NEXTJS FASTAPI
# =============================================================================
# This script removes all files and folders generated during development
# to reset the project to a clean state.
# =============================================================================

set -e  # Stop script on error

# Colors for display
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Color display functions
print_step() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to safely remove a file/directory if it exists
safe_remove() {
    local path="$1"
    local description="$2"
    
    if [ -e "$path" ]; then
        print_step "Removing $description..."
        rm -rf "$path"
        print_success "$description removed"
    else
        print_warning "$description does not exist"
    fi
}

# =============================================================================
# START CLEANING
# =============================================================================

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                PROJECT CLEANUP                               ║${NC}"
echo -e "${BLUE}║          Template SUPABASE NEXTJS FASTAPI                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

# Check root directory
if [ ! -f "Makefile" ] || [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    print_error "This script must be run from the root of the Template SUPABASE NEXTJS FASTAPI project"
    exit 1
fi

print_step "Cleanup in progress..."
echo

# =============================================================================
# BACKEND - Python/UV dependencies cleanup
# =============================================================================

print_step "🐍 Backend Cleanup (Python/UV)..."

# UV virtual environment
safe_remove ".venv" "Python virtual environment (.venv)"

# Python cache
safe_remove "backend/__pycache__" "backend Python cache"
safe_remove "backend/api/__pycache__" "API Python cache"
safe_remove "backend/api/models/__pycache__" "models Python cache"
safe_remove "backend/api/views/__pycache__" "views Python cache"
safe_remove "backend/api/helpers/__pycache__" "helpers Python cache"
safe_remove "backend/api/schemas/__pycache__" "schemas Python cache"

# .pyc and .pyo files recursively
print_step "Removing .pyc and .pyo files..."
find . -name "*.pyc" -delete 2>/dev/null || true
find . -name "*.pyo" -delete 2>/dev/null || true
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

# UV lock file (can be regenerated)
safe_remove "uv.lock" "UV lock file"

# =============================================================================
# FRONTEND - Node.js/npm dependencies cleanup
# =============================================================================

print_step "📦 Frontend Cleanup (Node.js/npm)..."

# Node.js dependencies
safe_remove "frontend/node_modules" "Node.js dependencies"

# Lock files
safe_remove "frontend/package-lock.json" "npm lock file"

# Next.js build
safe_remove "frontend/.next" "Next.js build"

# Next.js cache
safe_remove "frontend/.next/cache" "Next.js cache"

# TypeScript build info
safe_remove "frontend/tsconfig.tsbuildinfo" "TypeScript build info"

# =============================================================================
# SUPABASE - Local configuration cleanup
# =============================================================================

print_step "🗄️  Supabase Cleanup..."

if [ -d "supabase" ]; then
    print_warning "The supabase/ directory exists."
    echo
    echo -e "${YELLOW}This directory contains your local Supabase configuration.${NC}"
    echo -e "${YELLOW}If Docker containers are running, they will be stopped first.${NC}"
    echo
    read -p "Do you want to delete the supabase/ directory? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Stopping Docker containers..."
        if cd supabase/ 2>/dev/null; then
            if docker compose down 2>/dev/null; then
                print_success "Docker containers stopped"
            else
                print_warning "No Docker containers to stop or docker compose not available"
            fi
            cd ..
        else
            print_warning "Cannot access supabase/ directory"
        fi
        
        safe_remove "supabase" "local Supabase configuration"
        print_warning "⚠️  Supabase directory has been deleted. You will need to run 'supabase init' to recreate it."
    else
        print_success "✅ supabase/ directory preserved"
    fi
else
    print_warning "supabase/ directory does not exist"
fi

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================

print_step "🔐 Environment variables cleanup..."

# Backend .env files
safe_remove "backend/.env" "backend environment variables (.env)"
safe_remove "backend/.env.local" "backend environment variables (.env.local)"
safe_remove "backend/.env.development" "backend environment variables (.env.development)"
safe_remove "backend/.env.production" "backend environment variables (.env.production)"

# Frontend .env files
safe_remove "frontend/.env" "frontend environment variables (.env)"
safe_remove "frontend/.env.local" "frontend environment variables (.env.local)"
safe_remove "frontend/.env.development" "frontend environment variables (.env.development)"
safe_remove "frontend/.env.production" "frontend environment variables (.env.production)"

# =============================================================================
# OTHER TEMPORARY FILES
# =============================================================================

print_step "🧹 Temporary files cleanup..."

# Logs
safe_remove "*.log" "log files"
safe_remove "backend/*.log" "backend logs"
safe_remove "frontend/*.log" "frontend logs"

# System temporary files
safe_remove ".DS_Store" "macOS system files"
find . -name ".DS_Store" -delete 2>/dev/null || true

# Editor files
safe_remove ".vscode/settings.json" "specific VS Code settings"
safe_remove ".vscode/.ropeproject" "Rope project"

# =============================================================================
# FINAL QUESTION - .env.config
# =============================================================================

echo
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║                    FINAL QUESTION                           ║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

if [ -f ".setup/.env.config" ]; then
    print_warning "The .env.config file exists in .setup/ directory."
    echo
    echo -e "${YELLOW}This file potentially contains important configurations.${NC}"
    echo -e "${YELLOW}It is generally NOT deleted during cleanup.${NC}"
    echo
    read -p "Do you want to delete .setup/.env.config? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        safe_remove ".setup/.env.config" "environment configuration file (.setup/.env.config)"
        print_warning "⚠️  .setup/.env.config has been deleted. You will need to recreate it if necessary."
    else
        print_success "✅ .setup/.env.config preserved"
    fi
else
    print_warning ".setup/.env.config does not exist"
fi

# =============================================================================
# FINAL SUMMARY
# =============================================================================

echo
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  CLEANUP COMPLETED                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

print_success "🎉 Project cleanup completed successfully!"