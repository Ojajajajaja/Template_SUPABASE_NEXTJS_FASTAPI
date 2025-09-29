# 🚀 Full-Stack Template - Supabase, Next.js & FastAPI

> Production-ready template for rapidly developing modern web applications

![Tech Stack](https://img.shields.io/badge/Next.js-14-black?style=for-the-badge&logo=next.js)
![FastAPI](https://img.shields.io/badge/FastAPI-0.104-009688?style=for-the-badge&logo=fastapi)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase)
![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python)

## 📖 Description

This template provides a complete foundation for developing modern full-stack applications with:

### 🎨 **Frontend**
- **React** + **Next.js 14** (App Router)
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **Shadcn/UI** for components
- Responsive and accessible interface

### ⚡ **Backend** 
- **FastAPI** with Python 3.12+
- **UV** for dependency management
- **Gunicorn** for production
- Automatically documented REST API via Swagger UI

### 🗄️ **Database**
- **Supabase** (PostgreSQL + Auth + Storage)
- Self-hosted with Docker
- OAuth Authentication (Google)

## 🏗️ Project Architecture

```
.
├── backend/                 # FastAPI API
│   ├── api/                 # API code
│   │   ├── models/          # Pydantic models
│   │   ├── views/           # Routes and logic
│   │   ├── helpers/         # Utilities and services
│   │   └── schemas/         # Database schemas
│   ├── tests/               # Backend tests
│   └── run.py               # Startup script
├── frontend/                # Next.js Application
│   ├── src/app/             # Pages (App Router)
│   ├── src/components/      # Reusable components
│   ├── src/lib/             # Utilities and contexts
│   ├── src/services/        # API services
│   └── src/types/           # TypeScript types
├── .setup/                  # Installation scripts
│   ├── scripts/             # Automation scripts
│   ├── nginx/               # Nginx configuration
│   └── .env.config.example  # Example configuration
└── Makefile                 # Simplified commands
```

## 🚀 Quick Installation

### 📋 Prerequisites
- **Docker** and **Docker Compose**
- **Node.js** 18+ and **npm**
- **Python** 3.12+ and **UV**
- **Make** (for simplified commands)

### 💻 Development Environment

1. **Basic setup**
   ```bash
   # Create .env.config with your settings
   cp .setup/.env.config.example .setup/.env.config
   
   # Install dependencies
   make deps
   ```

2. **Start dev environment**
   ```bash
   make dev
   ```

This command will:
- ✅ Install Supabase locally
- ✅ Setup backend & frontend
- ✅ Create .env files for development following .env.config (also generating securized keys needed by supabase)
- ✅ Remove .git to allow your own repo

3. **Start services**
   ```bash
   # Backend (FastAPI)
   cd backend && uv run run.py dev
   
   # Frontend (Next.js) - new terminal
   cd frontend && npm run dev
   # Before trying to bring your stuff in production mode, always try to build
   cd frontend && npm run build
   
   # Database & Auth (Supabase)
   make supabase-start    # Start Supabase (already started at the end of the dev command)
   ```

### 🛠️ New VPS Installation

1. **First VPS installation**
   ```bash
   # Clone the template
   git clone YOUR_PROJECT_REPO my-project
   cd my-project


   # DNS configuration for your domain required before this step
   chmod +x hello-vps.sh
   ./hello-vps.sh
   nano .setup/.env.config
   make user
   make prod
   ```

These command will automatically:
- ✅ Install Supabase locally
- ✅ Setup backend & frontend 
- ✅ Create .env files for all 3 services following .env.config (also generating securized keys needed by supabase)
- ✅ Build and start with PM2 (multi-instance, auto-restart)
- ✅ Configure Nginx and SSL automatically
- ✅ Go live with demo interface

## 🎯 Available Commands

### 🔧 **Main Make Commands**

| Command | Description |
|---------|-------------|
| `make deps` | Install system dependencies |
| `make user` | Setup production user |
| `make dev` | Setup development environment |
| `make prod` | Complete production deployment |
| `make init` | Complete installation (deps + user) |

### 🐳 **Supabase Management**

| Command | Description |
|---------|-------------|
| `make supabase-start` | Start Supabase services |
| `make supabase-stop` | Stop Supabase services |
| `make supabase-restart` | Restart Supabase services |

### 🌐 **Production Management (PM2)**

| Command | Description |
|---------|-------------|
| `make frontend-start` | Start frontend with PM2 |
| `make frontend-stop` | Stop frontend PM2 |
| `make backend-start` | Start backend production |
| `make backend-stop` | Stop backend production |
| `make logs-frontend` | View frontend logs |
| `make logs-backend` | View backend logs |

## 🌍 Default URLs

### 🔧 **Development**
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:2000
- **Supabase**: http://localhost:8000
- **API Documentation**: http://localhost:2000/docs

## ⚙️ Configuration

### 📝 **.env.config File**

The `.setup/.env.config` file contains all configuration:

```bash
# Project Config
API_PREFIX=/api/v1
API_PORT=2000
FRONTEND_PORT=3000
PROJECT_NAME="Oja Template"
USERNAME_SUPABASE="oja"
PASSWORD_SUPABASE="ojasupabase"
PASSWORD_POSTGRES="ojapostgres"

# If you want multiple simultaneous Supabase databases on the same machine, complete this variable with a first port (4 numbers) and it will fill automatically the 6 other in the continuity, for example :
# SUPABASE_PORT_RANGE=8000
# Ports become :
# KONG_HTTP_PORT=8000
# KONG_HTTPS_PORT=8001
# POSTGRES_PORT=8002
# POOLER_PROXY_PORT_TRANSACTION=8003
# STUDIO_PORT=8004
# ANALYTICS_HOST_PORT=8005
SUPABASE_PORT_RANGE=

# Or manually change them
POSTGRES_PORT=5432
POOLER_PROXY_PORT_TRANSACTION=6543
KONG_HTTP_PORT=8000
KONG_HTTPS_PORT=8443
STUDIO_PORT=3000
ANALYTICS_HOST_PORT=4000

# To avoid confirmation mail on user signup (saving time in dev mode, setup it right in production)
ENABLE_EMAIL_AUTOCONFIRM=true

# OAuth Configuration
# Leave empty to disable OAuth providers
GOOGLE_CLIENT_ID=

# Production Config
# Domain
# Don't forget to add your domain in your DNS configuration
FRONTEND_DOMAIN="example.com"
BACKEND_DOMAIN="api.example.com"
SUPABASE_DOMAIN="supabase.example.com"

# User Configuration
# To avoid using root user for production
PROD_USERNAME="appuser"
PROD_PASSWORD="SecurePassword123!"
```

### 🔐 **Environment Variables**

The `.env` files are generated automatically:
- `backend/.env` - Backend variables
- `frontend/.env.local` - Public frontend variables
- `supabase/.env` - Supabase configuration

## 🔒 Security

### ✅ **Built-in Best Practices**
- Secrets never exposed on frontend
- Server-side only token validation
- Secured environment variables
- Restrictive CORS configuration
- Automatic SSL in production

### 🛡️ **OAuth Authentication**
- OAuth buttons with icons only (minimalist design)
- Google and GitHub support
- Secure session management
- Authentication middleware

## 🧪 Testing

```bash
# Backend tests
cd backend
uv run pytest

# Frontend tests 
cd frontend
npm test

# Coverage
uv run pytest --cov=api
npm run test:coverage
```

## 📚 Documentation

### 🔗 **API Documentation**
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- Interactive documentation automatically generated

### 📖 **Technologies Used**
- [Next.js](https://nextjs.org/) - React Framework
- [FastAPI](https://fastapi.tiangolo.com/) - Python Framework
- [Supabase](https://supabase.com/) - Backend-as-a-Service
- [Tailwind CSS](https://tailwindcss.com/) - CSS Framework
- [Shadcn/UI](https://ui.shadcn.com/) - UI Components

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file.

## 🆘 Support

- 📧 **Issues**: Open a ticket on GitHub
- 📖 **Documentation**: See the docs of used technologies
- 💬 **Discussions**: Use GitHub Discussions

---

<div align="center">
  <p><strong>Made with 3 for developers</strong></p>
  <p><em>2025 Oja Template. Built with &lt;3 for developers.</em></p>
</div>