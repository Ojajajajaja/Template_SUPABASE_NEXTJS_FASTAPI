// Service API pour encapsuler tous les appels backend
import { config } from '@/lib/config';
import { ApiException, QueryParams } from '@/types/api';

export class ApiService {
  private baseUrl: string;
  private apiPrefix: string;

  constructor() {
    this.baseUrl = config.apiUrl;
    this.apiPrefix = config.apiPrefix;
  }

  private getAuthHeaders(): Record<string, string> {
    const token = this.getStoredToken();
    return {
      'Content-Type': 'application/json',
      ...(token && { 'Authorization': `Bearer ${token}` }),
    };
  }

  private getStoredToken(): string | null {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem('access_token');
  }

  private setStoredToken(token: string): void {
    if (typeof window === 'undefined') return;
    localStorage.setItem('access_token', token);
  }

  private removeStoredToken(): void {
    if (typeof window === 'undefined') return;
    localStorage.removeItem('access_token');
  }

  private buildUrl(endpoint: string, params?: QueryParams): string {
    const url = new URL(`${this.baseUrl}${this.apiPrefix}${endpoint}`);
    
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          url.searchParams.append(key, String(value));
        }
      });
    }

    return url.toString();
  }

  private async handleResponse<T>(response: Response): Promise<T> {
    const contentType = response.headers.get('content-type');
    
    let data: any;
    if (contentType && contentType.includes('application/json')) {
      data = await response.json();
    } else {
      data = { message: await response.text() };
    }

    if (!response.ok) {
      throw new ApiException(
        data.detail || data.message || `HTTP error! status: ${response.status}`,
        response.status,
        data
      );
    }

    return data;
  }

  async get<T>(endpoint: string, params?: QueryParams): Promise<T> {
    const url = this.buildUrl(endpoint, params);
    
    const response = await fetch(url, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });

    return this.handleResponse<T>(response);
  }

  async post<T>(endpoint: string, data?: any): Promise<T> {
    const url = this.buildUrl(endpoint);
    
    const response = await fetch(url, {
      method: 'POST',
      headers: this.getAuthHeaders(),
      body: data ? JSON.stringify(data) : undefined,
    });

    return this.handleResponse<T>(response);
  }

  async put<T>(endpoint: string, data?: any): Promise<T> {
    const url = this.buildUrl(endpoint);
    
    const response = await fetch(url, {
      method: 'PUT',
      headers: this.getAuthHeaders(),
      body: data ? JSON.stringify(data) : undefined,
    });

    return this.handleResponse<T>(response);
  }

  async delete<T>(endpoint: string): Promise<T> {
    const url = this.buildUrl(endpoint);
    
    const response = await fetch(url, {
      method: 'DELETE',
      headers: this.getAuthHeaders(),
    });

    return this.handleResponse<T>(response);
  }

  // Méthodes utilitaires pour le token
  getToken(): string | null {
    return this.getStoredToken();
  }

  setToken(token: string): void {
    this.setStoredToken(token);
  }

  clearToken(): void {
    this.removeStoredToken();
  }

  isAuthenticated(): boolean {
    return !!this.getStoredToken();
  }
}

// Instance singleton
export const apiService = new ApiService();