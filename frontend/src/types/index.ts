// Export central pour tous les types

export * from './auth';
export * from './api';

// Types génériques
export interface ComponentProps {
  className?: string;
  children?: React.ReactNode;
}

export interface PageProps {
  params?: { [key: string]: string };
  searchParams?: { [key: string]: string | string[] | undefined };
}