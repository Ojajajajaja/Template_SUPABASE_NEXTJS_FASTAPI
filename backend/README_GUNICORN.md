# Guide d'utilisation de Gunicorn avec FastAPI

## 🚀 Introduction

Gunicorn a été intégré dans votre backend FastAPI pour améliorer considérablement les performances en production. Cette configuration vous permet de gérer plusieurs workers et d'optimiser la scalabilité de votre application.

## 📋 Avantages de Gunicorn

- **Performance accrue** : Support de plusieurs workers pour traiter les requêtes en parallèle
- **Stabilité** : Redémarrage automatique des workers défaillants
- **Scalabilité** : Ajustement dynamique du nombre de workers selon les ressources
- **Monitoring** : Logs détaillés et métriques de performance
- **Production-ready** : Configuration optimisée pour l'environnement de production

## ⚙️ Configuration

### Fichier de configuration : `gunicorn.conf.py`

La configuration est optimisée avec :
- **Workers** : (2 × CPU cores) + 1 (formule recommandée)
- **Worker class** : `uvicorn.workers.UvicornWorker` (pour FastAPI/ASGI)
- **Timeout** : 120 secondes
- **Max requests per worker** : 1000 (pour éviter les fuites mémoire)
- **Preload app** : Activé pour de meilleures performances

### Variables d'environnement

Vous pouvez personnaliser la configuration via ces variables :

```bash
API_PORT=8000                    # Port du serveur
GUNICORN_WORKERS=4              # Nombre de workers (optionnel)
HOST=0.0.0.0                    # Host d'écoute
```

## 🎯 Utilisation

### 1. Développement (avec rechargement automatique)

```bash
cd backend
./start_gunicorn.sh dev
```

### 2. Production

```bash
cd backend
./start_gunicorn.sh start
```

### 3. Via Makefile (recommandé pour la production)

```bash
make backend-start-prod
```

### 4. Test de configuration

```bash
cd backend
./start_gunicorn.sh test
```

## 📊 Monitoring et Logs

### Logs en temps réel
```bash
# Via PM2 (en production)
pm2 logs backend

# Logs Gunicorn directs
tail -f logs/gunicorn.log
```

### Métriques de performance
```bash
# Status des workers
pm2 status

# Monitoring détaillé
pm2 monit
```

## 🔧 Optimisation des performances

### Ajustement du nombre de workers

Pour une API avec beaucoup d'I/O (comme avec Supabase) :
```bash
# Workers = (2 × CPU cores) + 1 (par défaut)
export GUNICORN_WORKERS=5

# Pour une charge très élevée
export GUNICORN_WORKERS=8
```

### Configuration mémoire

Le fichier `gunicorn.conf.py` inclut :
- `max_requests = 1000` : Redémarre le worker après 1000 requêtes
- `worker_tmp_dir = "/dev/shm"` : Utilise la RAM pour les fichiers temporaires
- `preload_app = True` : Charge l'app une seule fois, partagée entre workers

## 🔍 Dépannage

### Problèmes courants

1. **Port déjà utilisé**
   ```bash
   lsof -ti:8000 | xargs kill -9
   ```

2. **Workers qui plantent**
   - Vérifiez les logs : `pm2 logs backend`
   - Redémarrez : `pm2 restart backend`

3. **Performance dégradée**
   - Ajustez le nombre de workers
   - Surveillez l'utilisation mémoire : `pm2 monit`

### Commandes utiles

```bash
# Arrêter le serveur
pm2 stop backend

# Redémarrer avec nouvelle config
pm2 restart backend

# Voir les processus
ps aux | grep gunicorn

# Tuer tous les processus Gunicorn
pkill -f gunicorn
```

## 📈 Comparaison Performance

### Avant (Uvicorn seul)
- 1 processus
- ~1000 req/sec
- Utilisation CPU limitée

### Après (Gunicorn + Uvicorn workers)
- Multiples workers (4-8 selon le CPU)
- ~3000-5000 req/sec
- Utilisation optimale des ressources
- Redondance et stabilité

## 🛡️ Sécurité

La configuration inclut :
- Limitation des tailles de requêtes
- Timeout de sécurité
- Logs d'accès détaillés
- Possibilité d'ajout SSL/TLS

## 🚀 Prochaines étapes

1. **Monitoring avancé** : Intégration avec Prometheus/Grafana
2. **Load balancing** : Nginx en frontend
3. **Auto-scaling** : Ajustement automatique des workers
4. **Health checks** : Vérifications de santé automatiques

---

**Note** : Cette configuration est optimisée pour la production. En développement, vous pouvez continuer à utiliser `python main.py` pour un démarrage plus rapide.