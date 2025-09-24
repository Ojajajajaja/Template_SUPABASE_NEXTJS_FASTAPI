# Fullstack Project Template - Supabase, Next.js & FastAPI

This template provides a complete base for a fullstack project using:
- **Frontend**: Next.js with TypeScript, Tailwind CSS and ESLint
- **Backend**: FastAPI with Python
- **Database**: Supabase (Self-hosted PostgreSQL with Docker)

## 🏗️ Project Architecture

```
.
├── backend/           # FastAPI API
├── frontend/          # Next.js Application
├── supabase/          # Self-hosted Supabase services with Docker
├── .setup/            # Initialization scripts and configurations
└── setup.sh           # Main installation script
```

## 🚀 Installation

1. **Clone the template**
   ```bash
   git clone https://github.com/Ojajajajaja/Template_SUPABASE_NEXTJS_FASTAPI.git project-name
   cd project-name
   ```

2. **Run the installation script**
   ```bash
   ./setup.sh
   ```

The installation script will automatically:
- Check required dependencies
- Initialize the Supabase environment
- Generate environment files
- Build and start all services
- Remove .git to start your own depot

## 📁 Detailed Structure

### Backend (FastAPI)
- Language: Python 3.12+
- Dependency management: `uv`
- Default ports: API on 8001
- Environment variables configured automatically

### Frontend (Next.js)
- Framework: Next.js 14+ with App Router
- Language: TypeScript
- Style: Tailwind CSS
- Default port: 3000
- Environment variables configured automatically

### Database (Supabase)
- Database: PostgreSQL 15
- Docker services: Auth, Storage, Realtime, etc.
- Default port: 8000 (Kong API Gateway)
- Automatic configuration of JWT keys and roles

## ⚙️ Configuration

### Environment Variables
Environment variables are managed automatically by the installation script:
- `.setup/.env.config`: Main configuration
- `backend/.env`: Backend variables
- `frontend/.env.local`: Frontend variables
- `supabase/.env`: Supabase variables

### Default Ports
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8001
- **Supabase API**: http://localhost:8000
- **Supabase Studio**: http://localhost:3000 (same port as frontend)

## ▶️ Starting Services

After installation, you can start services individually:

### Backend
```bash
cd backend
uv run main.py
```

### Frontend
```bash
cd frontend
npm run dev
```

### Supabase
```bash
cd supabase
docker compose up -d
```

## 🛠️ Available Scripts

### Development Scripts
- `./setup.sh`: Complete installation script (development setup)
- `.setup/scripts/01-check-dependencies.sh`: Dependency check
- `.setup/scripts/02-init-supabase.sh`: Supabase initialization
- `.setup/scripts/03-generate_env.py`: Environment file generation
- `.setup/scripts/04-build.sh`: Service build and startup

### Deployment Scripts
- `./deploy.sh nginx`: Generate Nginx configurations for production
- `./deploy.sh all`: Complete deployment preparation
- `./deploy.sh help`: Show deployment options

## 🔐 Security

- JWT keys are automatically generated during installation
- Passwords are configured in `.setup/.env.config`
- Sensitive variables are not versioned thanks to `.gitignore` files

## 📚 Documentation

### Backend
- API Documentation: http://localhost:8001/docs (Swagger)
- Alternative API Documentation: http://localhost:8001/redoc (ReDoc)

### Supabase
- Admin interface: http://localhost:3000
- Documentation: https://supabase.com/docs

## 🤝 Contributing

1. Fork the project
2. Create a branch for your feature (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'Add a feature'`)
4. Push the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 📞 Support

For any issues or questions, please open an issue on this repository.