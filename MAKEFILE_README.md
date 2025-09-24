# Makefile Commands Reference

Ce Makefile fournit des commandes pratiques pour gérer le projet Template SUPABASE NEXTJS FASTAPI en développement et en production.

## Commandes Principales

### Développement Rapide
```bash
make dev
# Équivaut à : make setup
# Configure le projet pour le développement
```

### Production Complète
```bash
make prod
# Équivaut à : make setup && make build && make deploy
# Déploiement complet en production
```

## Commandes Individuelles

### Configuration
```bash
make setup    # Exécute ./setup.sh
make build    # Exécute ./build.sh  
make deploy   # Exécute ./deploy.sh
```

### Gestion des Services de Développement

#### Frontend (Next.js)
```bash
make frontend-start   # Démarre npm run dev
make frontend-stop    # Arrête le serveur de développement
```

#### Backend (FastAPI)
```bash
make backend-start    # Démarre python main.py
make backend-stop     # Arrête le serveur de développement
```

#### Supabase (Docker)
```bash
make supabase-start   # cd supabase && docker compose up -d
make supabase-stop    # cd supabase && docker compose down
make supabase-restart # Stop puis start
```

## Commandes Utilitaires

### Information et Status
```bash
make help      # Affiche l'aide
make status    # Affiche le statut de tous les services
make info      # Affiche les informations d'environnement
make logs      # Affiche les logs des applications
```

### Maintenance
```bash
make install   # Installe toutes les dépendances
make clean     # Nettoie et arrête tous les services
```

## Workflows Typiques

### Développement Local
```bash
# 1. Configuration initiale (une seule fois)
make dev

# 2. Démarrage des services
make supabase-start
make backend-start
make frontend-start

# 3. Vérification du statut
make status
```

### Déploiement Production
```bash
# Déploiement complet automatique
make prod

# Ou étape par étape
make setup
make deploy  # Nginx + HTTPS
make build   # Build + PM2
```

### Maintenance
```bash
# Arrêter tous les services
make clean

# Redémarrer Supabase uniquement
make supabase-restart

# Voir les logs
make logs

# Informations système
make info
```

## URLs par Défaut

Après `make dev` et démarrage des services :

- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:2000 (ou port configuré)
- **Supabase Studio**: http://localhost:3000 (partage le port frontend en dev)
- **Supabase API**: http://localhost:8000

## Gestion des Erreurs

### Frontend ne démarre pas
```bash
cd frontend
npm install
make frontend-start
```

### Backend ne démarre pas
```bash
# Vérifier la configuration
make setup
make backend-start
```

### Supabase ne démarre pas
```bash
# Vérifier Docker
docker --version

# Redémarrer les services
make supabase-restart
```

### Conflit de ports
```bash
# Arrêter tous les services
make clean

# Vérifier les processus
make status

# Redémarrer individuellement
make supabase-start
make backend-start
make frontend-start
```

## Notes Importantes

- **Développement** : Utilisez `make dev` et les commandes `*-start/stop`
- **Production** : Utilisez `make prod` qui configure PM2
- **Ports** : Le frontend partage le port 3000 avec Supabase Studio en développement
- **Dépendances** : Le Makefile vérifie et installe les dépendances automatiquement
- **Logs** : Tous les logs sont centralisés avec `make logs`

## Prérequis

- Node.js et npm
- Python 3.12+
- Docker et Docker Compose
- Make (généralement préinstallé sur Linux/macOS)