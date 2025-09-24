#!/bin/bash

# Script principal de déploiement
# Orchestre toutes les tâches de déploiement du template

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Banner
echo -e "${PURPLE}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║                    SCRIPT DE DÉPLOIEMENT                        ║
║              Template Supabase + Next.js + FastAPI             ║
╚══════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Déterminer le répertoire racine du projet
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"
SETUP_DIR="$PROJECT_ROOT/.setup"

log_info "Répertoire du projet: $PROJECT_ROOT"

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  nginx           Générer les configurations Nginx"
    echo "  all             Exécuter toutes les tâches de déploiement"
    echo "  help            Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 nginx        # Générer uniquement les configurations Nginx"
    echo "  $0 all          # Préparer tout pour le déploiement"
    echo ""
}

# Fonction pour générer les configurations Nginx
generate_nginx() {
    log_step "Génération des configurations Nginx"
    
    if [[ -f "$SCRIPT_DIR/generate-nginx-configs.sh" ]]; then
        bash "$SCRIPT_DIR/generate-nginx-configs.sh"
    else
        log_error "Script generate-nginx-configs.sh non trouvé"
        return 1
    fi
}

# Fonction pour vérifier la configuration
check_config() {
    log_step "Vérification de la configuration"
    
    ENV_CONFIG="$SETUP_DIR/.env.config"
    
    if [[ ! -f "$ENV_CONFIG" ]]; then
        log_error "Fichier de configuration manquant: $ENV_CONFIG"
        log_info "Copiez .env.config.example vers .env.config et configurez-le"
        return 1
    fi
    
    log_success "Fichier de configuration trouvé"
    
    # Vérifier les variables essentielles
    source "$ENV_CONFIG"
    
    missing_vars=()
    
    [[ -z "$FRONTEND_DOMAIN" ]] && missing_vars+=("FRONTEND_DOMAIN")
    [[ -z "$BACKEND_DOMAIN" ]] && missing_vars+=("BACKEND_DOMAIN")
    [[ -z "$SUPABASE_DOMAIN" ]] && missing_vars+=("SUPABASE_DOMAIN")
    [[ -z "$FRONTEND_PORT" ]] && missing_vars+=("FRONTEND_PORT")
    [[ -z "$API_PORT" ]] && missing_vars+=("API_PORT")
    [[ -z "$KONG_HTTP_PORT" ]] && missing_vars+=("KONG_HTTP_PORT")
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_error "Variables manquantes dans .env.config:"
        for var in "${missing_vars[@]}"; do
            log_error "  - $var"
        done
        return 1
    fi
    
    log_success "Configuration valide"
}

# Fonction pour afficher le résumé
show_summary() {
    log_step "Résumé du déploiement"
    
    source "$SETUP_DIR/.env.config"
    
    # Nettoyer les domaines
    FRONTEND_DOMAIN=$(echo "$FRONTEND_DOMAIN" | sed 's/^"\(.*\)"$/\1/')
    BACKEND_DOMAIN=$(echo "$BACKEND_DOMAIN" | sed 's/^"\(.*\)"$/\1/')
    SUPABASE_DOMAIN=$(echo "$SUPABASE_DOMAIN" | sed 's/^"\(.*\)"$/\1/')
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                        RÉSUMÉ DU DÉPLOIEMENT                       ║${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${NC} Services configurés:                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}   🌐 Frontend:  https://$FRONTEND_DOMAIN (port $FRONTEND_PORT)${GREEN}$(printf '%*s' $((42 - ${#FRONTEND_DOMAIN} - ${#FRONTEND_PORT})) '')║${NC}"
    echo -e "${GREEN}║${NC}   🔧 Backend:   https://$BACKEND_DOMAIN (port $API_PORT)${GREEN}$(printf '%*s' $((47 - ${#BACKEND_DOMAIN} - ${#API_PORT})) '')║${NC}"
    echo -e "${GREEN}║${NC}   🗄️  Supabase:  https://$SUPABASE_DOMAIN (port $KONG_HTTP_PORT)${GREEN}$(printf '%*s' $((41 - ${#SUPABASE_DOMAIN} - ${#KONG_HTTP_PORT})) '')║${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${NC} Fichiers générés:                                               ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}   📁 nginx/frontend.conf                                        ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}   📁 nginx/backend.conf                                         ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}   📁 nginx/supabase.conf                                        ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}   📁 nginx/install.sh                                           ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}   📁 nginx/README.md                                            ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Prochaines étapes:${NC}"
    echo -e "${YELLOW}1.${NC} Vérifiez les configurations dans le dossier ${BLUE}nginx/${NC}"
    echo -e "${YELLOW}2.${NC} Copiez le dossier sur votre serveur de production"
    echo -e "${YELLOW}3.${NC} Exécutez ${BLUE}sudo ./nginx/install.sh${NC} sur le serveur"
    echo -e "${YELLOW}4.${NC} Configurez SSL avec certbot"
    echo ""
}

# Fonction principale
main() {
    case "${1:-help}" in
        "nginx")
            check_config && generate_nginx && show_summary
            ;;
        "all")
            check_config && generate_nginx && show_summary
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            log_error "Option inconnue: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Exécuter la fonction principale
main "$@"