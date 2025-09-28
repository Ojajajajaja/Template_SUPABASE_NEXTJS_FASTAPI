# Backend API

Backend restructuré avec une architecture modulaire pour une meilleure maintenabilité et organisation du code.

## Structure

```
backend/
├── api/                    # Code source de l'API
│   ├── helpers/           # Utilitaires et fonctions helper
│   │   ├── auth.py       # Helpers d'authentification
│   │   ├── utils.py      # Utilitaires généraux
│   │   └── __init__.py
│   ├── models/           # Modèles Pydantic
│   │   ├── auth.py       # Modèles d'authentification
│   │   ├── user.py       # Modèles utilisateur
│   │   ├── base.py       # Modèles de base
│   │   └── __init__.py
│   ├── schemas/          # Schémas de base de données
│   │   ├── base.py       # Schémas de base
│   │   ├── user.py       # Schémas utilisateur
│   │   └── __init__.py
│   ├── views/            # Routes et contrôleurs
│   │   ├── auth.py       # Routes d'authentification
│   │   ├── user.py       # Routes utilisateur
│   │   ├── base.py       # Routes de base
│   │   └── __init__.py
│   ├── app.py            # Configuration FastAPI
│   ├── config.py         # Configuration de l'application
│   ├── main.py           # Point d'entrée principal
│   └── __init__.py
├── tests/                # Tests (à développer)
├── run.py               # Script de démarrage simplifié
├── gunicorn.conf.py     # Configuration Gunicorn
├── pyproject.toml       # Dépendances UV
└── README.md            # Ce fichier
```

## Démarrage

### Mode développement (avec rechargement automatique)
```bash
uv run run.py dev
# ou
uv run run.py
```

### Mode production (avec Gunicorn)
```bash
uv run run.py prod
```

### Alternative : utilisation directe
```bash
# Développement
uv run api.main dev

# Production  
uv run api.main prod
```

## Routes disponibles

- `GET /` - Endpoint de base
- `GET /health` - Contrôle de santé
- `POST /api/auth/signup` - Inscription
- `POST /api/auth/login` - Connexion
- `POST /api/auth/oauth/login` - Connexion OAuth
- `GET /api/user/me` - Utilisateur actuel
- `GET /api/user/profile` - Profil utilisateur
- `PUT /api/user/profile` - Mise à jour du profil

## Configuration

Les variables d'environnement sont gérées dans `api/config.py` :

- `PROJECT_NAME` - Nom du projet
- `API_PREFIX` - Préfixe des routes API (défaut: `/api`)
- `API_PORT` - Port du serveur (défaut: `2000`)
- `CORS_ORIGINS` - Origines CORS autorisées
- `SUPABASE_URL` - URL Supabase
- `SUPABASE_ANON_KEY` - Clé anonyme Supabase
- `SUPABASE_SERVICE_KEY` - Clé de service Supabase

## Architecture

### Séparation des responsabilités

1. **Models** (`api/models/`) : Modèles Pydantic pour la validation des données
2. **Views** (`api/views/`) : Routes et logique métier
3. **Helpers** (`api/helpers/`) : Fonctions utilitaires et helpers
4. **Schemas** (`api/schemas/`) : Définitions des schémas de base de données
5. **Config** (`api/config.py`) : Centralisation de la configuration

### Avantages de cette structure

- **Maintenabilité** : Code organisé et modulaire
- **Testabilité** : Modules isolés faciles à tester
- **Évolutivité** : Ajout facile de nouvelles fonctionnalités
- **Réutilisabilité** : Helpers et modèles réutilisables
- **Lisibilité** : Structure claire et logique