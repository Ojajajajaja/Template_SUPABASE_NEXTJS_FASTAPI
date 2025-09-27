# Guide de Sauvegarde Supabase

Ce template inclut un système complet de sauvegarde pour vos bases de données Supabase, permettant de copier entièrement l'état d'une base de données avec ses buckets et toutes ses configurations.

## 🎯 Fonctionnalités

### Deux modes de sauvegarde

1. **Mode Schéma seulement** (`--schema-only`)
   - Structure des tables, vues, séquences
   - Fonctions personnalisées
   - Politiques RLS (Row Level Security)
   - Triggers et contraintes
   - Configuration des buckets Storage
   - Politiques de sécurité Storage

2. **Mode Complet** (`--with-data`)
   - Tout ce qui est inclus dans le mode schéma
   - **+ Données de toutes les tables**

### Sortie organisée

Chaque sauvegarde génère :
- **Fichiers SQL séparés** pour une restauration modulaire
- **Script de restauration automatique** (`restore.sh`)
- **Archive compressée** pour le stockage/transfert
- **Documentation complète** (README.md)

## 🚀 Utilisation

### Via Makefile (Recommandé)

```bash
# Sauvegarde du schéma uniquement
make supabase-backup-schema

# Sauvegarde complète (schéma + données)
make supabase-backup-full
```

### Via script direct

```bash
# Schéma seulement
./.setup/scripts/supabase-backup.sh --schema-only

# Schéma + données
./.setup/scripts/supabase-backup.sh --with-data

# Avec options personnalisées
./.setup/scripts/supabase-backup.sh --with-data --output ./mes-sauvegardes
```

## ⚙️ Configuration

### Variables d'environnement (Recommandé)

```bash
export SUPABASE_URL="https://xxxxx.supabase.co"
export SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
export DB_PASSWORD="your-db-password"
```

### Fichier de configuration

Le script lit automatiquement le fichier `supabase/.env` s'il existe.

### Configuration interactive

Si les variables ne sont pas définies, le script vous demandera les informations nécessaires.

## 📁 Structure de sauvegarde

```
backups/
└── supabase_backup_20241227_143052/
    ├── 01_schema.sql              # Structure de la base
    ├── 02_functions.sql           # Fonctions personnalisées
    ├── 03_rls_policies.sql        # Politiques RLS
    ├── 04_triggers.sql            # Triggers
    ├── 05_data.sql                # Données (mode complet uniquement)
    ├── 06_storage_config.sql      # Configuration Storage
    ├── 07_storage_policies.sql    # Politiques Storage
    ├── storage_buckets_info.json  # Métadonnées des buckets
    ├── restore.sh                 # Script de restauration
    └── README.md                  # Documentation
```

## 🔄 Restauration

### Restauration automatique

```bash
# Extraire l'archive
tar -xzf supabase_backup_20241227_143052.tar.gz

# Restaurer
cd supabase_backup_20241227_143052
./restore.sh "postgresql://postgres:password@localhost:5432/postgres"
```

### Restauration manuelle

```bash
# 1. Restaurer le schéma
psql "postgresql://..." < 01_schema.sql

# 2. Restaurer les fonctions
psql "postgresql://..." < 02_functions.sql

# 3. Restaurer les politiques RLS
psql "postgresql://..." < 03_rls_policies.sql

# 4. Restaurer les triggers
psql "postgresql://..." < 04_triggers.sql

# 5. Restaurer les données (si disponibles)
psql "postgresql://..." < 05_data.sql

# 6. Restaurer la configuration Storage
psql "postgresql://..." < 06_storage_config.sql

# 7. Restaurer les politiques Storage
psql "postgresql://..." < 07_storage_policies.sql
```

## 🛠️ Prérequis

### Outils requis

- **Docker** : Pour exécuter pg_dump/psql
- **curl** : Pour l'API Supabase
- **jq** : Pour traiter les données JSON
- **bash** : Version 4.0+ recommandée

