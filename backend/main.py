from fastapi import FastAPI, Depends, HTTPException, status, Body
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from dotenv import load_dotenv
import os
from supabase import create_client, Client
from pydantic import BaseModel
from typing import Optional
from supabase_auth import SignUpWithPasswordCredentials

# Load environment variables
load_dotenv()

# Get project name from environment variables
PROJECT_NAME = os.getenv("PROJECT_NAME", "API Backend")

# Initialize FastAPI application
app = FastAPI(
    title=f"{PROJECT_NAME} API",
    description=f"Backend API for {PROJECT_NAME} with Supabase authentication",
    version="1.0.0"
)

# Security configuration
security = HTTPBearer()

# Supabase configuration
SUPABASE_URL = os.getenv("SUPABASE_URL") or ""
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY") or ""
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY") or ""
API_PREFIX = os.getenv("API_PREFIX") or "/api"
API_PORT = int(os.getenv("API_PORT", "8000"))
CORS_ORIGINS = (os.getenv("CORS_ORIGINS") or "http://localhost:3000").split(",")

# Create Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)

# Security configuration
security = HTTPBearer()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["Access-Control-Allow-Origin"]
)

# Pydantic models
class SignupData(BaseModel):
    email: str
    password: str
    first_name: str
    last_name: str
    phone: Optional[str] = None

class LoginData(BaseModel):
    email: str
    password: str

class ProfileUpdateData(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    full_name: Optional[str] = None
    phone: Optional[str] = None

class OAuthCredentials(BaseModel):
    provider: str  # "google" ou "github"
    token: str
    user_info: dict

# Function to verify JWT token
async def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        # Use service key for backend operations
        supabase_service: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
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

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/health", tags=["Health"], summary="Health check", description="Check the health status of the API")
def health_check():
    return {"status": "healthy", "message": "API is running normally"}

# Authentication route to check if user is logged in
@app.get(
    f"{API_PREFIX}/user/me", 
    dependencies=[Depends(verify_token)],
    tags=["User"],
    summary="Get current user",
    description="Retrieve information of the currently authenticated user"
)
async def get_current_user():
    return {"message": "User is authenticated"}

# Route to get user profile
@app.get(
    f"{API_PREFIX}/user/profile",
    dependencies=[Depends(verify_token)],
    tags=["User"],
    summary="Get user profile",
    description="Retrieve the profile information of the currently authenticated user"
)
async def get_profile(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        # Use service key for backend operations
        supabase_service: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
        
        # Get current user
        user_response = supabase_service.auth.get_user(credentials.credentials)
        if not user_response or not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )
        user_id = user_response.user.id
        
        # Get user profile from user_profiles table
        profile_response = supabase_service.table("user_profiles").select("*").eq("id", user_id).execute()
        
        # Get user metadata from auth table
        user_metadata = user_response.user.user_metadata if user_response.user.user_metadata else {}
        
        # Combine profile data
        profile_data = {
            "id": user_id,
            "email": user_response.user.email,
            "first_name": user_metadata.get("first_name", ""),
            "last_name": user_metadata.get("last_name", ""),
            "full_name": user_metadata.get("full_name", ""),
            "phone": user_metadata.get("phone", ""),
            "role": "user",  # Valeur par défaut
            "created_at": user_response.user.created_at
        }
        
        # If we have profile data from the user_profiles table, merge it
        if profile_response.data:
            profile_data.update(profile_response.data[0])
            
        return profile_data
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

# Route to sign up
@app.post(
    f"{API_PREFIX}/auth/signup",
    tags=["Auth"],
    summary="User signup",
    description="Register a new user with email, password, first name, last name, and optional phone number"
)
async def signup(signup_data: SignupData):
    try:
        # Use service key to create user
        supabase_service: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
        
        # Prepare full name
        full_name = f"{signup_data.first_name} {signup_data.last_name}"
        
        # Sign up the user with metadata
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
        
        return {"message": "User created successfully", "user": user_response.user}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

# Route to log in
@app.post(
    f"{API_PREFIX}/auth/login",
    tags=["Auth"],
    summary="User login",
    description="Log in a user with email and password"
)
async def login(login_data: LoginData):
    try:
        # Use service key to log in user
        supabase_service: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
        response = supabase_service.auth.sign_in_with_password({
            "email": login_data.email,
            "password": login_data.password,
        })
        
        if not response.session or not response.session.access_token:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Login failed"
            )
            
        return {"access_token": response.session.access_token, "user": response.user}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

