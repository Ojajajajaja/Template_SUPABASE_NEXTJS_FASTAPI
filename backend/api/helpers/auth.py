"""
Helpers pour l'authentification Supabase
"""
from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from supabase import create_client, Client
from api.config import settings

# Configuration de sécurité
security = HTTPBearer()


def get_supabase_client() -> Client:
    """Retourne un client Supabase avec la clé anonyme"""
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_ANON_KEY)


def get_supabase_service_client() -> Client:
    """Retourne un client Supabase avec la clé de service (pour les opérations backend)"""
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_KEY)


async def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Vérifie le token JWT et retourne les informations utilisateur
    """
    try:
        supabase_service = get_supabase_service_client()
        user_response = supabase_service.auth.get_user(credentials.credentials)
        
        if not user_response or not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return user_response
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )