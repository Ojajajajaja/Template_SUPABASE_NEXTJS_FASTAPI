"""
Routes d'authentification
"""
from fastapi import APIRouter, HTTPException, status
from supabase_auth import SignUpWithPasswordCredentials

from api.models import SignupData, LoginData, OAuthCredentials, UserResponse, APIResponse, UserProfile
from api.helpers import get_supabase_service_client, generate_random_password, extract_oauth_user_info
from api.config import settings

# Créer le routeur pour l'authentification
router = APIRouter(prefix=f"{settings.API_PREFIX}/auth", tags=["Auth"])


@router.post(
    "/signup",
    response_model=APIResponse,
    summary="User signup",
    description="Register a new user with email, password, first name, last name, and optional phone number"
)
async def signup(signup_data: SignupData):
    """Inscription d'un nouvel utilisateur"""
    try:
        supabase_service = get_supabase_service_client()
        
        # Préparer le nom complet
        full_name = f"{signup_data.first_name} {signup_data.last_name}"
        
        # Créer les credentials d'inscription
        user_credentials: SignUpWithPasswordCredentials = {
            "email": signup_data.email,
            "password": signup_data.password,
            "options": {
                "data": {
                    "first_name": signup_data.first_name,
                    "last_name": signup_data.last_name,
                    "full_name": full_name,
                    "phone": signup_data.phone
                }
            }
        }
        
        user_response = supabase_service.auth.sign_up(user_credentials)
        
        return APIResponse(
            message="User created successfully", 
            data={"user": user_response.user}
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.post(
    "/oauth/login",
    response_model=UserResponse,
    summary="OAuth login",
    description="Log in a user with OAuth provider (Google or GitHub)"
)
async def oauth_login(oauth_data: OAuthCredentials):
    """Connexion OAuth d'un utilisateur"""
    try:
        supabase_service = get_supabase_service_client()
        
        # Extraire les informations utilisateur selon le provider
        user_info = extract_oauth_user_info(oauth_data.provider, oauth_data.user_info)
        email = user_info["email"]
        
        if not email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email not found in OAuth user info"
            )
        
        # Vérifier si l'utilisateur existe déjà
        existing_user = None
        try:
            users_response = supabase_service.auth.admin.list_users()
            if users_response:
                existing_user = next(
                    (user for user in users_response if user.email == email),
                    None
                )
        except Exception:
            pass  # Continue avec la création si la recherche échoue
        
        if existing_user:
            # Utilisateur existant, créer une session
            return UserResponse(
                access_token=f"oauth_temp_token_{existing_user.id}",
                user=existing_user.__dict__,
                profile=UserProfile(
                    id=existing_user.id,
                    email=existing_user.email or "",
                    first_name=user_info["first_name"],
                    last_name=user_info["last_name"],
                    full_name=user_info["full_name"],
                    phone="",
                    role="user",
                    created_at=existing_user.created_at
                )
            )
        else:
            # Nouvel utilisateur, le créer
            random_password = generate_random_password()
            
            user_credentials: SignUpWithPasswordCredentials = {
                "email": email,
                "password": random_password,
                "options": {
                    "data": {
                        "first_name": user_info["first_name"],
                        "last_name": user_info["last_name"],
                        "full_name": user_info["full_name"],
                        "oauth_provider": oauth_data.provider,
                        "oauth_verified": True
                    }
                }
            }
            
            user_response = supabase_service.auth.sign_up(user_credentials)
            
            if not user_response.user:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Failed to create user"
                )
            
            return UserResponse(
                access_token=f"oauth_temp_token_{user_response.user.id}",
                user=user_response.user.__dict__,
                profile=UserProfile(
                    id=user_response.user.id,
                    email=email,
                    first_name=user_info["first_name"],
                    last_name=user_info["last_name"],
                    full_name=user_info["full_name"],
                    phone="",
                    role="user",
                    created_at=user_response.user.created_at
                )
            )
                
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"OAuth login failed: {str(e)}"
        )


@router.post(
    "/login",
    response_model=UserResponse,
    summary="User login",
    description="Log in a user with email and password"
)
async def login(login_data: LoginData):
    """Connexion d'un utilisateur"""
    try:
        supabase_service = get_supabase_service_client()
        response = supabase_service.auth.sign_in_with_password({
            "email": login_data.email,
            "password": login_data.password,
        })
        
        if not response.session or not response.session.access_token:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Login failed"
            )
            
        return UserResponse(
            access_token=response.session.access_token,
            user=response.user.__dict__ if response.user else {}
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )