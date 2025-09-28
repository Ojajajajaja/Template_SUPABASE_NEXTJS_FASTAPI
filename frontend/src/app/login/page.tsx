'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { useAuth } from '@/lib/hooks';
import { ErrorMessage } from '@/components';
import { OAuthButtons } from '@/components/auth';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Loader } from '@/components/ui/loader';
import { ModeToggle } from '@/components/mode-toggle';

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

  // Redirect if already authenticated
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
      // Error is already handled by context
      console.error('Auth error:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleOAuthSuccess = () => {
    router.push('/dashboard');
  };

  const handleOAuthError = (error: string) => {
    console.error('OAuth error:', error);
    // L'erreur sera aussi affichée via le contexte d'authentification
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

  // Loading display during auth verification
  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader size="lg" />
      </div>
    );
  }

  // Don't show form if already authenticated
  if (isAuthenticated) {
    return null;
  }

  return (
    <div className="min-h-screen flex flex-col lg:flex-row">
      {/* Left section - Hero */}
      <div className="flex-1 bg-gradient-to-br from-primary via-primary/90 to-primary/80 flex items-center justify-center p-8 relative overflow-hidden">
        {/* Background pattern */}
        <div className="absolute inset-0 bg-grid-white/10 bg-[size:32px_32px] [mask-image:radial-gradient(ellipse_at_center,black_50%,transparent_100%)]" />
        
        <div className="relative z-10 text-center text-primary-foreground max-w-md">
          <div className="mb-8">
            <div className="w-16 h-16 bg-primary-foreground/20 rounded-full flex items-center justify-center mx-auto mb-4">
              <Image 
                src="/placeholder_logo.svg" 
                alt="Oja Template Logo" 
                width={32} 
                height={32}
                className="w-8 h-8 invert"
              />
            </div>
            <h1 className="text-4xl font-bold mb-4">Oja Template</h1>
            <p className="text-primary-foreground/80 text-lg leading-relaxed">
              Join the template and discover a modern solution designed to accelerate your development.
            </p>
          </div>
          
          {/* Features */}
          <div className="space-y-4 text-left">
            <div className="flex items-center space-x-3">
              <div className="w-2 h-2 bg-primary-foreground rounded-full"></div>
              <span className="text-sm">Secure authentication</span>
            </div>
            <div className="flex items-center space-x-3">
              <div className="w-2 h-2 bg-primary-foreground rounded-full"></div>
              <span className="text-sm">Modern interface with Shadcn/UI</span>
            </div>
            <div className="flex items-center space-x-3">
              <div className="w-2 h-2 bg-primary-foreground rounded-full"></div>
              <span className="text-sm">Modular and extensible architecture</span>
            </div>
          </div>
        </div>
      </div>

      {/* Right section - Form */}
      <div className="flex-1 flex items-center justify-center p-8 bg-background">
        <div className="w-full max-w-md space-y-6">
          {/* Header with navigation */}
          <div className="flex justify-between items-center mb-8">
            <Link href="/" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
              ← Back to home
            </Link>
            <ModeToggle />
          </div>

          <Card>
            <CardHeader className="space-y-1 text-center">
              <CardTitle className="text-2xl">
                {isLogin ? "Sign In" : "Create Account"}
              </CardTitle>
              <CardDescription>
                {isLogin 
                  ? "Enter your credentials to access your account"
                  : "Create your account to get started"
                }
              </CardDescription>
            </CardHeader>
            <CardContent>
              {error && (
                <ErrorMessage
                  message={error}
                  onDismiss={clearError}
                  className="mb-6"
                />
              )}
              
              <form onSubmit={handleSubmit} className="space-y-4">
                {!isLogin && (
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="firstName">First Name</Label>
                      <Input
                        id="firstName"
                        type="text"
                        placeholder="John"
                        value={firstName}
                        onChange={(e) => setFirstName(e.target.value)}
                        required={!isLogin}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="lastName">Last Name</Label>
                      <Input
                        id="lastName"
                        type="text"
                        placeholder="Doe"
                        value={lastName}
                        onChange={(e) => setLastName(e.target.value)}
                        required={!isLogin}
                      />
                    </div>
                  </div>
                )}
                
                {!isLogin && (
                  <div className="space-y-2">
                    <Label htmlFor="phone">Phone (optional)</Label>
                    <Input
                      id="phone"
                      type="tel"
                      placeholder="+1 234 567 8900"
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                    />
                  </div>
                )}
                
                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input
                    id="email"
                    type="email"
                    placeholder="john@example.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                  />
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="password">Password</Label>
                  <Input
                    id="password"
                    type="password"
                    placeholder="••••••••"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                  />
                </div>
                
                <Button 
                  type="submit" 
                  className="w-full" 
                  disabled={isSubmitting}
                >
                  {isSubmitting && (
                    <Loader size="sm" className="mr-2" />
                  )}
                  {isSubmitting
                    ? (isLogin ? "Signing in..." : "Creating account...")
                    : (isLogin ? "Sign In" : "Create Account")
                  }
                </Button>
              </form>
              
              {/* Boutons OAuth */}
              <OAuthButtons 
                onSuccess={handleOAuthSuccess}
                onError={handleOAuthError}
                disabled={isSubmitting}
              />
              
              <div className="mt-6 text-center">
                <Button
                  variant="link"
                  onClick={toggleMode}
                  disabled={isSubmitting}
                  className="text-sm"
                >
                  {isLogin
                    ? "Don't have an account? Sign up"
                    : "Already have an account? Sign in"
                  }
                </Button>
              </div>
            </CardContent>
          </Card>
          
          {/* Footer */}
          <p className="text-center text-xs text-muted-foreground">
            By continuing, you agree to our{' '}
            <Link href="#" className="underline underline-offset-4 hover:text-foreground">
              terms of service
            </Link>{' '}
            and{' '}
            <Link href="#" className="underline underline-offset-4 hover:text-foreground">
              privacy policy
            </Link>
            .
          </p>
        </div>
      </div>
    </div>
  );
}