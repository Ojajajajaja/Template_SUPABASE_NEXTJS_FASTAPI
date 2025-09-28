"""
Application FastAPI principale
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.config import settings
from api.views import auth_router, user_router, base_router


def create_app() -> FastAPI:
    """
    Créer et configurer l'application FastAPI
    
    Returns:
        Application FastAPI configurée
    """
    # Valider les variables d'environnement
    settings.validate_env_vars()
    
    # Créer l'instance FastAPI
    app = FastAPI(
        title=f"{settings.PROJECT_NAME} API",
        description=settings.DESCRIPTION,
        version=settings.VERSION
    )
    
    # Ajouter le middleware CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
        expose_headers=["Access-Control-Allow-Origin"]
    )
    
    # Enregistrer les routeurs
    app.include_router(base_router)
    app.include_router(auth_router)
    app.include_router(user_router)
    
    return app


# Instance de l'application pour Gunicorn
app = create_app()