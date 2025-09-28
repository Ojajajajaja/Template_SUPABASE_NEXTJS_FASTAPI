"""
Modèles de base pour l'API
"""
from pydantic import BaseModel
from typing import Any, Optional


class HealthCheck(BaseModel):
    """Modèle pour le contrôle de santé de l'API"""
    status: str
    message: str


class APIResponse(BaseModel):
    """Modèle de réponse générique pour l'API"""
    message: str
    data: Optional[Any] = None


class ErrorResponse(BaseModel):
    """Modèle de réponse d'erreur"""
    detail: str
    error_code: Optional[str] = None