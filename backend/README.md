# Backend API Documentation

This document provides detailed information about the available endpoints and functionalities of the FastAPI backend with Supabase integration.

## Table of Contents
- [Authentication](#authentication)
- [Health Check](#health-check)
- [User Management](#user-management)
- [Environment Variables](#environment-variables)

## Authentication

### Sign Up
**POST** `/api/v1/auth/signup`

Registers a new user with email and password.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+1234567890" // Optional
}
```

**Response:**
```json
{
  "message": "User created successfully",
  "user": {
    // User object
  }
}
```

### Login
**POST** `/api/v1/auth/login`

Authenticates an existing user with email and password.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    // User object
  }
}
```

## Health Check

### Health Status
**GET** `/health`

Checks the health status of the API.

**Response:**
```json
{
  "status": "healthy",
  "message": "API is running normally"
}
```

## User Management

### Get Current User
**GET** `/api/v1/user/me`

Retrieves information of the currently authenticated user. Requires authentication token.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "message": "User is authenticated"
}
```

### Get User Profile
**GET** `/api/v1/user/profile`

Retrieves the complete profile information of the currently authenticated user, including role. Requires authentication token.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "id": "user-uuid",
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "full_name": "John Doe",
  "phone": "+1234567890",
  "role": "user",
  "created_at": "2023-01-01T00:00:00Z"
}
```

### Update User Profile
**PUT** `/api/v1/user/profile`

Updates the profile information of the currently authenticated user. Requires authentication token.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body (all fields are optional):**
```json
{
  "first_name": "John", // Optional
  "last_name": "Doe", // Optional
  "full_name": "John Doe", // Optional
  "phone": "+1234567890" // Optional
}
```

**Response:**
```json
{
  "message": "Profile updated successfully"
}
```

## User Roles

The application supports the following user roles:
- `user`: Standard user with basic permissions
- `mod`: Moderator with additional permissions
- `admin`: Administrator with extended permissions
- `superadmin`: Super administrator with all permissions

User roles are managed in the `user_profiles` table in Supabase and are included in the profile data returned by the API.

## Environment Variables

The following environment variables need to be configured:

- `PROJECT_NAME`: The name of your project (default: "API Backend")
- `SUPABASE_URL`: The URL of your Supabase instance
- `SUPABASE_ANON_KEY`: The anonymous key for your Supabase project
- `SUPABASE_SERVICE_KEY`: The service key for your Supabase project
- `API_PREFIX`: The prefix for API routes (default: "/api/v1")
- `API_PORT`: The port on which the API will run (default: 8001)
- `CORS_ORIGINS`: Comma-separated list of allowed origins for CORS (default: "http://localhost:3000")

## Authentication

All endpoints under `/api/v1/user/*` require authentication. To authenticate, include the access token in the Authorization header:

```
Authorization: Bearer <access_token>
```

The access token is obtained through the login endpoint.