### Permissions nécessaires

- Accès à la base de données avec privilèges SUPERUSER
- Clé API Supabase valide
- Accès réseau vers votre instance Supabase

## 🔧 Options avancées

### Toutes les options disponibles

```bash
./.setup/scripts/supabase-backup.sh [OPTIONS]

Options:
  -h, --help              Afficher l'aide
  -s, --schema-only       Sauvegarder seulement le schéma
  -d, --with-data         Sauvegarder le schéma + données
  -o, --output DIR        Répertoire de sortie (défaut: backups)
  -u, --url URL           URL de la base Supabase
  -k, --key KEY           Clé API Supabase
  -p, --password PASS     Mot de passe de la base
```

### Exemples d'utilisation avancée

```bash
# Sauvegarde avec paramètres personnalisés
./.setup/scripts/supabase-backup.sh \
  --with-data \
  --output "/chemin/vers/sauvegardes" \
  --url "https://xxxxx.supabase.co" \
  --key "eyJhbGciO..." \
  --password "mon-mot-de-passe"

# Sauvegarde programmée (cron)
0 2 * * * cd /chemin/vers/projet && make supabase-backup-schema
```

## 🚨 Notes importantes

### Sécurité

- **Stockage sécurisé** : Les sauvegardes contiennent des données sensibles
- **Chiffrement** : Considérez chiffrer les archives avant stockage
- **Accès** : Limitez l'accès aux fichiers de sauvegarde

### Limitations

- **Fichiers Storage** : Les fichiers dans les buckets ne sont pas sauvegardés
- **Extensions** : Les extensions Supabase sont gérées automatiquement
- **Utilisateurs** : Les utilisateurs auth ne sont pas inclus

### Performance

- **Grandes bases** : Le mode avec données peut être lent sur de grandes bases
- **Réseau** : Une connexion stable est requise
- **Espace** : Prévoyez suffisamment d'espace disque

## 🔍 Dépannage

### Erreurs courantes

1. **Erreur de connexion**
   ```
   Solution: Vérifiez l'URL et les identifiants
   ```

2. **Permissions insuffisantes**
   ```
   Solution: Utilisez un utilisateur avec privilèges SUPERUSER
   ```

3. **Timeout de connexion**
   ```
   Solution: Vérifiez la connectivité réseau
   ```

4. **Espace disque insuffisant**
   ```
   Solution: Libérez de l'espace ou changez le répertoire de sortie
   ```

### Debug

Pour plus de détails sur les erreurs :

```bash
# Activer le mode verbose
export DEBUG=1
./.setup/scripts/supabase-backup.sh --with-data
```

## 📚 Intégration dans votre workflow

### CI/CD

```yaml
# Exemple GitHub Actions
- name: Backup Supabase
  run: |
    export SUPABASE_URL="${{ secrets.SUPABASE_URL }}"
    export SUPABASE_ANON_KEY="${{ secrets.SUPABASE_ANON_KEY }}"
    export DB_PASSWORD="${{ secrets.DB_PASSWORD }}"
    make supabase-backup-full
```

### Scripts de maintenance

```bash
#!/bin/bash
# backup-daily.sh
cd /chemin/vers/projet
make supabase-backup-schema

# Nettoyer les sauvegardes anciennes (garde 7 jours)
find backups/ -name "supabase_backup_*" -mtime +7 -exec rm -rf {} \;
```

## 🆕 Migration entre environnements

Le script est particulièrement utile pour :

- **Dev → Staging** : Copier la structure avec quelques données de test
- **Staging → Prod** : Migration du schéma uniquement
- **Backup → Restore** : Sauvegarde régulière et restauration d'urgence
- **Multi-région** : Synchronisation entre différentes instances

---

Pour plus d'informations, consultez le README.md généré avec chaque sauvegarde ou contactez l'équipe de développement.