---
trigger: always_on
alwaysApply: true
---

# Architecture Rules - Template SUPABASE NEXTJS FASTAPI

## Project Stack (MANDATORY)
- Next.js 14
- FastAPI
- Supabase
- TypeScript
- Python 3.12+

## Backend Architecture Rules

### Framework Requirements
- **Framework**: FastAPI (ONLY)
- **Package Manager**: UV (ONLY)

### Required Folder Structure
- `api/` - Main API package
- `api/models/` - Pydantic models ONLY
- `api/views/` - Route definitions ONLY
- `api/helpers/` - Utility functions and services
- `api/schemas/` - Database schema definitions
- `tests/` - All test files

### Forbidden Backend Patterns
- Single monolithic main.py > 300 lines
- Business logic outside api/ folder
- Direct database calls in views without helpers
- Secrets hardcoded in code

### Backend Naming Conventions
- **Files**: snake_case
- **Classes**: PascalCase
- **Functions**: snake_case
- **Constants**: UPPER_SNAKE_CASE

## Frontend Architecture Rules

### Framework Requirements
- **Framework**: Next.js (ONLY)
- **Package Manager**: npm (ONLY)
- **Language**: TypeScript (MANDATORY)
- **UI Library**: shadcn/ui

### Required Folder Structure
- `src/app/` - Next.js app router pages
- `src/components/` - Reusable UI components
- `src/lib/` - Utilities and configurations
- `src/services/` - API service layer
- `src/types/` - TypeScript type definitions

### Forbidden Frontend Patterns
- Components > 200 lines
- Direct API calls in components (use services/)
- Inline styles (use CSS modules or Tailwind)
- French UI text (English ONLY)
- Text-based OAuth buttons (icon-only ONLY)

### Frontend Naming Conventions
- **Files**: kebab-case
- **Components**: PascalCase
- **Functions**: camelCase
- **Types**: PascalCase

## Authentication Architecture

### Provider Requirements
- **Primary**: Supabase Auth
- **OAuth Providers**: Google, GitHub ONLY

### Authentication Rules (CRITICAL)
- Never expose service keys in frontend
- Always validate tokens on backend
- Use icon-only OAuth buttons (NO TEXT)
- Handle auth state in React Context

## Environment Configuration

### Development Environment
- **Backend Command**: `uv run run.py dev`
- **Frontend Command**: `npm run dev`
- **Hot Reload**: ENABLED

### Production Environment
- **Backend Command**: `uv run run.py prod`
- **Frontend Command**: `npm run build && npm start`
- **Optimization**: ENABLED

## Code Quality Rules

### Linting Requirements
- **Python**: ruff (MANDATORY)
- **TypeScript**: eslint (MANDATORY)

### Formatting Requirements
- **Python**: black (MANDATORY)
- **TypeScript**: prettier (MANDATORY)

### Type Checking Requirements
- **Python**: mypy (MANDATORY)
- **TypeScript**: tsc --noEmit (MANDATORY)

## Testing Architecture

### Backend Testing
- **Framework**: pytest (ONLY)
- **Location**: backend/tests/
- **Coverage Minimum**: 80%

### Frontend Testing
- **Framework**: jest + @testing-library (ONLY)
- **Location**: frontend/__tests__/
- **Coverage Minimum**: 70%

## Security Architecture

### Sensitive Files (NEVER COMMIT)
- .env
- *.pem
- *.key

### Security Rules (ABSOLUTE)
- Real API keys (NEVER COMMIT)
- Production credentials (NEVER COMMIT)
- Personal tokens (NEVER COMMIT)

## Performance Architecture

### Backend Performance Rules
- Use async/await for I/O operations
- Implement proper caching
- Monitor database query performance

### Frontend Performance Rules
- Use Next.js Image optimization
- Implement lazy loading
- Optimize bundle size

## Accessibility Architecture

### Requirements (MANDATORY)
- ARIA labels for interactive elements
- Keyboard navigation support
- High contrast mode compatibility
- Screen reader friendly

## Documentation Architecture

### Required Documentation
- README.md in each major folder
- API endpoint documentation
- Component prop documentation
- Environment variables documentation

## Deployment Architecture

### Environment Requirements
- development
- staging
- production

### Deployment Rules (MANDATORY)
- Environment-specific configs
- Health check endpoints
- Proper logging configuration
- Error monitoring setup

## Module Interaction Rules

### Backend Module Hierarchy
1. **models/**: Base level - NO imports from other api/ modules
2. **helpers/**: Can import from models/
3. **views/**: Can import from helpers/ and models/
4. **schemas/**: Independent - database definitions only

### Frontend Module Hierarchy
1. **types/**: Base level - type definitions only
2. **lib/**: Can import from types/
3. **services/**: Can import from types/ and lib/
4. **components/**: Can import from all above
5. **app/**: Can import from all above

## File Size Limits (STRICT)

### Backend Limits
- **Python files**: 300 lines MAXIMUM
- **Test files**: 500 lines MAXIMUM

### Frontend Limits
- **TypeScript files**: 200 lines MAXIMUM
- **Component files**: 200 lines MAXIMUM
- **Service files**: 300 lines MAXIMUM

## Import Organization Rules

### Python Import Order
1. Standard library imports
2. Third-party library imports
3. Local application imports (absolute paths preferred)

### TypeScript Import Order
1. React and React-related imports
2. Third-party library imports
3. Internal imports (using @/ alias)
4. Type-only imports (at the end)

## Error Handling Architecture

### Backend Error Handling
- ALWAYS use FastAPI HTTPException
- ALWAYS return appropriate HTTP status codes
- ALWAYS log errors for debugging

### Frontend Error Handling
- ALWAYS handle error states in components
- ALWAYS display user-friendly error messages
- ALWAYS implement fallbacks for loading failures

## Language Requirements (ABSOLUTE)

### UI Text Language
- **ONLY English** for all user interface text
- **ONLY English** for error messages
- **ONLY English** for tooltips and help text

### Code Language
- **ONLY English** for comments
- **ONLY English** for variable names
- **ONLY English** for function names
- **ONLY English** for documentation