"""
Routes de base de l'API
"""
from fastapi import APIRouter
from api.models import HealthCheck

# Créer le routeur pour les routes de base
router = APIRouter(tags=["Base"])


@router.get("/", summary="Root endpoint", description="Basic API endpoint")
def read_root():
    """Point d'entrée de base de l'API"""
    return {"Hello": "World"}


@router.get(
    "/health",
    response_model=HealthCheck,
    summary="Health check",
    description="Check the health status of the API"
)
def health_check():
    """Contrôle de santé de l'API"""
    return HealthCheck(
        status="healthy",
        message="API is running normally"
    )