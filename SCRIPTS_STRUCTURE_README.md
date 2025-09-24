# Scripts Structure Reorganization

## Vue d'ensemble

La structure des scripts a été réorganisée pour une meilleure maintenabilité et clarté. Tous les scripts ont été déplacés dans `.setup/scripts/` avec des liens symboliques à la racine pour maintenir la compatibilité.

## Nouvelle Structure

```
Template_SUPABASE_NEXTJS_FASTAPI/
├── install-dependencies.sh       # Installation des dépendances système
├── setup.sh → .setup/scripts/setup.sh      # Script principal de setup (symlink)
├── build.sh → .setup/scripts/build.sh      # Script principal de build (symlink)
├── deploy.sh → .setup/scripts/deploy.sh    # Script principal de deploy (symlink)
├── Makefile                       # Commandes d'orchestration
└── .setup/
    ├── scripts/                   # 📁 Tous les scripts du projet
    │   ├── setup.sh               # Script principal de setup
    │   ├── build.sh               # Script principal de build
    │   ├── deploy.sh              # Script principal de deploy
    │   ├── setup/                 # 📁 Scripts de configuration
    │   │   ├── 01-check-dependencies.sh
    │   │   ├── 02-init-supabase.sh
    │   │   ├── 03-generate_env.py
    │   │   └── 04-build.sh
    │   ├── build/                 # 📁 Scripts de build
    │   │   ├── 00-setup-user.sh
    │   │   ├── 01-build-frontend.sh
    │   │   ├── 02-setup-pm2.sh
    │   │   └── 03-start-services.sh
    │   └── deploy/                # 📁 Scripts de déploiement
    │       ├── 01-generate-nginx-configs.sh
    │       ├── 02-install-nginx.sh
    │       └── 03-setup-https.sh
    └── nginx/                     # Templates Nginx
```

## Avantages de cette Structure

### ✅ Organisation Logique
- **Séparation claire** des responsabilités par dossier
- **Scripts principaux** facilement identifiables
- **Sous-scripts** organisés par fonction

### ✅ Compatibilité Maintenue
- **Liens symboliques** à la racine pour la compatibilité
- **Makefile inchangé** - toutes les commandes fonctionnent
- **Documentation existante** reste valide

### ✅ Évolutivité
- **Ajout facile** de nouveaux scripts dans les bons dossiers
- **Structure extensible** pour de nouvelles fonctionnalités
- **Maintenance simplifiée** grâce à l'organisation

## Gestion des Liens Symboliques

Les scripts principaux supportent maintenant les deux modes d'exécution :

### Exécution Directe
```bash
./.setup/scripts/setup.sh    # Script original
```

### Exécution via Lien Symbolique
```bash
./setup.sh                   # Lien symbolique
make setup                   # Via Makefile
```

### Résolution Automatique des Chemins
Chaque script principal détecte automatiquement son mode d'exécution :

```bash
if [[ -L "${BASH_SOURCE[0]}" ]]; then
    # Appelé via lien symbolique
    SCRIPT_DIR="$(cd "$(dirname "$(readlink "${BASH_SOURCE[0]}")")" && pwd)"
else
    # Appelé directement
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
```

## Impact sur l'Utilisation

### Pour les Utilisateurs
**Aucun changement** - toutes les commandes habituelles fonctionnent :
```bash
make setup
make build  
make deploy
./setup.sh
./build.sh
./deploy.sh
```

### Pour les Développeurs
**Meilleure organisation** pour la maintenance :
- Scripts logiquement groupés
- Chemins relatifs cohérents
- Documentation par dossier

## Tests de Validation

Tous les modes d'exécution ont été testés :

- ✅ **Makefile** : `make setup`, `make build`, `make deploy`
- ✅ **Liens symboliques** : `./setup.sh`, `./build.sh`, `./deploy.sh`
- ✅ **Exécution directe** : `./.setup/scripts/setup.sh`
- ✅ **Résolution des chemins** : Tous les sous-scripts trouvés correctement

## Migration Complète

Cette réorganisation complète la migration des dépendances :

1. **Phase 1** ✅ : Centralisation des installations dans `install-dependencies.sh`
2. **Phase 2** ✅ : Nettoyage des installations dans les scripts existants  
3. **Phase 3** ✅ : Réorganisation de la structure des scripts

Le template est maintenant parfaitement structuré et prêt pour la production ! 🚀