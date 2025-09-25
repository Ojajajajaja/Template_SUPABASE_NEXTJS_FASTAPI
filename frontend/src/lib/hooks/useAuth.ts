// Hook personnalisé pour l'authentification
'use client';

import { useContext } from 'react';
import { AuthContext } from '@/lib/contexts/AuthContext';
import { AuthContextType } from '@/types';

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  
  return context;
};

export default useAuth;