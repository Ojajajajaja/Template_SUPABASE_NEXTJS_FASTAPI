"""
Schémas de base de données pour les utilisateurs
"""
from typing import Optional
from datetime import datetime


class UserProfileSchema:
    """
    Schéma pour la table user_profiles dans Supabase
    
    Cette classe définit la structure attendue des données
    dans la table user_profiles de Supabase.
    """
    
    table_name = "user_profiles"
    
    fields = {
        "id": "uuid PRIMARY KEY",  # Référence à auth.users.id
        "first_name": "text",
        "last_name": "text", 
        "full_name": "text",
        "phone": "text",
        "role": "text DEFAULT 'user'",
        "created_at": "timestamp with time zone DEFAULT timezone('utc'::text, now())",
        "updated_at": "timestamp with time zone DEFAULT timezone('utc'::text, now())"
    }
    
    @staticmethod
    def create_table_sql() -> str:
        """Retourne le SQL pour créer la table user_profiles"""
        return f"""
        CREATE TABLE IF NOT EXISTS {UserProfileSchema.table_name} (
            id uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
            first_name text,
            last_name text,
            full_name text,
            phone text,
            role text DEFAULT 'user',
            created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
            updated_at timestamp with time zone DEFAULT timezone('utc'::text, now())
        );
        
        -- Index sur l'email pour les recherches rapides
        CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON {UserProfileSchema.table_name}(role);
        
        -- Trigger pour mettre à jour updated_at automatiquement
        CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = timezone('utc'::text, now());
            RETURN NEW;
        END;
        $$ language 'plpgsql';
        
        CREATE TRIGGER update_user_profiles_updated_at 
            BEFORE UPDATE ON {UserProfileSchema.table_name}
            FOR EACH ROW 
            EXECUTE FUNCTION update_updated_at_column();
        """