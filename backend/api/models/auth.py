"""
Modèles d'authentification pour l'API
"""
from pydantic import BaseModel
from typing import Optional


class SignupData(BaseModel):
    """Modèle pour l'inscription d'un utilisateur"""
    email: str
    password: str
    first_name: str
    last_name: str
    phone: Optional[str] = None


class LoginData(BaseModel):
    """Modèle pour la connexion d'un utilisateur"""
    email: str
    password: str


class OAuthCredentials(BaseModel):
    """Modèle pour l'authentification OAuth"""
    provider: str  # "google" ou "github"
    token: str
    user_info: dict