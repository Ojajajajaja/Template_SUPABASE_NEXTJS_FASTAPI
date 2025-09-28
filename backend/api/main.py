"""
Point d'entrée principal de l'API
"""
import uvicorn
import subprocess
import sys

from api.app import app
from api.config import settings


def run_development():
    """Lance le serveur en mode développement avec uvicorn et rechargement automatique"""
    print("🚀 Démarrage en mode DÉVELOPPEMENT")
    print("================================================")
    print(f"Host: 0.0.0.0")
    print(f"Port: {settings.API_PORT}")
    print("Mode: Développement (rechargement automatique)")
    print("================================================")
    
    uvicorn.run(
        "api.app:app",
        host="0.0.0.0",
        port=settings.API_PORT,
        reload=True,
        log_level="info"
    )


def run_production():
    """Lance le serveur en mode production avec Gunicorn"""
    print("🚀 Démarrage en mode PRODUCTION")
    print("================================================")
    print(f"Host: 0.0.0.0")
    print(f"Port: {settings.API_PORT}")
    print("Mode: Production (Gunicorn + workers multiples)")
    print("================================================")
    
    # Commande Gunicorn avec uv
    cmd = [
        "uv", "run",
        "gunicorn",
        "api.app:app",
        "--config", "gunicorn.conf.py",
        "--bind", f"0.0.0.0:{settings.API_PORT}"
    ]
    
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"❌ Erreur lors du démarrage de Gunicorn: {e}")
        sys.exit(1)
    except FileNotFoundError:
        print("❌ uv ou Gunicorn n'est pas installé. Vérifiez votre installation.")
        sys.exit(1)


if __name__ == "__main__":
    # Si aucun argument, démarrer en mode développement par défaut
    if len(sys.argv) == 1:
        run_development()
    elif len(sys.argv) == 2:
        mode = sys.argv[1].lower()
        if mode in ["dev", "development"]:
            run_development()
        elif mode in ["prod", "production"]:
            run_production()
        else:
            print("❌ Mode non reconnu. Utilisez:")
            print("  uv run api.main dev         # Mode développement")
            print("  uv run api.main prod        # Mode production")
            print("  uv run api.main             # Mode développement (défaut)")
            sys.exit(1)
    else:
        print("❌ Trop d'arguments. Utilisez:")
        print("  uv run api.main dev         # Mode développement")
        print("  uv run api.main prod        # Mode production")
        print("  uv run api.main             # Mode développement (défaut)")
        sys.exit(1)