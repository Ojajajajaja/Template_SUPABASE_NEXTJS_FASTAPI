#!/bin/bash

# Script de génération des configurations Nginx
# Ce script lit le fichier .env.config et génère les configurations nginx à la racine du projet

set -e  # Arrêter le script en cas d'erreur

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Déterminer le répertoire racine du projet
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"
SETUP_DIR="$PROJECT_ROOT/.setup"
NGINX_TEMPLATES_DIR="$SETUP_DIR/nginx"
TARGET_NGINX_DIR="$PROJECT_ROOT/nginx"
ENV_CONFIG_FILE="$SETUP_DIR/.env.config"

log_info "=== Génération des configurations Nginx ==="
log_info "Répertoire du projet: $PROJECT_ROOT"
log_info "Répertoire des templates: $NGINX_TEMPLATES_DIR"
log_info "Répertoire de destination: $TARGET_NGINX_DIR"

# Vérifier que le fichier de configuration existe
if [[ ! -f "$ENV_CONFIG_FILE" ]]; then
    log_error "Le fichier de configuration $ENV_CONFIG_FILE n'existe pas"
    log_info "Veuillez copier .env.config.example vers .env.config et le configurer"
    exit 1
fi

# Charger les variables d'environnement
log_info "Chargement de la configuration depuis $ENV_CONFIG_FILE"
source "$ENV_CONFIG_FILE"

# Vérifier que les variables essentielles sont définies
if [[ -z "$FRONTEND_DOMAIN" || -z "$BACKEND_DOMAIN" || -z "$SUPABASE_DOMAIN" ]]; then
    log_error "Les domaines ne sont pas configurés dans le fichier .env.config"
    log_error "Variables manquantes: FRONTEND_DOMAIN, BACKEND_DOMAIN, ou SUPABASE_DOMAIN"
    exit 1
fi

if [[ -z "$FRONTEND_PORT" || -z "$API_PORT" || -z "$KONG_HTTP_PORT" ]]; then
    log_error "Les ports ne sont pas configurés dans le fichier .env.config"
    log_error "Variables manquantes: FRONTEND_PORT, API_PORT, ou KONG_HTTP_PORT"
    exit 1
fi

# Nettoyer les domaines (enlever les guillemets)
FRONTEND_DOMAIN=$(echo "$FRONTEND_DOMAIN" | sed 's/^"\(.*\)"$/\1/')
BACKEND_DOMAIN=$(echo "$BACKEND_DOMAIN" | sed 's/^"\(.*\)"$/\1/')
SUPABASE_DOMAIN=$(echo "$SUPABASE_DOMAIN" | sed 's/^"\(.*\)"$/\1/')

log_info "Configuration détectée:"
log_info "  Frontend: $FRONTEND_DOMAIN:$FRONTEND_PORT"
log_info "  Backend: $BACKEND_DOMAIN:$API_PORT"
log_info "  Supabase: $SUPABASE_DOMAIN:$KONG_HTTP_PORT"

# Créer le répertoire nginx de destination
log_info "Création du répertoire nginx..."
mkdir -p "$TARGET_NGINX_DIR"

# Fonction pour traiter un fichier de template
process_template() {
    local template_file="$1"
    local output_file="$2"
    local service_name="$3"
    
    log_info "Génération de $service_name.conf..."
    
    # Copier le template et remplacer les variables
    sed -e "s/FRONTEND_DOMAIN/$FRONTEND_DOMAIN/g" \
        -e "s/BACKEND_DOMAIN/$BACKEND_DOMAIN/g" \
        -e "s/SUPABASE_DOMAIN/$SUPABASE_DOMAIN/g" \
        -e "s/FRONTEND_PORT/$FRONTEND_PORT/g" \
        -e "s/BACKEND_PORT/$API_PORT/g" \
        -e "s/API_PORT/$API_PORT/g" \
        -e "s/SUPABASE_PORT/$KONG_HTTP_PORT/g" \
        -e "s/KONG_HTTP_PORT/$KONG_HTTP_PORT/g" \
        "$template_file" > "$output_file"
    
    log_success "$service_name.conf généré avec succès"
}

# Traiter chaque fichier de configuration
if [[ -f "$NGINX_TEMPLATES_DIR/frontend.conf" ]]; then
    process_template "$NGINX_TEMPLATES_DIR/frontend.conf" "$TARGET_NGINX_DIR/frontend.conf" "Frontend"
else
    log_warning "Template frontend.conf non trouvé"
fi

if [[ -f "$NGINX_TEMPLATES_DIR/backend.conf" ]]; then
    process_template "$NGINX_TEMPLATES_DIR/backend.conf" "$TARGET_NGINX_DIR/backend.conf" "Backend"
else
    log_warning "Template backend.conf non trouvé"
fi

if [[ -f "$NGINX_TEMPLATES_DIR/supabase.conf" ]]; then
    process_template "$NGINX_TEMPLATES_DIR/supabase.conf" "$TARGET_NGINX_DIR/supabase.conf" "Supabase"
else
    log_warning "Template supabase.conf non trouvé"
fi

# Créer un fichier README dans le dossier nginx
log_success "Configurations Nginx générées avec succès"

log_success "=== Génération terminée avec succès ==="
log_info "Fichiers générés dans: $TARGET_NGINX_DIR"
log_info "- frontend.conf (pour $FRONTEND_DOMAIN)"
log_info "- backend.conf (pour $BACKEND_DOMAIN)"
log_info "- supabase.conf (pour $SUPABASE_DOMAIN)"