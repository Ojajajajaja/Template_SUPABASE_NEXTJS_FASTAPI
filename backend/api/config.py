"""
Configuration de l'application FastAPI
"""
import os
from typing import List
from dotenv import load_dotenv

# Charger les variables d'environnement
load_dotenv()


class Settings:
    """Configuration de l'application"""
    
    # Informations de l'application
    PROJECT_NAME: str = os.getenv("PROJECT_NAME", "API Backend")
    VERSION: str = "1.0.0"
    DESCRIPTION: str = f"Backend API for {PROJECT_NAME} with Supabase authentication"
    
    # Configuration API
    API_PREFIX: str = os.getenv("API_PREFIX", "/api")
    API_PORT: int = int(os.getenv("API_PORT", "8000"))
    
    # Configuration CORS
    CORS_ORIGINS: List[str] = (os.getenv("CORS_ORIGINS", "http://localhost:3000")).split(",")
    
    # Configuration Supabase
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_ANON_KEY: str = os.getenv("SUPABASE_ANON_KEY", "")
    SUPABASE_SERVICE_KEY: str = os.getenv("SUPABASE_SERVICE_KEY", "")
    
    # Validation des variables d'environnement critiques
    def validate_env_vars(self) -> None:
        """Valide que toutes les variables d'environnement critiques sont définies"""
        required_vars = {
            "SUPABASE_URL": self.SUPABASE_URL,
            "SUPABASE_ANON_KEY": self.SUPABASE_ANON_KEY,
            "SUPABASE_SERVICE_KEY": self.SUPABASE_SERVICE_KEY,
        }
        
        missing_vars = [var for var, value in required_vars.items() if not value]
        
        if missing_vars:
            raise ValueError(
                f"Variables d'environnement manquantes : {', '.join(missing_vars)}"
            )


# Instance globale des paramètres
settings = Settings()