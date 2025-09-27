#!/bin/bash

# Script de démarrage Gunicorn pour la production
# Ce script configure et démarre le serveur FastAPI avec Gunicorn

set -e

# Configuration par défaut
DEFAULT_HOST="0.0.0.0"
DEFAULT_PORT="8000"
DEFAULT_WORKERS="auto"

# Charger les variables d'environnement
if [ -f ".env" ]; then
    echo "📋 Chargement des variables d'environnement..."
    export $(cat .env | grep -v '^#' | xargs)
fi

# Configuration du serveur
HOST=${HOST:-$DEFAULT_HOST}
PORT=${API_PORT:-$DEFAULT_PORT}
WORKERS=${GUNICORN_WORKERS:-$DEFAULT_WORKERS}

echo "🚀 Démarrage du serveur FastAPI avec Gunicorn"
echo "=================================================="
echo "Host: $HOST"
echo "Port: $PORT"
echo "Workers: $WORKERS"
echo "Configuration: gunicorn.conf.py"
echo "=================================================="

# Vérifier si le fichier de configuration existe
if [ ! -f "gunicorn.conf.py" ]; then
    echo "❌ Fichier de configuration gunicorn.conf.py introuvable!"
    exit 1
fi

# Vérifier si l'application FastAPI existe
if [ ! -f "main.py" ]; then
    echo "❌ Fichier main.py introuvable!"
    exit 1
fi

# Démarrer Gunicorn
echo "🔄 Démarrage de Gunicorn..."

# Mode de démarrage selon l'argument
case "${1:-start}" in
    "start")
        exec gunicorn main:app \
            --config gunicorn.conf.py \
            --bind $HOST:$PORT \
            ${WORKERS:+--workers $WORKERS}
        ;;
    "dev")
        echo "🔧 Mode développement avec rechargement automatique"
        exec gunicorn main:app \
            --config gunicorn.conf.py \
            --bind $HOST:$PORT \
            --workers 1 \
            --reload \
            --access-logfile - \
            --error-logfile -
        ;;
    "test")
        echo "🧪 Test de la configuration Gunicorn"
        gunicorn main:app \
            --config gunicorn.conf.py \
            --bind $HOST:$PORT \
            --check-config
        echo "✅ Configuration valide!"
        ;;
    *)
        echo "Usage: $0 [start|dev|test]"
        echo "  start - Démarrage en mode production (défaut)"
        echo "  dev   - Démarrage en mode développement avec reload"
        echo "  test  - Test de la configuration"
        exit 1
        ;;
esac