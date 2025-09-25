#!/bin/bash

# Script d'aide pour continuer après le déplacement du projet
# Ce script guide l'utilisateur pour reprendre le workflow après déplacement

set -e

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Récupérer les paramètres
NEW_PROJECT_PATH="$1"
PROD_USERNAME="$2"

if [[ -z "$NEW_PROJECT_PATH" || -z "$PROD_USERNAME" ]]; then
    echo "Usage: $0 <new_project_path> <prod_username>"
    exit 1
fi

echo "=========================================="
echo "   CONTINUATION APRÈS DÉPLACEMENT"
echo "=========================================="
echo ""

log_info "Le projet a été déplacé vers: $NEW_PROJECT_PATH"
log_info "Utilisateur de production créé: $PROD_USERNAME"
echo ""

log_warning "IMPORTANT: Vous devez maintenant continuer depuis le nouveau répertoire!"
echo ""

echo "Choisissez une option pour continuer:"
echo ""
echo "1) Continuer en tant qu'utilisateur de production (recommandé)"
echo "   - Se connecter automatiquement avec l'utilisateur $PROD_USERNAME"
echo "   - Continuer le workflow depuis le répertoire du projet"
echo "   - Session sudo déjà initialisée (pas de mot de passe requis)"
echo ""
echo "2) Continuer en tant qu'utilisateur actuel"
echo "   - Naviguer manuellement vers le nouveau répertoire"
echo "   - Continuer le workflow avec l'utilisateur actuel"
echo ""

read -p "Votre choix (1 ou 2): " choice

case $choice in
    1)
        log_info "Connexion en tant qu'utilisateur de production..."
        log_info "Vous allez être connecté en tant que $PROD_USERNAME"
        log_info "Le projet sera automatiquement accessible"
        log_success "Session sudo déjà initialisée - pas de mot de passe requis !"
        echo ""
        log_success "Exécution: su - $PROD_USERNAME"
        echo ""
        
        # Se connecter en tant qu'utilisateur de production
        exec su - "$PROD_USERNAME"
        ;;
    2)
        log_info "Navigation vers le nouveau répertoire..."
        log_warning "Vous devez maintenant exécuter:"
        echo ""
        echo "  cd $NEW_PROJECT_PATH"
        echo "  make build    # Continuer avec le build"
        echo "  make deploy   # Puis le déploiement"
        echo ""
        log_info "Ou pour faire tout d'un coup:"
        echo "  cd $NEW_PROJECT_PATH && make build && make deploy"
        echo ""
        
        # Changer vers le nouveau répertoire
        cd "$NEW_PROJECT_PATH"
        
        # Lancer un nouveau shell dans le bon répertoire
        echo "Lancement d'un nouveau shell dans le répertoire du projet..."
        exec $SHELL
        ;;
    *)
        log_warning "Choix invalide. Vous devrez naviguer manuellement vers:"
        echo "  cd $NEW_PROJECT_PATH"
        echo ""
        exit 1
        ;;
esac