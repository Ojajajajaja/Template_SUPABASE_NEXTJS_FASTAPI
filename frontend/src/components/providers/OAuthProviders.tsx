'use client';

import { GoogleOAuthProvider } from '@react-oauth/google';
import { ReactNode } from 'react';

interface OAuthProvidersProps {
  children: ReactNode;
}

export function OAuthProviders({ children }: OAuthProvidersProps) {
  const googleClientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID;

  // If Google Client ID is not configured, return children without provider
  // This avoids the "GoogleOAuthProvider is required" error
  if (!googleClientId) {
    console.warn('NEXT_PUBLIC_GOOGLE_CLIENT_ID not found. Google OAuth will be disabled.');
    console.info('💡 To enable Google OAuth: Add GOOGLE_CLIENT_ID to your .setup/.env.config and run the setup script.');
    return <>{children}</>;
  }

  return (
    <GoogleOAuthProvider 
      clientId={googleClientId}
      onScriptLoadError={() => console.log('Google OAuth script failed to load')}
      onScriptLoadSuccess={() => console.log('Google OAuth script loaded successfully')}
    >
      {children}
    </GoogleOAuthProvider>
  );
}