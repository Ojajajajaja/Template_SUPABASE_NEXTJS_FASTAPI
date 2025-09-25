// Types communs pour l'API

export interface ApiResponse<T = any> {
  data?: T;
  message?: string;
  error?: string;
  status: number;
}

export interface ApiError {
  message: string;
  status: number;
  details?: any;
}

export class ApiException extends Error {
  status: number;
  details?: any;

  constructor(message: string, status: number, details?: any) {
    super(message);
    this.name = 'ApiException';
    this.status = status;
    this.details = details;
  }
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface QueryParams {
  [key: string]: string | number | boolean | undefined;
}