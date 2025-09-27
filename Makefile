# Makefile for Template SUPABASE NEXTJS FASTAPI
# Provides convenient commands for development and production

.PHONY: help dev prod install-deps setup setup-dev setup-prod build deploy frontend-start-dev frontend-stop-dev frontend-start-prod frontend-stop-prod backend-start-dev backend-stop-dev backend-start-prod backend-stop-prod supabase-start supabase-stop supabase-restart clean

# Default target
help:
	@echo "========================================="
	@echo "  Template SUPABASE NEXTJS FASTAPI"
	@echo "========================================="
	@echo ""
	@echo "Available commands:"
	@echo ""
	@echo "Dependencies & Setup:"
	@echo "  make install-deps    - Install all system dependencies (run FIRST)"
	@echo "  make setup-dev       - Run initial project setup development mode"
	@echo "  make setup-prod      - Run initial project setup production mode"
	@echo ""
	@echo "Development:"
	@echo "  make dev             - Setup project for development"
	@echo ""
	@echo "⚠️  IMPORTANT: Run 'make install-deps' before any other commands in production"
	@echo ""
	@echo "Production:"
	@echo "  make prod            - Full production deployment (setup + user + build + deploy)"
	@echo "  make setup-user      - Setup production user and relocate project"
	@echo "  make build           - Build and start applications with PM2"
	@echo "  make deploy          - Deploy with Nginx and HTTPS"
	@echo ""
	@echo "Services Management (Development):"
	@echo "  make frontend-start-dev  - Start frontend development server"
	@echo "  make frontend-stop-dev   - Stop frontend development server"
	@echo "  make backend-start-dev   - Start backend development server"
	@echo "  make backend-stop-dev    - Stop backend development server"
	@echo ""
	@echo "Services Management (Production):"
	@echo "  make frontend-start-prod - Start frontend with PM2"
	@echo "  make frontend-stop-prod  - Stop frontend PM2 process"
	@echo "  make backend-start-prod  - Start backend with PM2"
	@echo "  make backend-stop-prod   - Stop backend PM2 process"
	@echo ""
	@echo "Supabase Management:"
	@echo "  make supabase-start  - Start Supabase services"
	@echo "  make supabase-stop   - Stop Supabase services"
	@echo "  make supabase-restart- Restart Supabase services"
	@echo ""
	@echo "Utilities:"
	@echo "  make install         - Install project dependencies (npm, pip)"
	@echo "  make clean           - Clean temporary files and stop all services"
	@echo "  make status          - Show project status"
	@echo "  make logs            - Show application logs"
	@echo "  make info            - Show environment information"
	@echo "  make help            - Show this help message"
	@echo ""
	@echo "📖 For detailed setup guide, see: DEPENDENCIES_README.md"
	@echo ""

# Dependencies installation
install-deps:
	@echo "📦 Installing system dependencies..."
	@./.setup/scripts/00-install-dependencies.sh

# Development workflow
dev: setup-dev
	@echo "✓ Development environment ready!"
	@echo ""
	@echo "Next steps:"
	@echo "  make frontend-start-dev  - Start frontend (Next.js)"
	@echo "  make backend-start-dev   - Start backend (FastAPI)"
	@echo "  make supabase-start      - Start Supabase services"

# Production workflow (with dependencies check)
prod: setup-prod setup-user build deploy
	@echo "✓ Production deployment completed!"
	@echo ""
	@echo "Your applications are now running in production mode."

# Individual setup scripts
setup:
	@echo "🔧 Running project setup..."
	@./.setup/scripts/01-setup.sh

setup-dev:
	@echo "🔧 Running project setup..."
	@./.setup/scripts/01-setup.sh dev

setup-prod:
	@echo "🔧 Running project setup..."
	@./.setup/scripts/01-setup.sh prod

setup-user:
	@echo "👥 Setting up production user..."
	@./.setup/scripts/00-setup-user.sh

build:
	@echo "🏗️  Running build process..."
	@./.setup/scripts/02-build.sh

