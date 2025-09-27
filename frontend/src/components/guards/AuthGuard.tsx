// Authentication route protection component
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/lib/hooks';
import { Loader } from '@/components/ui/loader';
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

  // Loading display
  if (isLoading) {
    return (
      fallback || (
        <div className="min-h-screen flex items-center justify-center">
          <Loader size="lg" />
        </div>
      )
    );
  }

  // If not authenticated, display nothing (redirect in progress)
  if (!isAuthenticated) {
    return null;
  }

  // If authenticated, display content
  return <>{children}</>;
};

export default AuthGuard;