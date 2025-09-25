'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/lib/hooks';
import { LoadingSpinner, ErrorMessage } from '@/components';
import { config } from '@/lib/config';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLogin, setIsLogin] = useState(true);
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [phone, setPhone] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  const { login, signup, isAuthenticated, isLoading, error, clearError } = useAuth();
  const router = useRouter();

  // Redirection si déjà authentifié
  useEffect(() => {
    if (isAuthenticated && !isLoading) {
      router.push('/dashboard');
    }
  }, [isAuthenticated, isLoading, router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();
    setIsSubmitting(true);
    
    try {
      if (isLogin) {
        await login({ email, password });
        router.push('/dashboard');
      } else {
        await signup({
          email,
          password,
          first_name: firstName,
          last_name: lastName,
          phone: phone || undefined,
        });
        router.push('/dashboard');
      }
    } catch (error) {
      // L'erreur est déjà gérée par le contexte
      console.error('Auth error:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const resetForm = () => {
    setEmail('');
    setPassword('');
    setFirstName('');
    setLastName('');
    setPhone('');
    clearError();
  };

  const toggleMode = () => {
    setIsLogin(!isLogin);
    resetForm();
  };

  // Affichage du loading pendant la vérification d'auth
  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <LoadingSpinner size="xl" text="Vérification..." />
      </div>
    );
  }

  // Ne pas afficher le formulaire si déjà authentifié
  if (isAuthenticated) {
    return null;
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            {isLogin ? 'Connectez-vous à votre compte' : 'Créer un nouveau compte'}
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            {config.projectName}
          </p>
        </div>
        
        {error && (
          <ErrorMessage
            message={error}
            onDismiss={clearError}
          />
        )}
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <input type="hidden" name="remember" value="true" />
          <div className="rounded-md shadow-sm -space-y-px">
            {!isLogin && (
              <>
                <div>
                  <label htmlFor="first-name" className="sr-only">
                    First Name
                  </label>
                  <input
                    id="first-name"
                    name="first-name"
                    type="text"
                    required={!isLogin}
                    className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                    placeholder="First Name"
                    value={firstName}
                    onChange={(e) => setFirstName(e.target.value)}
                  />
                </div>
                <div>
                  <label htmlFor="last-name" className="sr-only">
                    Last Name
                  </label>
                  <input
                    id="last-name"
                    name="last-name"
                    type="text"
                    required={!isLogin}
                    className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                    placeholder="Last Name"
                    value={lastName}
                    onChange={(e) => setLastName(e.target.value)}
                  />
                </div>
                <div>
                  <label htmlFor="phone" className="sr-only">
                    Phone
                  </label>
                  <input
                    id="phone"
                    name="phone"
                    type="tel"
                    className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                    placeholder="Phone (optional)"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                  />
                </div>
              </>
            )}
            <div>
              <label htmlFor="email-address" className="sr-only">
                Email address
              </label>
              <input
                id="email-address"
                name="email"
                type="email"
                autoComplete="email"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="Email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>
            <div>
              <label htmlFor="password" className="sr-only">
                Password
              </label>
              <input
                id="password"
                name="password"
                type="password"
                autoComplete="current-password"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
          </div>

          <div>
            <button
              type="submit"
              disabled={isSubmitting}
              className="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isSubmitting ? (
                <div className="flex items-center">
                  <LoadingSpinner size="sm" color="gray" className="mr-2" />
                  {isLogin ? 'Connexion...' : 'Inscription...'}
                </div>
              ) : (
                isLogin ? 'Se connecter' : 'S\'inscrire'
              )}
            </button>
          </div>
        </form>
        <div className="text-center">
          <button
            type="button"
            onClick={toggleMode}
            className="font-medium text-indigo-600 hover:text-indigo-500"
            disabled={isSubmitting}
          >
            {isLogin ? 'Besoin d\'un compte ? S\'inscrire' : 'Déjà un compte ? Se connecter'}
          </button>
        </div>
      </div>
    </div>
  );
}