deploy:
	@echo "🚀 Running deployment process..."
	@./.setup/scripts/03-deploy.sh

# Frontend management - Development
frontend-start-dev:
	@echo "🌐 Starting frontend development server..."
	@if [ ! -d "frontend/node_modules" ]; then \
		echo "Installing frontend dependencies..."; \
		cd frontend && npm install; \
	fi
	@echo "Starting Next.js development server on http://localhost:3000"
	@cd frontend && npm run dev

frontend-stop-dev:
	@echo "🛑 Stopping frontend development server..."
	@pkill -f "next-router-worker" || true
	@pkill -f "npm run dev" || true
	@pkill -f "next dev" || true
	@echo "✓ Frontend development server stopped"

# Frontend management - Production
frontend-start-prod:
	@echo "🌐 Starting frontend with PM2..."
	@if ! command -v pm2 >/dev/null 2>&1; then \
		echo "❌ PM2 not installed. Please run 'make build' first."; \
		exit 1; \
	fi
	@if [ ! -d "frontend/node_modules" ]; then \
		echo "Installing frontend dependencies..."; \
		cd frontend && npm install; \
	fi
	@cd frontend && pm2 start npm --name "frontend" -- start
	@echo "✓ Frontend started with PM2"

frontend-stop-prod:
	@echo "🛑 Stopping frontend PM2 process..."
	@if command -v pm2 >/dev/null 2>&1; then \
		pm2 stop frontend 2>/dev/null || echo "Frontend process not found"; \
		pm2 delete frontend 2>/dev/null || true; \
	else \
		echo "⚠️  PM2 not installed"; \
	fi
	@echo "✓ Frontend PM2 process stopped"

# Backend management - Development
backend-start-dev:
	@echo "⚙️  Starting backend development server..."
	@if [ ! -f "backend/.env" ]; then \
		echo "⚠️  Backend .env file not found. Please run 'make setup' first."; \
		exit 1; \
	fi
	@echo "Starting FastAPI development server with auto-reload..."
	@cd backend && uv run main.py dev

backend-stop-dev:
	@echo "🛑 Stopping backend development server..."
	@pkill -f "uv run main.py" || true
	@pkill -f "uvicorn main:app" || true
	@echo "✓ Backend development server stopped"

# Backend management - Production
backend-start-prod:
	@echo "⚙️  Starting backend with Gunicorn via main.py..."
	@if [ ! -f "backend/.env" ]; then \
		echo "⚠️  Backend .env file not found. Please run 'make setup' first."; \
		exit 1; \
	fi
	@echo "Starting FastAPI production server with Gunicorn..."
	@cd backend && uv run main.py prod

backend-stop-prod:
	@echo "🛑 Stopping backend production server..."
	@pkill -f "gunicorn main:app" || true
	@pkill -f "uv run main.py prod" || true
	@echo "✓ Backend production server stopped"

# Supabase management
supabase-start:
	@echo "🗄️  Starting Supabase services..."
	@if [ ! -d "supabase" ]; then \
		echo "❌ Supabase directory not found. Please run 'make setup' first."; \
		exit 1; \
	fi
	@cd supabase && docker compose up -d
	@echo "✓ Supabase services started"

supabase-stop:
	@echo "🛑 Stopping Supabase services..."
	@if [ -d "supabase" ]; then \
		cd supabase && docker compose down; \
	else \
		echo "⚠️  Supabase directory not found."; \
	fi
	@echo "✓ Supabase services stopped"

supabase-restart:
	@echo "🔄 Restarting Supabase services..."
	@$(MAKE) supabase-stop
	@sleep 2
	@$(MAKE) supabase-start

