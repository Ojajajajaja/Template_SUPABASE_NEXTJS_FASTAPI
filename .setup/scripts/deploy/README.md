# Scripts de Déploiement

Ce dossier contient les scripts automatisés pour préparer le déploiement du template Supabase + Next.js + FastAPI.

## Structure des Scripts

```
deploy/
├── 01-generate-nginx-configs.sh  # Génération des configurations Nginx
├── 02-install-nginx.sh           # Installation et configuration Nginx
├── 03-setup-https.sh             # Configuration HTTPS/SSL avec Let's Encrypt
└── README.md                      # Ce fichier
```

## Utilisation

### Préparation

1. **Configurer les variables d'environnement** :
   ```bash
   cp .setup/.env.config.example .setup/.env.config
   ```

2. **Modifier `.env.config`** avec vos valeurs de production :
   ```bash
   # Production Config
   FRONTEND_DOMAIN="monsite.com"
   BACKEND_DOMAIN="api.monsite.com"
   SUPABASE_DOMAIN="supabase.monsite.com"
   ```

### Exécution

#### Script Principal (à la racine)
```bash
# Depuis la racine du projet
./deploy.sh
```

Le script principal [deploy.sh](file:///Users/oja/Project/tools/Template_SUPABASE_NEXTJS_FASTAPI/deploy.sh) est un lanceur simple qui exécute séquentiellement tous les scripts de déploiement, comme [setup.sh](file:///Users/oja/Project/tools/Template_SUPABASE_NEXTJS_FASTAPI/setup.sh) le fait pour la configuration.

### Ordre d'exécution

1. **01-generate-nginx-configs.sh** - Génère les configurations Nginx
2. **02-install-nginx.sh** - Installe et configure Nginx (nécessite sudo)
3. **03-setup-https.sh** - Configure HTTPS/SSL avec Let's Encrypt (nécessite sudo)

## Scripts Individuels

### 02-install-nginx.sh

Ce script installe et configure tous les composants nécessaires sur le serveur de production.

**Fonctionnalités :**
- ✅ Installation de Nginx
- ✅ Installation de Certbot (Let's Encrypt)
- ✅ Installation et configuration du firewall UFW
- ✅ Copie des configurations vers `/etc/nginx/sites-available/`
- ✅ Création des liens symboliques vers `/etc/nginx/sites-enabled/`
- ✅ Test et rechargement de la configuration Nginx
- ✅ Configuration automatique du firewall

### 03-setup-https.sh

Ce script configure les certificats SSL/TLS avec Let's Encrypt pour tous les domaines.

**Fonctionnalités :**
- ✅ Configuration automatique des certificats SSL pour tous les domaines
- ✅ Redirection automatique HTTP → HTTPS
- ✅ Configuration du renouvellement automatique des certificats
- ✅ Test et validation de la configuration Nginx après SSL
- ✅ Gestion des erreurs et rapport détaillé
- ✅ Support pour les domaines multiples

**Prérequis :**
- Doit être exécuté avec `sudo`
- Nginx doit être installé et fonctionnel
- Les DNS doivent pointer vers le serveur
- Les ports 80 et 443 doivent être accessibles depuis Internet

### 01-generate-nginx-configs.sh

Ce script génère les configurations Nginx à partir des templates et des variables d'environnement.

**Fonctionnalités :**
- ✅ Lecture automatique du fichier `.env.config`
- ✅ Substitution des variables dans les templates
- ✅ Création du dossier `nginx/` à la racine du projet

**Fichiers générés :**
```
nginx/
├── frontend.conf     # Configuration pour Next.js
├── backend.conf      # Configuration pour FastAPI
└── supabase.conf     # Configuration pour Supabase
```

## Variables d'Environnement Requises

Dans le fichier `.setup/.env.config` :

| Variable | Description | Exemple |
|----------|-------------|---------|
| `FRONTEND_DOMAIN` | Domaine du frontend | `"monsite.com"` |
| `BACKEND_DOMAIN` | Domaine de l'API | `"api.monsite.com"` |
| `SUPABASE_DOMAIN` | Domaine Supabase | `"supabase.monsite.com"` |
| `FRONTEND_PORT` | Port du frontend | `3000` |
| `API_PORT` | Port de l'API | `2000` |
| `KONG_HTTP_PORT` | Port Kong/Supabase | `8000` |

## Déploiement sur Serveur

Une fois les configurations générées :

1. **Copier le dossier nginx** sur votre serveur :
   ```bash
   scp -r nginx/ user@votre-serveur:/tmp/
   ```

2. **Se connecter au serveur** et installer :
   ```bash
   ssh user@votre-serveur
   cd /tmp/nginx
   sudo ./install.sh
   ```

3. **Configurer SSL** avec Let's Encrypt :
   ```bash
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d monsite.com
   sudo certbot --nginx -d api.monsite.com
   sudo certbot --nginx -d supabase.monsite.com
   ```

## Résolution de Problèmes

### Erreur "Fichier de configuration manquant"
```bash
# Solution : Créer le fichier de configuration
cp .setup/.env.config.example .setup/.env.config
# Puis éditer avec vos valeurs
```

### Erreur "Variables manquantes"
Vérifiez que toutes les variables requises sont définies dans `.env.config` :
- `FRONTEND_DOMAIN`
- `BACKEND_DOMAIN`
- `SUPABASE_DOMAIN`
- `FRONTEND_PORT`
- `API_PORT`
- `KONG_HTTP_PORT`

### Permissions
Si vous obtenez une erreur de permission :
```bash
chmod +x .setup/scripts/deploy/*.sh
```

## Sécurité

⚠️ **Important** : Ne commitez jamais le fichier `.env.config` dans votre dépôt Git. Il contient des informations sensibles de production.

Le fichier `.env.config` est automatiquement ignoré par Git grâce au `.gitignore`.

## Support

Pour toute question ou problème :
1. Vérifiez les logs du script
2. Assurez-vous que tous les fichiers templates existent
3. Vérifiez les permissions des scripts
4. Consultez la documentation du projet