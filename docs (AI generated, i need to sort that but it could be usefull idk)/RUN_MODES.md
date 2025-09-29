# 🚀 Modes de Démarrage du Backend

Ce backend FastAPI supporte deux modes de démarrage selon l'environnement.

## 🛠️ Mode Développement (Recommandé pour le dev)

```bash
python main.py dev
# ou simplement (mode par défaut)
python main.py
```

**Avantages :**
- ✅ Rechargement automatique du code
- ✅ Démarrage rapide
- ✅ Messages d'erreur détaillés
- ✅ Un seul processus (facile à déboguer)
- ✅ Logs en temps réel

**Serveur utilisé :** Uvicorn avec `--reload`

## 🏭 Mode Production

```bash
python main.py prod
```

**Avantages :**
- ✅ Multi-processus (utilise tous les CPU)
- ✅ Haute disponibilité
- ✅ Gestion avancée des ressources
- ✅ Optimisé pour les charges élevées
- ✅ Auto-restart des workers défaillants

**Serveur utilisé :** Gunicorn avec workers Uvicorn

## 📋 Comparaison

| Aspect | Développement | Production |
|--------|---------------|------------|
| **Serveur** | Uvicorn | Gunicorn + Uvicorn |
| **Workers** | 1 | Multiple (CPU × 2 + 1) |
| **Reload** | ✅ Automatique | ❌ Redémarrage requis |
| **Performance** | Normale | Optimale |
| **Debugging** | ✅ Facile | Plus complexe |
| **Mémoire** | Faible | Plus élevée |

## 🔧 Configuration d'Environnement

Assurez-vous d'avoir un fichier `.env` avec :

```env
API_PORT=8000
PROJECT_NAME="Mon Projet"
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_KEY=your_service_key
CORS_ORIGINS=http://localhost:3000
```

## 🚨 Recommandations

- **En développement :** Utilisez toujours `uv run main.py dev` ou `uv run main.py`
- **En production :** Utilisez `uv run main.py prod`
- **Tests locaux :** Mode dev suffit largement
- **Serveur de production :** Mode prod obligatoire pour les performances

## 🛑 Migration depuis l'ancien système

L'ancien script `start_gunicorn.sh` a été supprimé, car toute la logique est maintenant dans `main.py`.

```bash
# Ancien (supprimé)
./start_gunicorn.sh dev

# Nouveau (recommandé)
uv run main.py dev
```