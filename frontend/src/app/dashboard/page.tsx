'use client';

import { useEffect, useState } from 'react';

// Interface pour le profil utilisateur
interface UserProfile {
  id: string;
  email: string;
  first_name: string;
  last_name: string;
  full_name: string;
  phone: string;
  role: string;
  created_at: string;
}

export default function DashboardPage() {
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is authenticated
    const checkAuth = async () => {
      try {
        const token = localStorage.getItem('access_token');
        if (!token) {
          // Redirect to login if no token
          window.location.href = '/login';
          return;
        }

        // Configuration API
        const apiUrl = 'http://localhost:2000';
        const apiPrefix = '/api/v1';
        
        // Verify token with backend
        const response = await fetch(`${apiUrl}${apiPrefix}/user/me`, {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
        });

        if (!response.ok) {
          // If token is invalid, redirect to login
          localStorage.removeItem('access_token');
          window.location.href = '/login';
          return;
        }

        // Get user profile data
        const profileResponse = await fetch(`${apiUrl}${apiPrefix}/user/profile`, {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
        });

        if (profileResponse.ok) {
          const profileData = await profileResponse.json();
          setUserProfile(profileData);
        }

        const userData = await response.json();
        // Utilisateur authentifié avec succès
      } catch (error) {
        console.error('Authentication check failed', error);
        localStorage.removeItem('access_token');
        window.location.href = '/login';
      } finally {
        setLoading(false);
      }
    };

    checkAuth();
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-t-2 border-b-2 border-indigo-500"></div>
      </div>
    );
  }

  return (
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
                onClick={() => {
                  localStorage.removeItem('access_token');
                  window.location.href = '/';
                }}
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
          <div className="border-4 border-dashed border-gray-200 rounded-lg h-96 p-4">
            <h2 className="text-2xl font-bold text-gray-800 mb-4">Welcome to your Dashboard</h2>
            <p className="text-gray-600">
              This is a protected page that can only be accessed when you are logged in.
            </p>
            <div className="mt-6">
              <h3 className="text-lg font-medium text-gray-900">User Profile</h3>
              <div className="mt-2 bg-white py-4 px-6 shadow rounded">
                {userProfile ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <p className="text-sm font-medium text-gray-500">First Name</p>
                      <p className="text-gray-900">{userProfile.first_name || 'N/A'}</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-500">Last Name</p>
                      <p className="text-gray-900">{userProfile.last_name || 'N/A'}</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-500">Full Name</p>
                      <p className="text-gray-900">{userProfile.full_name || 'N/A'}</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-500">Email</p>
                      <p className="text-gray-900">{userProfile.email || 'N/A'}</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-500">Phone</p>
                      <p className="text-gray-900">{userProfile.phone || 'N/A'}</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-500">Role</p>
                      <p className="text-gray-900 capitalize">{userProfile.role || 'N/A'}</p>
                    </div>
                  </div>
                ) : (
                  <p className="text-gray-600">Loading profile information...</p>
                )}
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
