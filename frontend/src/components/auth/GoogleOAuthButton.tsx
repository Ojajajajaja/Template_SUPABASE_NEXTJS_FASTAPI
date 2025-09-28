'use client';

import { GoogleLogin, CredentialResponse, useGoogleLogin } from '@react-oauth/google';
import { useAuth } from '@/lib/hooks';
import { useState, useCallback } from 'react';
import { Button } from '@/components/ui/button';
import { FaGoogle } from 'react-icons/fa';

interface GoogleOAuthButtonProps {
  onSuccess?: () => void;
  onError?: (error: string) => void;
  disabled?: boolean;
  className?: string;
  useCustomButton?: boolean;
}

export function GoogleOAuthButton({ 
  onSuccess, 
  onError, 
  disabled = false,
  className = "",
  useCustomButton = false
}: GoogleOAuthButtonProps) {
  const { loginWithOAuth } = useAuth();
  const [isLoading, setIsLoading] = useState(false);

  // Check if Google Client ID is configured
  const googleClientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID;
  const isGoogleConfigured = !!googleClientId;

  // Hook for custom button
  const googleLogin = useGoogleLogin({
    onSuccess: async (tokenResponse) => {
      setIsLoading(true);
      try {
        // Fetch user information with token
        const userInfoResponse = await fetch(
          `https://www.googleapis.com/oauth2/v2/userinfo?access_token=${tokenResponse.access_token}`
        );
        const userInfo = await userInfoResponse.json();
        
        await loginWithOAuth({
          provider: 'google',
          token: tokenResponse.access_token,
          user_info: {
            email: userInfo.email,
            name: userInfo.name,
            picture: userInfo.picture,
            given_name: userInfo.given_name,
            family_name: userInfo.family_name,
          }
        });
        
        onSuccess?.();
      } catch (error) {
        console.error('Google OAuth error:', error);
        onError?.(error instanceof Error ? error.message : 'Google authentication failed');
      } finally {
        setIsLoading(false);
      }
    },
    onError: () => {
      onError?.('Google authentication failed');
    },
    flow: 'implicit',
  });

  const handleSuccess = async (credentialResponse: CredentialResponse) => {
    if (!credentialResponse.credential) {
      onError?.('No credential received from Google');
      return;
    }

    setIsLoading(true);
    try {
      // Decode JWT token to extract user information
      const payload = JSON.parse(atob(credentialResponse.credential.split('.')[1]));
      
      await loginWithOAuth({
        provider: 'google',
        token: credentialResponse.credential,
        user_info: {
          email: payload.email,
          name: payload.name,
          picture: payload.picture,
          given_name: payload.given_name,
          family_name: payload.family_name,
        }
      });
      
      onSuccess?.();
    } catch (error) {
      console.error('Google OAuth error:', error);
      onError?.(error instanceof Error ? error.message : 'Google authentication failed');
    } finally {
      setIsLoading(false);
    }
  };

  const handleError = () => {
    onError?.('Google authentication failed');
  };

  // If Google is not configured, show informative button
  if (!isGoogleConfigured) {
    return (
      <Button
        type="button"
        variant="outline"
        size="icon"
        className={`h-10 w-10 opacity-50 ${className}`}
        disabled={true}
        title="Configure Google OAuth in .env.local first"
      >
        <FaGoogle className="h-4 w-4" />
      </Button>
    );
  }

  // Custom button to avoid CORS issues
  if (useCustomButton) {
    return (
      <Button
        type="button"
        variant="outline"
        size="icon"
        className={`h-10 w-10 ${className}`}
        onClick={() => googleLogin()}
        disabled={disabled || isLoading}
        title="Sign in with Google"
      >
        {isLoading ? (
          <div className="h-4 w-4 animate-spin rounded-full border-2 border-gray-300 border-t-gray-600" />
        ) : (
          <FaGoogle className="h-4 w-4" />
        )}
      </Button>
    );
  }

  return (
    <div className={className}>
      {(disabled || isLoading) ? (
        <Button
          type="button"
          variant="outline"
          className="w-full"
          disabled={true}
        >
          <FaGoogle className="mr-2 h-4 w-4" />
          {isLoading ? 'Connexion...' : 'Continuer avec Google'}
        </Button>
      ) : (
        <GoogleLogin
          onSuccess={handleSuccess}
          onError={handleError}
          useOneTap={false}
          theme="outline"
          size="large"
          text="continue_with"
          width="320"
          auto_select={false}
          cancel_on_tap_outside={false}
        />
      )}
    </div>
  );
}

// Version avec bouton personnalisé
export function CustomGoogleButton({ 
  onSuccess, 
  onError, 
  disabled = false,
  className = "" 
}: GoogleOAuthButtonProps) {
  const [isLoading, setIsLoading] = useState(false);

  const handleClick = () => {
    // Cette fonction sera appelée quand on utilisera l'API Google directement
    // Pour l'instant, on utilise le composant GoogleLogin ci-dessus
  };

  return (
    <Button
      type="button"
      variant="outline"
      className={`w-full ${className}`}
      onClick={handleClick}
      disabled={disabled || isLoading}
    >
      <FaGoogle className="mr-2 h-4 w-4" />
      {isLoading ? 'Connexion...' : 'Continuer avec Google'}
    </Button>
  );
}