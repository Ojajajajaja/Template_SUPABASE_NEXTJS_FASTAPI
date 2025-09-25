// HOC pour la protection des routes
import { ComponentType } from 'react';
import AuthGuard from './AuthGuard';

interface WithAuthOptions {
  fallback?: React.ReactNode;
  redirectTo?: string;
}

export function withAuth<P extends object>(
  Component: ComponentType<P>,
  options?: WithAuthOptions
) {
  const WrappedComponent = (props: P) => {
    return (
      <AuthGuard {...options}>
        <Component {...props} />
      </AuthGuard>
    );
  };

  WrappedComponent.displayName = `withAuth(${Component.displayName || Component.name})`;

  return WrappedComponent;
}

export default withAuth;