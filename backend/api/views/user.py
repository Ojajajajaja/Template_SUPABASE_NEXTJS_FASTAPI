"""
Routes utilisateur
"""
from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPAuthorizationCredentials

from api.models import ProfileUpdateData, UserProfile, APIResponse
from api.helpers import verify_token, get_supabase_service_client, security
from api.config import settings

# Créer le routeur pour les utilisateurs
router = APIRouter(prefix=f"{settings.API_PREFIX}/user", tags=["User"])


@router.get(
    "/me",
    dependencies=[Depends(verify_token)],
    response_model=APIResponse,
    summary="Get current user",
    description="Retrieve information of the currently authenticated user"
)
async def get_current_user():
    """Vérifier si l'utilisateur est authentifié"""
    return APIResponse(message="User is authenticated")


@router.get(
    "/profile",
    dependencies=[Depends(verify_token)],
    response_model=UserProfile,
    summary="Get user profile",
    description="Retrieve the profile information of the currently authenticated user"
)
async def get_profile(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Récupérer le profil de l'utilisateur actuel"""
    try:
        supabase_service = get_supabase_service_client()
        
        # Récupérer l'utilisateur actuel
        user_response = supabase_service.auth.get_user(credentials.credentials)
        if not user_response or not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )
        user_id = user_response.user.id
        
        # Récupérer le profil depuis la table user_profiles
        profile_response = supabase_service.table("user_profiles").select("*").eq("id", user_id).execute()
        
        # Récupérer les métadonnées utilisateur depuis auth
        user_metadata = user_response.user.user_metadata if user_response.user.user_metadata else {}
        
        # Combiner les données de profil
        profile_data = {
            "id": user_id,
            "email": user_response.user.email or "",
            "first_name": user_metadata.get("first_name", ""),
            "last_name": user_metadata.get("last_name", ""),
            "full_name": user_metadata.get("full_name", ""),
            "phone": user_metadata.get("phone", ""),
            "role": "user",
            "created_at": user_response.user.created_at
        }
        
        # Si on a des données de profil depuis user_profiles, les fusionner
        if profile_response.data:
            profile_data.update(profile_response.data[0])
            
        return UserProfile(**profile_data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.put(
    "/profile",
    dependencies=[Depends(verify_token)],
    response_model=APIResponse,
    summary="Update user profile",
    description="Update the profile information of the currently authenticated user"
)
async def update_profile(
    profile_data: ProfileUpdateData, 
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Mettre à jour le profil de l'utilisateur"""
    try:
        supabase_service = get_supabase_service_client()
        
        # Récupérer l'utilisateur actuel
        user_response = supabase_service.auth.get_user(credentials.credentials)
        if not user_response or not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )
        user_id = user_response.user.id
        
        # Préparer les données de mise à jour
        update_data = {}
        if profile_data.first_name is not None:
            update_data["first_name"] = profile_data.first_name
        if profile_data.last_name is not None:
            update_data["last_name"] = profile_data.last_name
        if profile_data.full_name is not None:
            update_data["full_name"] = profile_data.full_name
        if profile_data.phone is not None:
            update_data["phone"] = profile_data.phone
            
        # Si full_name n'est pas fourni mais first_name ou last_name l'est, le construire
        if "full_name" not in update_data and ("first_name" in update_data or "last_name" in update_data):
            # Récupérer les données actuelles pour compléter les champs manquants
            current_user_data = supabase_service.table("user_profiles").select("*").eq("id", user_id).execute()
            if current_user_data.data:
                current_data = current_user_data.data[0]
                first_name = update_data.get("first_name", current_data.get("first_name", ""))
                last_name = update_data.get("last_name", current_data.get("last_name", ""))
                update_data["full_name"] = f"{first_name} {last_name}".strip()
        
        # Mettre à jour les métadonnées utilisateur dans auth
        if update_data:
            supabase_service.auth.update_user({
                "data": update_data
            })
            
            # Mettre à jour le profil utilisateur dans user_profiles
            supabase_service.table("user_profiles").update(update_data).eq("id", user_id).execute()
        
        return APIResponse(message="Profile updated successfully")
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )