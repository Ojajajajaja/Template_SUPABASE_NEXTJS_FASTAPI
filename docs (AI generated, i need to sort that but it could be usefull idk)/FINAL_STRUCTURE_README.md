# Template Structure - Final Organization

## Vue d'ensemble

Le template Template SUPABASE NEXTJS FASTAPI a été complètement réorganisé pour une structure propre, maintenable et professionnelle. Tous les scripts sont maintenant centralisés dans `.setup/scripts/` avec un accès via le Makefile.

## Structure Finale

```
Template_SUPABASE_NEXTJS_FASTAPI/
├── 📄 Makefile                           # Interface unique d'orchestration
├── 📁 frontend/                          # Application Next.js
├── 📁 backend/                           # API FastAPI
└── 📁 .setup/                            # Configuration et scripts
    ├── 📁 scripts/                       # 🔧 Tous les scripts du projet
    │   ├── install-dependencies.sh       # 🛠️ Installation dépendances système
    │   ├── check-dependencies.sh         # 🔍 Vérification des dépendances
    │   ├── setup.sh                      # ⚙️ Configuration du projet
    │   ├── build.sh                      # 🏗️ Build et PM2
    │   ├── deploy.sh                     # 🚀 Déploiement Nginx/HTTPS
    │   ├── 📁 setup/                     # Scripts de configuration
    │   │   ├── 01-check-dependencies.sh
    │   │   ├── 02-init-supabase.sh
    │   │   ├── 03-generate_env.py
    │   │   └── 04-build.sh
    │   ├── 📁 build/                     # Scripts de build
    │   │   ├── 00-setup-user.sh
    │   │   ├── 01-build-frontend.sh
    │   │   ├── 02-setup-pm2.sh
    │   │   └── 03-start-services.sh
    │   └── 📁 deploy/                    # Scripts de déploiement
    │       ├── 01-generate-nginx-configs.sh
    │       ├── 02-install-nginx.sh
    │       └── 03-setup-https.sh
    ├── 📁 nginx/                         # Templates Nginx
    └── 📄 .env.config.example            # Configuration exemple
```

## Interface Utilisateur

### 🎯 Commandes Principales

```bash
# 1. Installation des dépendances (OBLIGATOIRE EN PREMIER)
make install-deps

# 2a. Développement
make dev              # Setup seulement

# 2b. Production complète
make prod            # Setup + Build + Deploy automatique
```

### 🔧 Commandes Individuelles

```bash
make setup           # Configuration du projet
make build           # Build avec PM2
make deploy          # Déploiement Nginx/HTTPS
```

### 📊 Commandes Utilitaires

```bash
make check-deps-status    # Vérifier les dépendances
make status              # Statut des services
make info                # Informations système
make clean               # Nettoyage
```

### 🔄 Gestion des Services

```bash
# Développement
make frontend-start-dev   # Frontend Next.js dev
make backend-start-dev    # Backend FastAPI dev

# Production
make frontend-start-prod  # Frontend avec PM2
make backend-start-prod   # Backend avec PM2

# Supabase
make supabase-start      # Démarrer Supabase
make supabase-stop       # Arrêter Supabase
```

## Workflow Recommandé

### 🚀 Première Installation

```bash
# 1. Cloner le template
git clone <repo> myproject
cd myproject

# 2. Installer les dépendances système
sudo make install-deps

# 3a. Pour le développement
make dev

# 3b. Pour la production complète (nouvel ordre)
make prod  # setup → setup-user → build → deploy
```

### 🔄 Workflow Production Détaillé

```bash
# Workflow complet en production
make setup        # 1. Configuration du projet
make setup-user   # 2. Création utilisateur + déplacement
make build        # 3. Build avec PM2
make deploy       # 4. Déploiement Nginx/HTTPS

# Ou tout d'un coup
make prod
```

### 🔄 Utilisation Quotidienne

```bash
# Développement
make frontend-start-dev
make backend-start-dev
make supabase-start

# Vérification
make status
make logs
```

## Avantages de cette Structure

### ✅ **Racine Propre**
- Aucun script à la racine
- Structure professionnelle
- Facilite la navigation

### ✅ **Centralisation**
- Tous les scripts dans `.setup/scripts/`
- Organisation logique par fonction
- Maintenance simplifiée

### ✅ **Interface Unique**
- Makefile comme point d'entrée unique
- Commandes intuitives et cohérentes
- Documentation intégrée (`make help`)

### ✅ **Évolutivité**
- Structure extensible
- Ajout facile de nouveaux scripts
- Organisation scalable

### ✅ **Sécurité**
- Dépendances système centralisées
- Vérifications automatiques
- Installation contrôlée

## Migration depuis l'Ancienne Structure

Si vous utilisez une ancienne version avec des scripts à la racine :

```bash
# Ancienne méthode (ne fonctionne plus)
./setup.sh    ❌
./build.sh    ❌ 
./deploy.sh   ❌

# Nouvelle méthode (recommandée)
make setup    ✅
make build    ✅
make deploy   ✅

# Ou directement (si nécessaire)
./.setup/scripts/setup.sh    ✅
./.setup/scripts/build.sh    ✅
./.setup/scripts/deploy.sh   ✅
```

## Documentation

- **DEPENDENCIES_README.md** - Guide des dépendances
- **MAKEFILE_README.md** - Documentation du Makefile
- **SCRIPTS_STRUCTURE_README.md** - Structure des scripts
- **.setup/scripts/*/README.md** - Documentation par catégorie

## Support

Pour toute question :
1. Consultez `make help`
2. Vérifiez `make info` pour l'environnement
3. Utilisez `make check-deps-status` pour les dépendances
4. Consultez les README spécialisés

---

**Le template est maintenant parfaitement structuré et prêt pour un usage professionnel ! 🚀**