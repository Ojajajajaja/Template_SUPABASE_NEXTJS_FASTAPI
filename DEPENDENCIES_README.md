# Dependencies Installation Guide

## Overview

This guide explains the correct order for setting up the Template SUPABASE NEXTJS FASTAPI project.

## Installation Order

### 1. Install System Dependencies (FIRST)

```bash
# Install all system dependencies
make install-deps
# OR
./install-dependencies.sh
```

**What this installs:**
- Node.js & npm
- Python 3 & pip
- UV (Python package manager) → moved to `/usr/local/bin/uv`
- Docker & Docker Compose
- Nginx
- Certbot (for SSL certificates)
- PM2 (Node.js process manager)
- System packages and build tools

**Important:** After installation, you may need to log out and back in for Docker group membership to take effect.

### 2. Development Setup

```bash
# For development environment
make dev
# OR
./setup.sh
```

### 3. Production Deployment

```bash
# Full production deployment (includes dependency check)
make prod
# OR manually:
make setup
make build
make deploy
```

## Dependency Management

### Global vs Local Installations

The `install-dependencies.sh` script ensures proper global installation:

- **UV**: Installed to `/usr/local/bin/uv` for system-wide access
- **PM2**: Installed globally via npm
- **Nginx**: Installed as system service
- **Docker**: Configured with proper user permissions

### Why This Approach?

1. **Centralized Dependencies**: All system dependencies in one place
2. **Proper Permissions**: Ensures tools are accessible by all users
3. **Path Management**: Moves tools from user directories to system paths
4. **Dependency Verification**: Checks all requirements before running scripts

## Makefile Commands

### Essential Commands

```bash
make install-deps    # Install system dependencies (run first)
make dev            # Development setup
make prod           # Full production deployment
```

### Individual Commands

```bash
make setup          # Project setup only
make build          # Build with PM2 only
make deploy         # Deploy with Nginx only
```

### Service Management

#### Development
```bash
make frontend-start-dev     # Start Next.js dev server
make backend-start-dev      # Start FastAPI dev server
make supabase-start         # Start Supabase with Docker
```

#### Production
```bash
make frontend-start-prod    # Start frontend with PM2
make backend-start-prod     # Start backend with PM2
```

### Utilities

```bash
make status         # Show all service status
make logs          # Show application logs
make info          # Show environment information
make clean         # Stop all services and cleanup
```

## Troubleshooting

### Dependencies Not Found

If you get errors like "UV not found" or "Nginx not found":

```bash
# Run the dependency installer
make install-deps
```

### Permission Issues

If you encounter permission issues with Docker:

```bash
# Log out and back in after running install-deps
# Or manually add yourself to docker group:
sudo usermod -aG docker $USER
```

### Global Tool Access

If tools aren't accessible globally:

```bash
# Check if UV is in the right location
which uv
# Should return: /usr/local/bin/uv

# Check PATH
echo $PATH
```

## Dependencies Verification

The system automatically checks dependencies before production deployment:

- ✅ UV (Python package manager)
- ✅ Nginx (Web server)
- ✅ Docker (Containerization)
- ✅ PM2 (Process manager)
- ✅ Node.js & Python

## OS Support

The installation script supports:

- **Ubuntu/Debian** (apt-get)
- **CentOS/RHEL/Fedora** (yum)
- **macOS** (Homebrew)

## Next Steps

After running `make install-deps`:

1. **Log out and back in** (for Docker permissions)
2. **Run `make dev`** for development
3. **Run `make prod`** for production
4. **Check status** with `make status`

## Changements dans les Scripts

Les scripts existants ont été modifiés pour ne plus installer les dépendances :

### Scripts de Build
- **02-setup-pm2.sh** : Vérifie que PM2 est installé au lieu de l'installer
- **01-build-frontend.sh** : Assume que Node.js/npm sont déjà installés

### Scripts de Déploiement  
- **02-install-nginx.sh** : Vérifie que Nginx/Certbot sont installés au lieu de les installer
- **03-setup-https.sh** : Assume que Certbot est déjà installé

### Scripts de Setup
- **01-check-dependencies.sh** : Vérifie les dépendances et guide vers `make install-deps`

## File Structure

```
Template_SUPABASE_NEXTJS_FASTAPI/
├── install-dependencies.sh    # System dependencies installer
├── setup.sh                   # Project setup
├── build.sh                   # Build with PM2
├── deploy.sh                  # Deploy with Nginx
├── Makefile                   # Orchestration commands
└── .setup/                    # Configuration files
```