# Utility commands
clean:
	@echo "🧹 Cleaning up..."
	@echo "Stopping all development services..."
	@$(MAKE) frontend-stop-dev
	@$(MAKE) backend-stop-dev
	@$(MAKE) supabase-stop
	@echo "Cleaning temporary files..."
	@find . -name "*.log" -type f -delete 2>/dev/null || true
	@find . -name ".DS_Store" -type f -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.pyc" -type f -delete 2>/dev/null || true
	@if [ -d "logs" ]; then rm -rf logs/*; fi
	@echo "✓ Cleanup completed"

# Status check
status:
	@echo "📊 Project Status"
	@echo "=================="
	@echo ""
	@echo "Frontend:"
	@if pgrep -f "next dev" > /dev/null; then \
		echo "  🟢 Development server running"; \
	else \
		echo "  🔴 Development server stopped"; \
	fi
	@echo ""
	@echo "Backend:"
	@if pgrep -f "uv run main.py" > /dev/null; then \
		echo "  🟢 Server running"; \
	elif pgrep -f "uvicorn main:app" > /dev/null; then \
		echo "  🟢 Development server running"; \
	elif pgrep -f "gunicorn main:app" > /dev/null; then \
		echo "  🟢 Production server running (Gunicorn)"; \
	else \
		echo "  🔴 Server stopped"; \
	fi
	@echo ""
	@echo "Supabase:"
	@if docker ps | grep -q supabase; then \
		echo "  🟢 Services running"; \
		docker ps --format "table {{.Names}}\t{{.Status}}" | grep supabase || true; \
	else \
		echo "  🔴 Services stopped"; \
	fi
	@echo ""
	@echo "PM2 (Production):"
	@if command -v pm2 >/dev/null 2>&1; then \
		if pm2 list | grep -q "online"; then \
			echo "  🟢 Production services running"; \
			pm2 status; \
		else \
			echo "  🔴 No production services running"; \
		fi \
	else \
		echo "  ⚪ PM2 not installed"; \
	fi

# Development helpers
install:
	@echo "📦 Installing dependencies..."
	@echo "Installing frontend dependencies..."
	@cd frontend && npm install
	@echo "Installing backend dependencies..."
	@cd backend && pip install -r requirements.txt 2>/dev/null || echo "No requirements.txt found, using pyproject.toml"
	@echo "✓ Dependencies installed"

# Logs viewing
logs:
	@echo "📄 Application Logs"
	@echo "==================="
	@if command -v pm2 >/dev/null 2>&1 && pm2 list | grep -q "online"; then \
		echo "PM2 Logs:"; \
		pm2 logs --lines 50; \
	else \
		echo "No PM2 processes running."; \
	fi
	@if [ -d "logs" ] && [ "$(ls -A logs)" ]; then \
		echo ""; \
		echo "Application Logs:"; \
		for log in logs/*.log; do \
			if [ -f "$$log" ]; then \
				echo "--- $$log ---"; \
				tail -20 "$$log"; \
				echo ""; \
			fi \
		done \
	fi

# Environment info
info:
	@echo "ℹ️  Environment Information"
	@echo "=========================="
	@echo "Node.js: $$(node --version 2>/dev/null || echo 'Not installed')"
	@echo "npm: $$(npm --version 2>/dev/null || echo 'Not installed')"
	@echo "Python: $$(python --version 2>/dev/null || python3 --version 2>/dev/null || echo 'Not installed')"
	@echo "Docker: $$(docker --version 2>/dev/null || echo 'Not installed')"
	@echo "PM2: $$(pm2 --version 2>/dev/null || echo 'Not installed')"
	@echo "Git: $$(git --version 2>/dev/null || echo 'Not installed')"
	@echo ""
	@echo "Project Structure:"
	@echo "  Frontend: $$([ -d 'frontend' ] && echo '✓ Present' || echo '✗ Missing')"
	@echo "  Backend: $$([ -d 'backend' ] && echo '✓ Present' || echo '✗ Missing')"
	@echo "  Supabase: $$([ -d 'supabase' ] && echo '✓ Present' || echo '✗ Missing')"
	@echo "  Configuration: $$([ -f '.setup/.env.config' ] && echo '✓ Configured' || echo '⚠️  Not configured')"