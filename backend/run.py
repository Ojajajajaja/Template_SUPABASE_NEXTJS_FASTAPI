"""
Script de démarrage simplifié pour le backend
"""
import sys
from api.main import run_development, run_production


def main():
    """Point d'entrée principal"""
    if len(sys.argv) == 1:
        # Mode développement par défaut
        run_development()
    elif len(sys.argv) == 2:
        mode = sys.argv[1].lower()
        if mode in ["dev", "development"]:
            run_development()
        elif mode in ["prod", "production"]:
            run_production()
        else:
            print("❌ Mode non reconnu. Utilisez:")
            print("  uv run run.py dev         # Mode développement")
            print("  uv run run.py prod        # Mode production")
            print("  uv run run.py             # Mode développement (défaut)")
            sys.exit(1)
    else:
        print("❌ Trop d'arguments. Utilisez:")
        print("  uv run run.py dev         # Mode développement")
        print("  uv run run.py prod        # Mode production")
        print("  uv run run.py             # Mode développement (défaut)")
        sys.exit(1)


if __name__ == "__main__":
    main()