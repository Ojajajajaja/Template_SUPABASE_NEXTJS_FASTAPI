// Service d'authentification
import { apiService } from './api';
import {
  User,
  UserProfile,
  LoginCredentials,
  SignupData,
  ProfileUpdateData,
  AuthResponse,
} from '@/types';

export class AuthService {
  async login(credentials: LoginCredentials): Promise<AuthResponse> {
    const response = await apiService.post<AuthResponse>('/auth/login', credentials);
    
    if (response.access_token) {
      apiService.setToken(response.access_token);
    }
    
    return response;
  }

  async signup(data: SignupData): Promise<{ message: string; user: User }> {
    return apiService.post('/auth/signup', data);
  }

  async getCurrentUser(): Promise<{ message: string }> {
    return apiService.get('/user/me');
  }

  async getUserProfile(): Promise<UserProfile> {
    return apiService.get<UserProfile>('/user/profile');
  }

  async updateProfile(data: ProfileUpdateData): Promise<{ message: string }> {
    return apiService.put('/user/profile', data);
  }

  logout(): void {
    apiService.clearToken();
    
    // Redirection vers la page d'accueil
    if (typeof window !== 'undefined') {
      window.location.href = '/';
    }
  }

  isAuthenticated(): boolean {
    return apiService.isAuthenticated();
  }

  getToken(): string | null {
    return apiService.getToken();
  }
}

// Instance singleton
export const authService = new AuthService();