# Route pour l'authentification OAuth
@app.post(
    f"{API_PREFIX}/auth/oauth/login",
    tags=["Auth"],
    summary="OAuth login",
    description="Log in a user with OAuth provider (Google or GitHub)"
)
async def oauth_login(oauth_data: OAuthCredentials):
    try:
        # Use service key to handle OAuth
        supabase_service: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
        
        # Extract user information from OAuth data
        user_info = oauth_data.user_info
        email = user_info.get("email")
        
        if not email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email not found in OAuth user info"
            )
        
        # Check if user already exists
        existing_user = None
        try:
            # Try to find existing user by email
            users_response = supabase_service.auth.admin.list_users()
            if users_response:
                existing_user = next(
                    (user for user in users_response if user.email == email),
                    None
                )
        except Exception:
            pass  # Continue with user creation if lookup fails
        
        if existing_user:
            # User exists, create a session
            try:
                # Generate a session for existing user
                # Note: Supabase doesn't have direct "sign in as user" method
                # This is a simplified approach - in production, you'd want more robust session management
                
                # For now, we'll create a temporary password and sign them in
                # This is not ideal but works for demonstration
                # In production, use proper OAuth flow with Supabase Auth
                
                # Return user info with a mock token (replace with proper implementation)
                return {
                    "access_token": f"oauth_temp_token_{existing_user.id}", 
                    "user": existing_user,
                    "profile": {
                        "id": existing_user.id,
                        "email": existing_user.email,
                        "first_name": user_info.get("given_name", ""),
                        "last_name": user_info.get("family_name", ""),
                        "full_name": user_info.get("name", ""),
                        "phone": "",
                        "role": "user",
                        "created_at": existing_user.created_at
                    }
                }
            except Exception as e:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Failed to create session for existing user: {str(e)}"
                )
        else:
            # User doesn't exist, create new user
            try:
                # Prepare user data
                first_name = user_info.get("given_name", "")
                last_name = user_info.get("family_name", "")
                full_name = user_info.get("name", f"{first_name} {last_name}".strip())
                
                # Generate a random password for OAuth users
                import secrets
                import string
                random_password = ''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(16))
                
                # Create user with OAuth info
                user_credentials: SignUpWithPasswordCredentials = {
                    "email": email,
                    "password": random_password,
                    "options": {
                        "data": {
                            "first_name": first_name,
                            "last_name": last_name,
                            "full_name": full_name,
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
                
                return {
                    "access_token": f"oauth_temp_token_{user_response.user.id}",
                    "user": user_response.user,
                    "profile": {
                        "id": user_response.user.id,
                        "email": email,
                        "first_name": first_name,
                        "last_name": last_name,
                        "full_name": full_name,
                        "phone": "",
                        "role": "user",
                        "created_at": user_response.user.created_at
                    }
                }
                
            except Exception as e:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Failed to create OAuth user: {str(e)}"
                )
                
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"OAuth login failed: {str(e)}"
        )

# Route to update user profile
@app.put(
    f"{API_PREFIX}/user/profile",
    dependencies=[Depends(verify_token)],
    tags=["User"],
    summary="Update user profile",
    description="Update the profile information of the currently authenticated user"
)
async def update_profile(profile_data: ProfileUpdateData, credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        # Use service key for backend operations
        supabase_service: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
        
        # Get current user
        user_response = supabase_service.auth.get_user(credentials.credentials)
        if not user_response or not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )
        user_id = user_response.user.id
        
        # Prepare update data
        update_data = {}
        if profile_data.first_name is not None:
            update_data["first_name"] = profile_data.first_name
        if profile_data.last_name is not None:
            update_data["last_name"] = profile_data.last_name
        if profile_data.full_name is not None:
            update_data["full_name"] = profile_data.full_name
        if profile_data.phone is not None:
            update_data["phone"] = profile_data.phone
            
        # If full_name is not provided but first_name or last_name is, construct it
        if "full_name" not in update_data and ("first_name" in update_data or "last_name" in update_data):
            # Get current user data to fill missing fields
            current_user_data = supabase_service.table("user_profiles").select("*").eq("id", user_id).execute()
            if current_user_data.data:
                current_data = current_user_data.data[0]
                first_name = update_data.get("first_name", current_data.get("first_name", ""))
                last_name = update_data.get("last_name", current_data.get("last_name", ""))
                update_data["full_name"] = f"{first_name} {last_name}".strip()
        
        # Update user metadata in auth table
        if update_data:
            # Update user metadata
            supabase_service.auth.update_user({
                "data": update_data
            })
            
            # Update user profile in user_profiles table
            supabase_service.table("user_profiles").update(update_data).eq("id", user_id).execute()
        
        return {"message": "Profile updated successfully"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

# Application instance pour Gunicorn
app_instance = app

def run_development():
    """Lance le serveur en mode développement avec uvicorn et rechargement automatique"""
    print("🚀 Démarrage en mode DÉVELOPPEMENT")
    print("================================================")
    print(f"Host: 0.0.0.0")
    print(f"Port: {API_PORT}")
    print("Mode: Développement (rechargement automatique)")
    print("================================================")
    
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=API_PORT,
        reload=True,
        log_level="info"
    )

def run_production():
    """Lance le serveur en mode production avec Gunicorn"""
    import subprocess
    import sys
    
    print("🚀 Démarrage en mode PRODUCTION")
    print("================================================")
    print(f"Host: 0.0.0.0")
    print(f"Port: {API_PORT}")
    print("Mode: Production (Gunicorn + workers multiples)")
    print("================================================")
    
    # Commande Gunicorn avec uv
    cmd = [
        "uv", "run",
        "gunicorn",
        "main:app",
        "--config", "gunicorn.conf.py",
        "--bind", f"0.0.0.0:{API_PORT}"
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
    import sys
    
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
            print("  uv run main.py dev         # Mode développement")
            print("  uv run main.py prod        # Mode production")
            print("  uv run main.py             # Mode développement (défaut)")
            sys.exit(1)
    else:
        print("❌ Trop d'arguments. Utilisez:")
        print("  uv run main.py dev         # Mode développement")
        print("  uv run main.py prod        # Mode production")
        print("  uv run main.py             # Mode développement (défaut)")
        sys.exit(1)