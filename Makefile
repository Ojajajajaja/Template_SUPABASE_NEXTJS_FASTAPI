# Makefile for Template SUPABASE NEXTJS FASTAPI
# Provides convenient commands for development and production

.PHONY: init dev prod deps setup setup-prod user build deploy frontend-start frontend-stop backend-start backend-stop logs-frontend logs-backend supabase-start supabase-stop supabase-restart

# Workflow
init : deps user
	@echo "✓ Your vps is now ready!"

dev: setup
	@echo "✓ Development environment ready!"
	@echo ""
	@echo "Next steps:"
	@echo "  cd frontend/ && npm run dev  - Start frontend (Next.js)"
	@echo "  cd backend/ && uv run run.py dev  - Start backend (FastAPI)"
	@echo "  make supabase-start     - Start Supabase services (Supabase)"

prod: setup-prod build deploy
	@echo "✓ Production deployment completed!"
	@echo ""
	@echo "Your applications are now running in production mode."

# Individual scripts
deps:
	@echo "📦 Installing system dependencies..."
	@./.setup/scripts/00-install-dependencies.sh

setup:
	@echo "🔧 Running project setup..."
	@./.setup/scripts/01-setup.sh

setup-prod:
	@echo "🔧 Running project setup..."
	@./.setup/scripts/01-setup.sh prod

user:
	@echo "👥 Setting up production user..."
	@./.setup/scripts/00-setup-user.sh

build:
	@echo "🏗️  Running build process..."
	@./.setup/scripts/02-build.sh

deploy:
	@echo "🚀 Running deployment process..."
	@./.setup/scripts/03-deploy.sh

# Frontend management - Production
frontend-start:
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

frontend-stop:
	@echo "🛑 Stopping frontend PM2 process..."
	@if command -v pm2 >/dev/null 2>&1; then \
		pm2 stop frontend 2>/dev/null || echo "Frontend process not found"; \
		pm2 delete frontend 2>/dev/null || true; \
	else \
		echo "⚠️  PM2 not installed"; \
	fi
	@echo "✓ Frontend PM2 process stopped"

logs-frontend:
	@echo "📄 Frontend Logs"
	@pm2 logs frontend

# Backend management - Production
backend-start:
	@echo "⚙️  Starting backend with Gunicorn via run.py..."
	@if [ ! -f "backend/.env" ]; then \
		echo "⚠️  Backend .env file not found. Please run 'make setup' first."; \
		exit 1; \
	fi
	@echo "Starting FastAPI production server with Gunicorn..."
	@cd backend && uv run run.py prod

backend-stop:
	@echo "🛑 Stopping backend production server..."
	@pkill -f "gunicorn main:app" || true
	@pkill -f "uv run run.py prod" || true
	@echo "✓ Backend production server stopped"

logs-backend:
	@echo "📄 Backend Logs"
	@pm2 logs backend

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
