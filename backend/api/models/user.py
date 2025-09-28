"""
Modèles utilisateur pour l'API
"""
from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class ProfileUpdateData(BaseModel):
    """Modèle pour la mise à jour du profil utilisateur"""
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    full_name: Optional[str] = None
    phone: Optional[str] = None


class UserProfile(BaseModel):
    """Modèle pour le profil utilisateur"""
    id: str
    email: str
    first_name: str
    last_name: str
    full_name: str
    phone: Optional[str] = None
    role: str = "user"
    created_at: datetime


class UserResponse(BaseModel):
    """Modèle de réponse pour les données utilisateur"""
    access_token: str
    user: dict
    profile: Optional[UserProfile] = None