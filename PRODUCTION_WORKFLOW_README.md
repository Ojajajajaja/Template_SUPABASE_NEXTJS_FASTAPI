# Production Workflow - Guide Complet

## Vue d'ensemble

Le template utilise maintenant un workflow de production en 4 étapes avec gestion automatique du déplacement de projet et de l'utilisateur de production.

## Ordre des Scripts de Production

```
1. 📋 01-setup.sh      - Configuration initiale du projet
2. 👤 02-setup-user.sh - Création utilisateur + déplacement projet  
3. 🏗️ 03-build.sh      - Build des applications + PM2
4. 🚀 04-deploy.sh     - Déploiement Nginx + HTTPS
```

## Workflow Automatique

### 🎯 Commande Unique (Recommandée)

```bash
# Installation complète en une commande
sudo make install-deps  # Prérequis système
make prod              # Workflow complet automatique
```

### 🔧 Workflow Étape par Étape

```bash
# 1. Dépendances système (obligatoire en premier)
sudo make install-deps

# 2. Configuration du projet
make setup

# 3. Configuration utilisateur de production
sudo make setup-user   # ⚠️ Étape critique - déplace le projet

# 4. Build des applications
make build

# 5. Déploiement Nginx/HTTPS
sudo make deploy
```

## Gestion du Déplacement de Projet

### 🔄 Que se passe-t-il lors de `make setup-user` ?

1. **Création de l'utilisateur de production** (ex: `appuser`)
2. **Déplacement du projet** vers `/home/appuser/Template_SUPABASE_NEXTJS_FASTAPI`
3. **Configuration des permissions** et groupes
4. **Options de continuation automatique**

### ⚙️ Options de Continuation Après Déplacement

Après `make setup-user`, le script propose 3 options :

#### Option 1: Utilisateur de Production (Recommandée)
```bash
# Se connecter automatiquement avec l'utilisateur de production
# ✅ Avantages: 
#   - Environnement de production optimal
#   - Permissions correctes
#   - Répertoire automatiquement configuré

su - appuser  # Connexion automatique
# Vous êtes maintenant dans /home/appuser/Template_SUPABASE_NEXTJS_FASTAPI
make build && make deploy  # Continuer le workflow
```

#### Option 2: Utilisateur Actuel
```bash
# Continuer avec l'utilisateur actuel depuis le nouveau répertoire
cd /home/appuser/Template_SUPABASE_NEXTJS_FASTAPI
make build && make deploy
```

#### Option 3: Manuel (Plus tard)
```bash
# Continuer manuellement plus tard
# Choix A - Utilisateur de production:
su - appuser
make build && make deploy

# Choix B - Utilisateur actuel:
cd /home/appuser/Template_SUPABASE_NEXTJS_FASTAPI  
make build && make deploy
```

## Scripts de Continuation

### 🔄 Script d'Aide Automatique

Le script `continue-after-move.sh` est automatiquement proposé pour faciliter la transition :

```bash
# Script appelé automatiquement après déplacement
./.setup/scripts/continue-after-move.sh <nouveau_chemin> <utilisateur_prod>
```

**Fonctionnalités :**
- Interface guidée pour choisir la méthode de continuation
- Connexion automatique à l'utilisateur de production
- Navigation automatique vers le nouveau répertoire
- Lancement d'un nouveau shell dans le bon contexte

## Bonnes Pratiques

### ✅ Workflow Recommandé pour la Production

```bash
# 1. Installation complète automatique
sudo make install-deps && make prod

# 2. Si interruption après setup-user, continuer avec:
su - appuser  # Se connecter en utilisateur de production
make build && make deploy  # Continuer le workflow
```

### ⚠️ Points d'Attention

1. **Après `make setup-user`** : Le projet n'est plus dans le répertoire original
2. **Permissions** : L'utilisateur de production a les bonnes permissions
3. **Environnement** : L'utilisateur de production a un environnement optimisé
4. **Continuation** : Toujours continuer depuis le nouveau répertoire

## Dépannage

### ❓ "Le projet n'est plus dans le répertoire original"

**Cause :** Le script `02-setup-user.sh` a déplacé le projet vers `/home/<user>/`

**Solution :**
```bash
# Trouver le nouveau répertoire
find /home -name "Template_SUPABASE_NEXTJS_FASTAPI" 2>/dev/null

# Aller dans le nouveau répertoire
cd /home/appuser/Template_SUPABASE_NEXTJS_FASTAPI

# Continuer le workflow
make build && make deploy
```

### ❓ "Erreurs de permissions"

**Solution :** Utiliser l'utilisateur de production :
```bash
su - appuser
# Continuer depuis l'environnement de production
```

### ❓ "Reprendre un workflow interrompu"

```bash
# Si interrompu après setup
make setup-user && make build && make deploy

# Si interrompu après setup-user
su - appuser  # puis
make build && make deploy

# Si interrompu après build
make deploy
```

## Architecture de l'Utilisateur de Production

### 🏠 Environnement Utilisateur

```
/home/appuser/
├── Template_SUPABASE_NEXTJS_FASTAPI/  # Projet déplacé
│   ├── .setup/scripts/                # Scripts accessibles
│   ├── frontend/                      # Application frontend
│   └── backend/                       # Application backend
├── .profile_project                   # Profil projet automatique
└── .bashrc                           # Configuration shell
```

### 🔐 Permissions et Groupes

- **sudo** : Accès pour les commandes système nécessaires
- **docker** : Gestion des conteneurs Supabase
- **Permissions spéciales** : Nginx, Certbot, UFW sans mot de passe

### 🎯 Avantages

1. **Isolation** : Environnement dédié à la production
2. **Sécurité** : Permissions minimales nécessaires
3. **Consistance** : Même environnement sur tous les serveurs
4. **Facilité** : Navigation automatique vers le projet

---

**Ce workflow garantit un déploiement de production robuste et sécurisé ! 🚀**