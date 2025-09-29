# 📝 Notes de Production - Configuration VPS

## 🌐 Architecture VPS Recommandée

### Configuration Réseau Recommandée

```yaml
# docker-compose.production.yml
version: '3.8'

networks:
  internal:
    driver: bridge

services:
  # Backend FastAPI
  backend:
    build: ./backend
    environment:
      - SUPABASE_URL=http://kong:8000  # Communication interne
      - API_PORT=8000
    networks:
      - internal
    restart: unless-stopped

  # Supabase Services (même configuration que dev)
  kong:
    image: kong:2.8.1
    networks:
      - internal
    ports:
      - "3001:8000"  # Exposé pour debug si nécessaire

  postgres:
    image: supabase/postgres:15.8.1.060
    networks:
      - internal
    # Pas exposé publiquement
```

## ⚙️ Configuration Gunicorn pour VPS

### Pourquoi garder `preload_app = False`

Même sur le même VPS, gardez cette configuration car :

1. **Isolation des connexions** - Chaque worker a ses propres connexions HTTP
2. **Robustesse** - Un worker qui crash n'affecte pas les autres
3. **Scalabilité** - Plus facile d'ajouter/supprimer des workers

### Configuration Optimisée pour VPS

```python
# gunicorn.conf.py pour VPS
import multiprocessing

# Workers basés sur les CPU du VPS
workers = multiprocessing.cpu_count() * 2 + 1

# Isolation des workers (IMPORTANT)
preload_app = False

# Gestion mémoire pour VPS
max_requests = 1000
max_requests_jitter = 100

# Timeouts adaptés au réseau interne
timeout = 60
keepalive = 30
```

## 🔒 Sécurité VPS

### Variables d'Environnement

```bash
# .env.production
SUPABASE_URL=http://kong:8000  # Réseau interne
SUPABASE_SERVICE_KEY=your_production_service_key
API_PORT=8000

# Pas d'exposition PostgreSQL directe
POSTGRES_HOST=postgres  # Nom du service Docker
POSTGRES_PORT=5432      # Port interne seulement
```

### Nginx Configuration

```nginx
# /etc/nginx/sites-available/yoursite
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:8000;  # Backend FastAPI
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 📊 Monitoring

### Surveillance des Connexions

```bash
# Vérifier les connexions actives
docker exec your-postgres psql -U postgres -c "
  SELECT COUNT(*) as active_connections 
  FROM pg_stat_activity 
  WHERE state = 'active';
"

# Surveiller les workers Gunicorn
ps aux | grep gunicorn
```

## 🚀 Déploiement

### Script de Déploiement

```bash
#!/bin/bash
# deploy.sh

# Build et deploy
docker-compose -f docker-compose.production.yml up -d --build

# Vérifier la santé
curl http://localhost:8000/health

echo "✅ Déployment terminé"
```