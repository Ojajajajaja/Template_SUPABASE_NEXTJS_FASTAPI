---
trigger: always_on
alwaysApply: true
---

# Project Configuration Rules

## Project Information
- **Name**: Template SUPABASE NEXTJS FASTAPI
- **Type**: Full-stack application
- **Version**: 1.0.0
- **Description**: Full-stack template with Next.js frontend and FastAPI backend using Supabase

## Architecture Enforcement
- **Style**: modular-separation
- **Enforcement**: MANDATORY

### Backend Configuration
- **Framework**: FastAPI
- **Language**: Python
- **Package Manager**: UV (MANDATORY)
- **Max File Lines**: 300 (STRICT LIMIT)

#### Required Backend Folders
- `api/` (MANDATORY)
- `api/models/` (MANDATORY)
- `api/views/` (MANDATORY)
- `api/helpers/` (MANDATORY)
- `api/schemas/` (MANDATORY)
- `tests/` (MANDATORY)

### Frontend Configuration
- **Framework**: Next.js
- **Language**: TypeScript (MANDATORY)
- **Package Manager**: npm (MANDATORY)
- **UI Library**: shadcn/ui
- **Max Component Lines**: 200 (STRICT LIMIT)

#### Required Frontend Folders
- `src/app/` (MANDATORY)
- `src/components/` (MANDATORY)
- `src/lib/` (MANDATORY)
- `src/services/` (MANDATORY)
- `src/types/` (MANDATORY)

## User Preferences (STRICT ENFORCEMENT)
- **OAuth Buttons**: icon-only style, NO TEXT
- **UI Language**: English only
- **Design Style**: minimalist

## Project Requirements (NON-NEGOTIABLE)
- **Interface Language**: English only
- **Comment Language**: English only
- **OAuth Providers**: Google, GitHub
- **Authentication**: Supabase Auth

## Development Commands (MANDATORY)
- **Backend Dev**: `uv run run.py dev`
- **Backend Prod**: `uv run run.py prod`
- **Frontend Dev**: `npm run dev`
- **Frontend Build**: `npm run build`

## Development Tools (ENFORCED)
- **Backend Package Manager**: UV
- **Frontend Package Manager**: npm
- **Python Formatter**: black
- **Python Linter**: ruff
- **TypeScript Formatter**: prettier
- **TypeScript Linter**: eslint

## Security Rules (CRITICAL)
- **Environment Validation**: MANDATORY
- **No Secrets in Frontend**: ABSOLUTE RULE
- **Server-side Token Validation**: MANDATORY
- **Sensitive Files**: .env, *.pem, *.key

## Quality Requirements (ENFORCED)
- **Error Handling**: MANDATORY for all operations
- **Testing Required**: auth flows, critical paths, API endpoints
- **Documentation Required**: API endpoints, component props, environment variables

## Forbidden Patterns (NEVER ALLOW)
- monolithic_main_py
- secrets_in_frontend
- french_ui_text
- text_oauth_buttons
- circular_imports
- direct_db_in_routes
- missing_error_handling
- sync_io_operations

## Required Patterns (ALWAYS ENFORCE)
- modular_architecture
- centralized_config
- service_layer_separation
- proper_error_handling
- async_operations
- icon_only_oauth
- english_interface

## File Rules

### Python Files
- **Max Lines**: 300
- **Naming**: snake_case
- **Imports**: absolute_preferred
- **Async**: REQUIRED for I/O operations

### TypeScript Files
- **Max Lines**: 200
- **Naming**: camelCase
- **Components Naming**: PascalCase
- **Strict Types**: MANDATORY

## Monitoring Requirements (MANDATORY)
- **Health Checks**: REQUIRED
- **Error Tracking**: REQUIRED
- **Performance Monitoring**: REQUIRED

## Deployment Requirements (ENFORCED)
- **Environments**: development, staging, production
- **Environment-specific Configs**: MANDATORY
- **Health Endpoints**: REQUIRED
- **Proper Logging**: MANDATORY