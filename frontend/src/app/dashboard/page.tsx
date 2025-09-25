'use client';

'use client';

import { useAuth } from '@/lib/hooks';
import { UserProfileCard, ErrorMessage, AuthGuard } from '@/components';

export default function DashboardPage() {
  const { profile, isLoading, error, logout, clearError } = useAuth();

  const handleLogout = () => {
    logout();
  };

  return (
    <AuthGuard>
      <div className="min-h-screen bg-gray-50">
        <nav className="bg-white shadow">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between h-16">
              <div className="flex">
                <div className="flex-shrink-0 flex items-center">
                  <h1 className="text-xl font-bold">Dashboard</h1>
                </div>
              </div>
              <div className="flex items-center">
                <button
                  onClick={handleLogout}
                  className="ml-4 px-4 py-2 border border-transparent text-sm font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                >
                  Logout
                </button>
              </div>
            </div>
          </div>
        </nav>

        <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
          <div className="px-4 py-6 sm:px-0">
            <div className="border-4 border-dashed border-gray-200 rounded-lg min-h-96 p-4">
              <h2 className="text-2xl font-bold text-gray-800 mb-4">Bienvenue sur votre Dashboard</h2>
              <p className="text-gray-600 mb-6">
                Cette page est protégée et accessible uniquement lorsque vous êtes connecté.
              </p>
              
              {error && (
                <ErrorMessage 
                  message={error} 
                  onDismiss={clearError} 
                  className="mb-6" 
                />
              )}
              
              <div className="mt-6">
                {profile && (
                  <UserProfileCard 
                    profile={profile} 
                    isLoading={isLoading}
                    showEditButton={false}
                  />
                )}
                {!profile && !isLoading && (
                  <div className="bg-white py-4 px-6 shadow rounded">
                    <p className="text-gray-600">Aucune information de profil disponible.</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </main>
      </div>
    </AuthGuard>
  );
}
