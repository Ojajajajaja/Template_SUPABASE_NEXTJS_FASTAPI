// Configuration du frontend
// Chargement des variables d'environnement depuis .env.local

export const config = {
  projectName: process.env.NEXT_PUBLIC_PROJECT_NAME || 'TheSuperProject',
  apiPrefix: process.env.NEXT_PUBLIC_API_PREFIX || '/api/v1',
  apiUrl: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:2000',
  frontendPort: process.env.NEXT_FRONTEND_PORT || '3000',
};

export default config;