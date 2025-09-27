"use client"

import Link from "next/link"
import Image from "next/image"
import { useAuth } from "@/lib/hooks"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Loader } from "@/components/ui/loader"
import { ModeToggle } from "@/components/mode-toggle"
import { UserMenu } from "@/components/navigation/UserMenu"

export function Hero() {
  const { isAuthenticated, isLoading } = useAuth();

  return (
    <div className="min-h-screen bg-gradient-to-br from-background via-background to-accent/10">
      {/* Header avec logo et navigation */}
      <header className="container mx-auto px-4 py-6">
        <nav className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Image 
              src="/placeholder_logo.svg" 
              alt="Oja Template Logo" 
              width={40} 
              height={40}
              className="w-10 h-10"
            />
            <span className="text-2xl font-bold text-foreground">Oja Template</span>
          </div>
          <div className="flex items-center space-x-4">
            <ModeToggle />
            <UserMenu />
          </div>
        </nav>
      </header>

      {/* Contenu principal */}
      <main className="container mx-auto px-4 py-20">
        <div className="max-w-4xl mx-auto text-center">
          {/* Hero Section */}
          <div className="mb-16">
            <h1 className="text-6xl md:text-8xl font-bold mb-8 bg-gradient-to-r from-foreground via-primary to-foreground bg-clip-text text-transparent leading-tight">
              Well played!
            </h1>
            <p className="text-2xl md:text-3xl text-muted-foreground mb-4 max-w-3xl mx-auto leading-relaxed">
              You have started the template, now it&apos;s time to
            </p>
            <p className="text-2xl md:text-3xl text-primary font-semibold mb-8 max-w-3xl mx-auto">
              build something amazing
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center items-center mt-12">
              {!isLoading && (
                <>
                  {isAuthenticated ? (
                    <Link href="/dashboard">
                      <Button size="lg" className="px-8 py-4 text-lg">
                        Go to Dashboard
                      </Button>
                    </Link>
                  ) : (
                    <>
                      <Link href="/login">
                        <Button size="lg" className="px-8 py-4 text-lg">
                          Login
                        </Button>
                      </Link>
                      <Link href="/login">
                        <Button variant="outline" size="lg" className="px-8 py-4 text-lg">
                          Sign Up
                        </Button>
                      </Link>
                    </>
                  )}
                </>
              )}
              {isLoading && (
                <div className="flex items-center justify-center space-x-4">
                  <Loader size="md" />
                </div>
              )}
            </div>
          </div>



          {/* Tech Stack Cards */}
          <div className="mt-24">
            <h2 className="text-3xl font-bold mb-12 text-center">Built with</h2>
            <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
              {/* Backend Card */}
              <Card className="group hover:shadow-lg transition-all duration-300">
                <CardHeader>
                  <CardTitle className="text-xl">
                    Backend Stack
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex flex-wrap justify-center gap-3 max-w-xs mx-auto">
                    <div className="bg-muted px-3 py-1.5 rounded-full text-sm font-medium">FastAPI</div>
                    <div className="bg-muted px-3 py-1.5 rounded-full text-sm font-medium">Python</div>
                    <div className="bg-muted px-3 py-1.5 rounded-full text-sm font-medium">UV</div>
                    <div className="bg-muted px-3 py-1.5 rounded-full text-sm font-medium">Gunicorn</div>
                    <div className="bg-muted px-3 py-1.5 rounded-full text-sm font-medium">Supabase</div>
                  </div>
                </CardContent>
              </Card>

              {/* Frontend Card */}
              <Card className="group hover:shadow-lg transition-all duration-300">
                <CardHeader>
                  <CardTitle className="text-xl">
                    Frontend Stack
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex flex-wrap justify-center gap-3 max-w-xs mx-auto">
                    <div className="bg-muted px-3 py-1.5 rounded-full text-sm font-medium">React</div>
                    <div className="bg-muted px-3 py-1.5 rounded-full text-sm font-medium">Next.js</div>
                    <div className="bg-muted px-3 py-1.5 rounded-full text-sm font-medium">Tailwind</div>
                    <div className="bg-muted px-3 py-1.5 rounded-full text-sm font-medium">TypeScript</div>
                    <div className="bg-muted px-3 py-1.5 rounded-full text-sm font-medium">Shadcn/UI</div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="container mx-auto px-4 py-8 mt-24 border-t">
        <div className="text-center text-muted-foreground">
          <p>&copy; 2025 Oja Template. Built with &lt;3 for developers.</p>
        </div>
      </footer>
    </div>
  )
}