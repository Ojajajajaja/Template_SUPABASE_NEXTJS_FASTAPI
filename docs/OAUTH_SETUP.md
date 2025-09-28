# Configuration OAuth pour Google et GitHub

Ce guide explique comment configurer l'authentification OAuth avec Google et GitHub dans votre application.

## Configuration Google OAuth

### 1. Créer un projet Google Cloud

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un nouveau projet ou sélectionnez un projet existant
3. Activez l'API Google+ dans la bibliothèque d'API

### 2. Configurer l'écran de consentement OAuth

1. Dans la console Google Cloud, allez dans "API et services" > "Écran de consentement OAuth"
2. Choisissez "Externe" comme type d'utilisateur
3. Remplissez les informations requises :
   - Nom de l'application
   - E-mail de support utilisateur
   - Domaine autorisé (votre domaine)
   - E-mail de contact du développeur

### 3. Créer des identifiants OAuth 2.0

1. Allez dans "API et services" > "Identifiants"
2. Cliquez sur "Créer des identifiants" > "ID client OAuth 2.0"
3. Sélectionnez "Application Web"
4. Ajoutez les URI de redirection autorisées :
   - Pour le développement : `http://localhost:3000`
   - Pour la production : `https://votredomaine.com`
5. Copiez le Client ID

### 4. Configuration dans l'application

Ajoutez dans votre fichier `.env.local` :
```env
NEXT_PUBLIC_GOOGLE_CLIENT_ID=votre_google_client_id_ici
```

## Configuration GitHub OAuth

### 1. Créer une application GitHub OAuth

1. Allez sur [GitHub Developer Settings](https://github.com/settings/developers)
2. Cliquez sur "New OAuth App"
3. Remplissez les informations :
   - **Application name** : Nom de votre application
   - **Homepage URL** : `http://localhost:3000` (dev) ou votre domaine (prod)
   - **Authorization callback URL** : `http://localhost:3000/auth/callback/github`
4. Cliquez sur "Register application"
5. Copiez le Client ID et générez un Client Secret

### 2. Configuration dans l'application

Ajoutez dans votre fichier `.env.local` :
```env
NEXT_PUBLIC_GITHUB_CLIENT_ID=votre_github_client_id_ici
GITHUB_CLIENT_SECRET=votre_github_client_secret_ici
```

## Configuration Backend (FastAPI)

Votre backend FastAPI doit également supporter l'authentification OAuth. Ajoutez ces endpoints :

### Endpoint pour Google OAuth
```python
@app.post("/auth/oauth/login")
async def oauth_login(credentials: OAuthCredentials):
    # Valider le token Google/GitHub
    # Créer ou récupérer l'utilisateur
    # Retourner un JWT token
    pass
```

### Structure des données OAuth
```python
class OAuthCredentials(BaseModel):
    provider: str  # "google" ou "github"
    token: str
    user_info: dict
```

## Variables d'environnement complètes

Votre fichier `.env.local` devrait contenir :

```env
# Configuration OAuth
NEXT_PUBLIC_GOOGLE_CLIENT_ID=votre_google_client_id_ici
NEXT_PUBLIC_GITHUB_CLIENT_ID=votre_github_client_id_ici
GITHUB_CLIENT_SECRET=votre_github_client_secret_ici

# Configuration API
NEXT_PUBLIC_API_URL=http://localhost:8000
```

## Fonctionnalités implémentées

✅ **Google OAuth**
- Bouton de connexion Google intégré
- Gestion automatique du flow OAuth
- Extraction des informations utilisateur

✅ **GitHub OAuth**
- Bouton de connexion GitHub
- Page de callback pour traiter la réponse
- API route pour échanger le code contre un token

✅ **Interface utilisateur**
- Boutons OAuth intégrés dans la page de connexion
- Gestion des erreurs
- États de chargement

✅ **Sécurité**
- Validation des tokens côté client
- Protection CSRF pour GitHub
- Gestion sécurisée des secrets

## Utilisation

Une fois configuré, les utilisateurs pourront :

1. Cliquer sur "Continuer avec Google" pour une connexion rapide avec Google
2. Cliquer sur "Continuer avec GitHub" pour une connexion avec GitHub
3. Les informations seront automatiquement récupérées et l'utilisateur sera connecté

## Dépannage

### Erreur "Google Client ID not configured"
- Vérifiez que `NEXT_PUBLIC_GOOGLE_CLIENT_ID` est défini dans `.env.local`
- Redémarrez le serveur de développement

### Erreur GitHub OAuth
- Vérifiez que l'URL de callback correspond exactement
- Assurez-vous que `GITHUB_CLIENT_SECRET` est défini côté serveur
- Vérifiez les paramètres de votre application GitHub

### Problèmes de redirection
- Vérifiez que les URLs de redirection sont correctement configurées
- En production, utilisez HTTPS pour les callbacks