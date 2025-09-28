"""
Schémas de base pour l'application
"""


class BaseSchema:
    """
    Classe de base pour tous les schémas de base de données
    """
    
    @staticmethod
    def get_common_fields() -> dict:
        """Retourne les champs communs à toutes les tables"""
        return {
            "created_at": "timestamp with time zone DEFAULT timezone('utc'::text, now())",
            "updated_at": "timestamp with time zone DEFAULT timezone('utc'::text, now())"
        }
    
    @staticmethod
    def get_update_trigger_sql(table_name: str) -> str:
        """Retourne le SQL pour créer un trigger de mise à jour automatique"""
        return f"""
        CREATE TRIGGER update_{table_name}_updated_at 
            BEFORE UPDATE ON {table_name}
            FOR EACH ROW 
            EXECUTE FUNCTION update_updated_at_column();
        """