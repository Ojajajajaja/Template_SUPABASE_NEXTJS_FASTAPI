# API views package
from .auth import router as auth_router
from .user import router as user_router
from .base import router as base_router

__all__ = [
    "auth_router",
    "user_router", 
    "base_router"
]