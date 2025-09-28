"""
Helpers utilitaires pour l'API
"""
import secrets
import string
from typing import Optional


def generate_random_password(length: int = 16) -> str:
    """
    Génère un mot de passe aléatoire pour les utilisateurs OAuth
    
    Args:
        length: Longueur du mot de passe (défaut: 16)
    
    Returns:
        Mot de passe aléatoire sécurisé
    """
    alphabet = string.ascii_letters + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(length))


def construct_full_name(first_name: Optional[str], last_name: Optional[str]) -> str:
    """
    Construit un nom complet à partir du prénom et nom de famille
    
    Args:
        first_name: Prénom
        last_name: Nom de famille
    
    Returns:
        Nom complet formaté
    """
    parts = []
    if first_name:
        parts.append(first_name.strip())
    if last_name:
        parts.append(last_name.strip())
    return " ".join(parts)


def extract_oauth_user_info(provider: str, user_info: dict) -> dict:
    """
    Extrait et normalise les informations utilisateur selon le provider OAuth
    
    Args:
        provider: Provider OAuth ("google" ou "github")
        user_info: Données utilisateur du provider
    
    Returns:
        Dictionnaire avec les informations normalisées
    """
    email = user_info.get("email", "")
    
    if provider == "google":
        first_name = user_info.get("given_name", "")
        last_name = user_info.get("family_name", "")
        full_name = user_info.get("name", construct_full_name(first_name, last_name))
    elif provider == "github":
        # GitHub ne fournit pas forcément given_name/family_name
        name = user_info.get("name", "")
        name_parts = name.split(" ", 1) if name else ["", ""]
        first_name = name_parts[0] if len(name_parts) > 0 else ""
        last_name = name_parts[1] if len(name_parts) > 1 else ""
        full_name = name
    else:
        # Provider non supporté
        first_name = ""
        last_name = ""
        full_name = user_info.get("name", "")
    
    return {
        "email": email,
        "first_name": first_name,
        "last_name": last_name,
        "full_name": full_name
    }