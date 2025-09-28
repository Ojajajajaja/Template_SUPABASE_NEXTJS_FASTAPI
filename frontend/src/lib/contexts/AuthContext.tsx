// Context d'authentification
'use client';

import React, { createContext, useReducer, useEffect, ReactNode } from 'react';
import { authService } from '@/services';
import { 
  AuthContextType, 
  AuthState, 
  LoginCredentials, 
  SignupData, 
  ProfileUpdateData,
  ApiException,
  User,
  UserProfile,
  OAuthCredentials
} from '@/types';

// État initial
const initialState: AuthState = {
  user: null,
  profile: null,
  isAuthenticated: false,
  isLoading: true,
  error: null,
};

// Actions du reducer
type AuthAction =
  | { type: 'AUTH_START' }
  | { type: 'AUTH_SUCCESS'; payload: { user?: User; profile?: UserProfile } }
  | { type: 'AUTH_FAILURE'; payload: string }
  | { type: 'LOGOUT' }
  | { type: 'UPDATE_PROFILE'; payload: UserProfile }
  | { type: 'CLEAR_ERROR' }
  | { type: 'SET_LOADING'; payload: boolean };

// Reducer
const authReducer = (state: AuthState, action: AuthAction): AuthState => {
  switch (action.type) {
    case 'AUTH_START':
      return {
        ...state,
        isLoading: true,
        error: null,
      };
    
    case 'AUTH_SUCCESS':
      return {
        ...state,
        user: action.payload.user || state.user,
        profile: action.payload.profile || state.profile,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      };
    
    case 'AUTH_FAILURE':
      return {
        ...state,
        user: null,
        profile: null,
        isAuthenticated: false,
        isLoading: false,
        error: action.payload,
      };
    
    case 'LOGOUT':
      return {
        ...state,
        user: null,
        profile: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      };
    
    case 'UPDATE_PROFILE':
      return {
        ...state,
        profile: action.payload,
        error: null,
      };
    
    case 'CLEAR_ERROR':
      return {
        ...state,
        error: null,
      };
    
    case 'SET_LOADING':
      return {
        ...state,
        isLoading: action.payload,
      };
    
    default:
      return state;
  }
};

// Création du contexte
export const AuthContext = createContext<AuthContextType | null>(null);

// Props du provider
interface AuthProviderProps {
  children: ReactNode;
}

// Provider du contexte
export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, initialState);

  // Vérification de l'authentification au chargement
  useEffect(() => {
    const checkAuth = async () => {
      try {
        if (!authService.isAuthenticated()) {
          dispatch({ type: 'SET_LOADING', payload: false });
          return;
        }

        dispatch({ type: 'AUTH_START' });
        
        // Récupération du profil utilisateur
        const profile = await authService.getUserProfile();
        
        dispatch({ 
          type: 'AUTH_SUCCESS', 
          payload: { profile } 
        });
        
      } catch (error) {
        console.error('Auth check failed:', error);
        authService.logout();
        dispatch({ 
          type: 'AUTH_FAILURE', 
          payload: error instanceof ApiException ? error.message : 'Authentication failed' 
        });
      }
    };

    checkAuth();
  }, []);

  // Fonction de connexion
  const login = async (credentials: LoginCredentials): Promise<void> => {
    try {
      dispatch({ type: 'AUTH_START' });
      
      const authResponse = await authService.login(credentials);
      const profile = await authService.getUserProfile();
      
      dispatch({ 
        type: 'AUTH_SUCCESS', 
        payload: { 
          user: authResponse.user, 
          profile 
        } 
      });
      
    } catch (error) {
      const message = error instanceof ApiException ? error.message : 'Login failed';
      dispatch({ type: 'AUTH_FAILURE', payload: message });
      throw error;
    }
  };

  // Fonction d'inscription
  const signup = async (data: SignupData): Promise<void> => {
    try {
      dispatch({ type: 'AUTH_START' });
      
      await authService.signup(data);
      
      // Connexion automatique après inscription
      await login({ email: data.email, password: data.password });
      
    } catch (error) {
      const message = error instanceof ApiException ? error.message : 'Signup failed';
      dispatch({ type: 'AUTH_FAILURE', payload: message });
      throw error;
    }
  };

  // Fonction de connexion OAuth
  const loginWithOAuth = async (credentials: OAuthCredentials): Promise<void> => {
    try {
      dispatch({ type: 'AUTH_START' });
      
      const authResponse = await authService.loginWithOAuth(credentials);
      const profile = authResponse.profile || await authService.getUserProfile();
      
      dispatch({ 
        type: 'AUTH_SUCCESS', 
        payload: { 
          user: authResponse.user, 
          profile 
        } 
      });
      
    } catch (error) {
      const message = error instanceof ApiException ? error.message : 'OAuth login failed';
      dispatch({ type: 'AUTH_FAILURE', payload: message });
      throw error;
    }
  };

  // Fonction de déconnexion
  const logout = (): void => {
    authService.logout();
    dispatch({ type: 'LOGOUT' });
  };

  // Fonction de mise à jour du profil
  const updateProfile = async (data: ProfileUpdateData): Promise<void> => {
    try {
      await authService.updateProfile(data);
      
      // Refresh du profil après mise à jour
      const updatedProfile = await authService.getUserProfile();
      dispatch({ type: 'UPDATE_PROFILE', payload: updatedProfile });
      
    } catch (error) {
      const message = error instanceof ApiException ? error.message : 'Profile update failed';
      dispatch({ type: 'AUTH_FAILURE', payload: message });
      throw error;
    }
  };

  // Fonction de rafraîchissement du profil
  const refreshProfile = async (): Promise<void> => {
    try {
      const profile = await authService.getUserProfile();
      dispatch({ type: 'UPDATE_PROFILE', payload: profile });
    } catch (error) {
      console.error('Profile refresh failed:', error);
      throw error;
    }
  };

  // Fonction pour effacer les erreurs
  const clearError = (): void => {
    dispatch({ type: 'CLEAR_ERROR' });
  };

  // Valeur du contexte
  const contextValue: AuthContextType = {
    ...state,
    login,
    loginWithOAuth,
    signup,
    logout,
    updateProfile,
    refreshProfile,
    clearError,
  };

  return (
    <AuthContext.Provider value={contextValue}>
      {children}
    </AuthContext.Provider>
  );
};