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
- Automatically documented REST API

### 🗄️ **Database**
- **Supabase** (PostgreSQL + Auth + Storage)
- Self-hosted with Docker
- OAuth Authentication (Google, GitHub)
- Row Level Security (RLS)

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

### 🛠️ New VPS Installation

1. **First VPS installation**
   ```bash
   # Clone the template
   git clone https://github.com/Ojajajajaja/Template_SUPABASE_NEXTJS_FASTAPI.git my-project
   cd my-project
   
   # VPS initialization script
   bash "hello vps.sh"
   ```

2. **Configuration**
   ```bash
   # Create your configuration file
   cp .setup/.env.config.example .setup/.env.config
   # Edit the file with your settings (username, project, ports, domain)
   nano .setup/.env.config
   ```

3. **Install dependencies**
   ```bash
   make deps
   ```

4. **User setup (avoid root)**
   ```bash
   make user
   ```

### 🌐 Production Deployment

```bash
# DNS configuration for your domain required before this step
make prod
```

This command will automatically:
- ✅ Install Supabase locally
- ✅ Setup backend & frontend
- ✅ Create .env files for all 3 services
- ✅ Build and start with PM2 (multi-instance, auto-restart)
- ✅ Configure Nginx and SSL automatically
- ✅ Go live with demo interface

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
- ✅ Create .env files for development
- ✅ Remove .git to allow your own repo

3. **Start services**
   ```bash
   # Backend (FastAPI)
   cd backend && uv run run.py dev
   
   # Frontend (Next.js) - new terminal
   cd frontend && npm run dev
   
   # Or use make commands
   make supabase-start    # Start Supabase
   ```

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

### 💻 **Local Development**

```bash
# Backend (FastAPI)
cd backend
uv run run.py dev          # Development mode
uv run run.py prod         # Production mode

# Frontend (Next.js)
cd frontend
npm run dev                # Development server
npm run build              # Production build
npm start                  # Production server

# Tests
cd backend && uv run pytest
cd frontend && npm test
```

## 🌍 Default URLs

### 🔧 **Development**
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8001
- **Supabase Studio**: http://localhost:54323
- **API Documentation**: http://localhost:8001/docs

### 🚀 **Production** 
- **Website**: https://your-domain.com
- **API**: https://your-domain.com/api
- **Supabase**: http://your-domain.com:54323

## ⚙️ Configuration

### 📝 **.env.config File**

The `.setup/.env.config` file contains all configuration:

```bash
# Project information
PROJECT_NAME="my-project"
USERNAME="my-user"
DOMAIN="my-domain.com"

# Ports
FRONTEND_PORT=3000
BACKEND_PORT=8001
SUPABASE_PORT=54323

# Passwords (auto-generated)
POSTGRES_PASSWORD="auto-password"
SUPABASE_JWT_SECRET="auto-jwt-secret"
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
- **Swagger UI**: http://localhost:8001/docs
- **ReDoc**: http://localhost:8001/redoc
- Interactive documentation automatically generated

### 📖 **Technologies Used**
- [Next.js](https://nextjs.org/) - React Framework
- [FastAPI](https://fastapi.tiangolo.com/) - Python Framework
- [Supabase](https://supabase.com/) - Backend-as-a-Service
- [Tailwind CSS](https://tailwindcss.com/) - CSS Framework
- [Shadcn/UI](https://ui.shadcn.com/) - UI Components

## 🤝 Contributing

1. Fork the project
2. Create a branch (`git checkout -b feature/my-feature`)
3. Commit (`git commit -m 'Add a feature'`)
4. Push (`git push origin feature/my-feature`) 
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file.

## 🆘 Support

- 📧 **Issues**: Open a ticket on GitHub
- 📖 **Documentation**: See the docs of used technologies
- 💬 **Discussions**: Use GitHub Discussions

---

<div align="center">
  <p><strong>Made with ❤️ for developers</strong></p>
  <p><em>Production-ready template • 5-minute setup • Automated deployment</em></p>
</div>