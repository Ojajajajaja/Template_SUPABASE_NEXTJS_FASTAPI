# Migration des Scripts - Résumé des Modifications

## Vue d'ensemble

Les scripts existants dans `.setup/scripts/` ont été modifiés pour ne plus gérer l'installation des dépendances système. Cette responsabilité a été centralisée dans le script `install-dependencies.sh`.

## Modifications Apportées

### 🔧 Scripts de Build

#### `.setup/scripts/build/02-setup-pm2.sh`
**Avant :**
```bash
# Installation automatique de PM2
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
fi
```

**Après :**
```bash
# Vérification que PM2 est installé
if ! command -v pm2 &> /dev/null; then
    log_error "PM2 is not installed"
    log_info "Please run 'make install-deps' or './install-dependencies.sh' first"
    exit 1
fi
```

### 🚀 Scripts de Déploiement

#### `.setup/scripts/deploy/02-install-nginx.sh`
**Avant :**
```bash
# Installation de Nginx et Certbot
apt update
apt install -y nginx certbot python3-certbot-nginx
```

**Après :**
```bash
# Vérification que Nginx et Certbot sont installés
if ! command -v nginx &> /dev/null; then
    log_error "Nginx is not installed"
    log_info "Please run 'make install-deps' first"
    exit 1
fi
```

### ⚙️ Scripts de Setup

#### `.setup/scripts/setup/01-check-dependencies.sh`
**Avant :**
- Affichage d'URLs d'installation manuelles
- Pas de vérification d'échec

**Après :**
- Guide vers `make install-deps`
- Compteur d'erreurs avec exit code approprié
- Messages uniformisés

## Avantages de cette Approche

### ✅ Centralisation
- Toutes les installations système en un seul endroit
- Évite la duplication de code
- Facilite la maintenance

### ✅ Cohérence
- Même méthode d'installation pour tous les OS
- Gestion uniforme des permissions
- Chemins globaux standardisés (ex: UV dans `/usr/local/bin/`)

### ✅ Robustesse
- Vérification des prérequis avant exécution
- Messages d'erreur clairs et actionables
- Pas d'installations partielles ou conflictuelles

### ✅ Séparation des Responsabilités
- **install-dependencies.sh** : Installation système
- **Scripts setup/** : Configuration projet
- **Scripts build/** : Build et PM2
- **Scripts deploy/** : Configuration Nginx/HTTPS

## Impact sur l'Utilisation

### Ancien Workflow
```bash
./setup.sh     # Installait uv, docker, etc. + configuration
./build.sh     # Installait PM2 + build
./deploy.sh    # Installait Nginx/Certbot + déploiement
```

### Nouveau Workflow
```bash
make install-deps  # Installation système (UNE FOIS)
make dev           # OU make prod pour tout automatiser
```

### Workflow Manuel (si nécessaire)
```bash
./install-dependencies.sh  # Prérequis système
./setup.sh                 # Configuration
./build.sh                 # Build avec PM2
./deploy.sh                # Nginx + HTTPS
```

## Gestion des Erreurs

Tous les scripts modifiés détectent maintenant les dépendances manquantes et affichent des messages cohérents :

```
❌ [DEPENDENCY] is not installed
Please run 'make install-deps' or './install-dependencies.sh' first
```

## Compatibilité

- ✅ **Rétrocompatible** : Les scripts peuvent toujours être exécutés individuellement
- ✅ **Makefile intégré** : Commandes pratiques avec vérifications automatiques  
- ✅ **Multi-OS** : Support Ubuntu, CentOS, macOS
- ✅ **CI/CD Ready** : Facilite l'intégration dans les pipelines

## Tests de Validation

Tous les scripts ont été testés pour vérifier :
- ✅ Détection correcte des dépendances manquantes
- ✅ Messages d'erreur appropriés
- ✅ Exit codes corrects (1 pour les erreurs)
- ✅ Fonctionnement normal quand les dépendances sont présentes

Cette migration améliore significativement la robustesse et la maintenabilité du système de déploiement.