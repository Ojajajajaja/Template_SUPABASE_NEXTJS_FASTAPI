# Scripts de Build

Ce dossier contient les scripts automatisés pour le build et le déploiement en production du template Supabase + Next.js + FastAPI.

## Structure des Scripts

```
build/
├── 00-setup-user.sh              # Configuration utilisateur production
├── 01-build-frontend.sh          # Build de l'application Next.js
├── 02-setup-pm2.sh               # Configuration de PM2
├── 03-start-services.sh          # Lancement des services
└── README.md                     # Ce fichier
```

## Utilisation

### Script Principal (à la racine)
```bash
# Depuis la racine du projet
./build.sh
```

Le script principal [build.sh](file:///Users/oja/Project/tools/Template_SUPABASE_NEXTJS_FASTAPI/build.sh) est un lanceur simple qui exécute séquentiellement tous les scripts de build, comme [setup.sh](file:///Users/oja/Project/tools/Template_SUPABASE_NEXTJS_FASTAPI/setup.sh) le fait pour la configuration.

### Ordre d'exécution

1. **00-setup-user.sh** - Configure l'utilisateur de production et déplace le projet
2. **01-build-frontend.sh** - Build l'application Next.js pour la production
3. **02-setup-pm2.sh** - Configure PM2 pour la gestion des processus
4. **03-start-services.sh** - Lance tous les services en production

## Scripts Individuels

### 00-setup-user.sh

Ce script configure l'utilisateur de production et déplace le projet dans son environnement.

**Fonctionnalités :**
- ✅ Création de l'utilisateur de production (si nécessaire)
- ✅ Configuration du mot de passe
- ✅ Ajout aux groupes sudo et docker
- ✅ Déplacement du projet vers `/home/USERNAME/`
- ✅ Configuration des permissions et propriétés
- ✅ Création d'un profil utilisateur personnalisé
- ✅ Configuration sudo pour les commandes nécessaires

**Prérequis :**
- PM2 doit être installé (utilisez `make install-deps`)
- Variables `PROD_USERNAME` et `PROD_PASSWORD` configurées dans `.env.config`
- Le répertoire home sera automatiquement `/home/PROD_USERNAME`

### 01-build-frontend.sh

Ce script build l'application Next.js pour la production.

**Fonctionnalités :**
- ✅ Vérification de l'existence du répertoire frontend
- ✅ Installation des dépendances si nécessaire
- ✅ Exécution de `npm run build`
- ✅ Vérification de la sortie de build
- ✅ Affichage des informations de taille

**Prérequis :**
- Node.js et npm installés (utilisez `make install-deps`)
- Répertoire `frontend/` avec `package.json`
- Script `build` défini dans `package.json`

### 02-setup-pm2.sh

Ce script configure PM2 pour la gestion des processus en production.

**Fonctionnalités :**
- ✅ Vérification que PM2 est installé
- ✅ Lecture de la configuration depuis `.env.config`
- ✅ Génération du fichier `ecosystem.config.js`
- ✅ Configuration des logs
- ✅ Validation de la configuration PM2

**Prérequis :**
- PM2 installé (utilisez `make install-deps`)
- Node.js et npm installés (utilisez `make install-deps`)
- Configuration `.env.config` présente

**Fichiers générés :**
```
/
├── ecosystem.config.js    # Configuration PM2
└── logs/                  # Répertoire des logs
    ├── frontend-*.log
    └── backend-*.log
```

### 03-start-services.sh

Ce script lance tous les services en utilisant PM2.

**Fonctionnalités :**
- ✅ Démarrage des applications via PM2
- ✅ Vérification du statut des services
- ✅ Attente de démarrage avec timeout
- ✅ Affichage des URLs d'accès
- ✅ Instructions d'utilisation PM2

**Services gérés :**
- `frontend` - Application Next.js
- `backend` - API FastAPI

## Variables d'Environnement

Le script utilise les variables du fichier `.setup/.env.config` :

| Variable | Description | Défaut |
|----------|-------------|---------|
| `FRONTEND_PORT` | Port du frontend | `3000` |
| `API_PORT` | Port de l'API | `2000` |
| `FRONTEND_DOMAIN` | Domaine du frontend | `localhost` |
| `BACKEND_DOMAIN` | Domaine de l'API | `localhost` |

## Commandes PM2 Utiles

Une fois les services lancés :

```bash
# Statut des processus
pm2 status

# Voir les logs
pm2 logs
pm2 logs frontend
pm2 logs backend

# Gestion des processus
pm2 restart all
pm2 stop all
pm2 delete all

# Monitoring
pm2 monit
```

## Prérequis Système

**IMPORTANT** : Avant d'utiliser ces scripts, vous devez installer toutes les dépendances système :

```bash
# Installation des dépendances système (à faire EN PREMIER)
make install-deps
# OU
./install-dependencies.sh
```

Cela installera :
- Node.js & npm
- Python 3 & UV
- PM2
- Docker
- Et autres dépendances nécessaires

## Prérequis

- Toutes les dépendances système installées (`make install-deps`)
- Utilisateur de production configuré (variables dans `.env.config`)
- Frontend buildé (`.next/` directory)
- Configuration `.env.config` présente

## Résolution de Problèmes

### Erreur "PM2 not found" ou "Dependencies missing"
```bash
# Installer toutes les dépendances système
make install-deps
```

### Erreur "Frontend build not found"
```bash
cd frontend
npm run build
```

### Services ne démarrent pas
```bash
# Vérifier les logs
pm2 logs

# Vérifier la configuration
pm2 describe frontend
pm2 describe backend
```

## Production

Pour un déploiement en production complète :

1. **Setup** : `./setup.sh` - Configuration initiale
2. **Deploy** : `./deploy.sh` - Nginx + HTTPS
3. **Build** : `./build.sh` - Build + PM2 + Lancement

Les applications seront accessibles via les domaines configurés dans Nginx.