// Composant de protection des routes authentifiées
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/lib/hooks';
import { LoadingSpinner } from '@/components/ui';
import { ComponentProps } from '@/types';

interface AuthGuardProps extends ComponentProps {
  fallback?: React.ReactNode;
  redirectTo?: string;
}

export const AuthGuard: React.FC<AuthGuardProps> = ({
  children,
  fallback,
  redirectTo = '/login',
}) => {
  const { isAuthenticated, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push(redirectTo);
    }
  }, [isAuthenticated, isLoading, router, redirectTo]);

  // Affichage du chargement
  if (isLoading) {
    return (
      fallback || (
        <div className="min-h-screen flex items-center justify-center">
          <LoadingSpinner size="xl" text="Vérification de l'authentification..." />
        </div>
      )
    );
  }

  // Si non authentifié, ne rien afficher (redirection en cours)
  if (!isAuthenticated) {
    return null;
  }

  // Si authentifié, afficher le contenu
  return <>{children}</>;
};

export default AuthGuard;