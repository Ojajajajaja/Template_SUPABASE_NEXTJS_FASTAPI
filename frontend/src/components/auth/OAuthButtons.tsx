'use client';

import { GoogleOAuthButton } from './GoogleOAuthButton';

interface OAuthButtonsProps {
  onSuccess?: () => void;
  onError?: (error: string) => void;
  disabled?: boolean;
  className?: string;
}

export function OAuthButtons({ 
  onSuccess, 
  onError, 
  disabled = false,
  className = ""
}: OAuthButtonsProps) {
  // Check if Google OAuth is configured
  const googleConfigured = !!process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID;

  // If Google is not configured, don't show the OAuth section
  if (!googleConfigured) {
    return null;
  }

  return (
    <div className={`space-y-3 ${className}`}>
      {/* Séparateur */}
      <div className="relative">
        <div className="absolute inset-0 flex items-center">
          <span className="w-full border-t" />
        </div>
      </div>

      {/* OAuth Buttons */}
      <div className="text-center">
        <p className="text-sm text-muted-foreground mb-3">
          Or sign in with
        </p>
        <div className="flex justify-center">
          <GoogleOAuthButton
            onSuccess={onSuccess}
            onError={onError}
            disabled={disabled}
            useCustomButton={true}
          />
        </div>
      </div>
    </div>
  );
}