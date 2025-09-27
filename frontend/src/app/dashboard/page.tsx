'use client';

import Image from 'next/image';
import { useAuth } from '@/lib/hooks';
import { UserProfileCard, ErrorMessage, AuthGuard } from '@/components';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { ModeToggle } from '@/components/mode-toggle';
import { UserMenu } from '@/components/navigation/UserMenu';
import { User } from 'lucide-react';

export default function DashboardPage() {
  const { profile, isLoading, error, clearError } = useAuth();

  return (
    <AuthGuard>
      <div className="min-h-screen bg-background">
        {/* Header */}
        <header className="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
          <div className="container mx-auto px-4 py-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <Image 
                  src="/placeholder_logo.svg" 
                  alt="Oja Template Logo" 
                  width={32} 
                  height={32}
                  className="w-8 h-8"
                />
                <span className="text-xl font-semibold">Oja Template</span>
              </div>
              <div className="flex items-center space-x-4">
                <ModeToggle />
                <UserMenu />
              </div>
            </div>
          </div>
        </header>

        {/* Main Content */}
        <main className="container mx-auto px-4 py-8">
          {error && (
            <ErrorMessage 
              message={error} 
              onDismiss={clearError} 
              className="mb-6" 
            />
          )}

          {/* User Profile Section */}
          <div className="max-w-8xl mx-auto">
            <Card>
              <CardHeader>
                <CardTitle>User Profile</CardTitle>
                <CardDescription>
                  Your account information and settings
                </CardDescription>
              </CardHeader>
              <CardContent>
                {profile && (
                  <UserProfileCard 
                    profile={profile} 
                    isLoading={isLoading}
                    showEditButton={false}
                  />
                )}
                {!profile && !isLoading && (
                  <div className="text-center py-8 text-muted-foreground">
                    <User className="h-12 w-12 mx-auto mb-4 opacity-50" />
                    <p>No profile information available.</p>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        </main>
      </div>
    </AuthGuard>
  );
}