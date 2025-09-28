---
trigger: always_on
alwaysApply: true
---

# Qoder Rules - Template SUPABASE NEXTJS FASTAPI

## 🏗️ Architecture Guidelines

### Backend Structure (FastAPI)
- **ALWAYS** respect the modular architecture in `backend/api/`
- **NEVER** put business logic in a single monolithic file
- **ALWAYS** use separation of concerns:
  - `models/` : Pydantic models only
  - `views/` : Routes and business logic
  - `helpers/` : Reusable utility functions
  - `schemas/` : Database definitions
  - `config.py` : Centralized configuration

### Frontend Structure (Next.js)
- **ALWAYS** organize by functional domains in `src/`
- **ALWAYS** use reusable components in `components/`
- **ALWAYS** centralize API services in `services/`
- **ALWAYS** manage global state in `lib/contexts/`

## 🔧 Development Standards

### Code Quality
- **ALWAYS** use TypeScript for frontend
- **ALWAYS** properly type Python functions with type hints
- **ALWAYS** validate data with Pydantic (backend) and Zod/TypeScript (frontend)
- **NEVER** use `any` in TypeScript without justification
- **ALWAYS** handle errors appropriately

### File Organization
- **ALWAYS** create an `__init__.py` file in each Python package
- **ALWAYS** export modules via `__all__` in `__init__.py`
- **ALWAYS** use absolute imports rather than relative when possible
- **ALWAYS** group imports by categories (standard, third-party, local)

### Dependencies Management
- **ALWAYS** use UV for Python (`uv add`, `uv remove`)
- **ALWAYS** use npm/pnpm for Node.js
- **NEVER** install dependencies globally without declaring them
- **ALWAYS** keep `pyproject.toml` and `package.json` up to date

## 🔐 Authentication & Security

### OAuth Implementation
- **ALWAYS** use only provider icons (Google, GitHub) without text
- **ALWAYS** handle tokens on backend side only
- **ALWAYS** validate tokens with Supabase Auth
- **NEVER** expose secret keys on frontend

### Environment Variables
- **ALWAYS** centralize configuration in `backend/api/config.py`
- **ALWAYS** validate critical environment variables at startup
- **NEVER** commit `.env` files with real keys
- **ALWAYS** document variables in `.env.example`

## 🎨 UI/UX Standards

### Language & Content
- **ALWAYS** use English for user interface
- **ALWAYS** use English for tooltips and messages
- **ALWAYS** comment frontend code in English

### Component Design
- **ALWAYS** create reusable components
- **ALWAYS** use shadcn/ui as component base
- **ALWAYS** implement minimalist and elegant design
- **ALWAYS** support dark/light mode

## 🚀 Deployment & Running

### Development Mode
- **ALWAYS** use `uv run run.py dev` for backend
- **ALWAYS** use `npm run dev` for frontend
- **ALWAYS** enable automatic reload in development

### Production Mode
- **ALWAYS** use `uv run run.py prod` for backend in production
- **ALWAYS** use Gunicorn with multiple workers in production
- **ALWAYS** optimize frontend builds with Next.js

## 📝 Documentation

### Code Documentation
- **ALWAYS** document complex functions with docstrings
- **ALWAYS** use explicit variable and function names
- **ALWAYS** maintain up-to-date README for each main module

### API Documentation
- **ALWAYS** document FastAPI endpoints with clear descriptions
- **ALWAYS** use Pydantic models for automatic documentation
- **ALWAYS** include request/response examples

## 🧪 Testing Standards

### Test Organization
- **ALWAYS** create tests in the `tests/` folder
- **ALWAYS** test critical endpoints (auth, user management)
- **ALWAYS** mock external services (Supabase)

### Test Execution
- **ALWAYS** ensure tests pass before making changes
- **ALWAYS** test in isolation (no external dependencies)

## ⚠️ Error Handling

### Backend Errors
- **ALWAYS** use FastAPI HTTPException
- **ALWAYS** return appropriate HTTP status codes
- **ALWAYS** log errors for debugging

### Frontend Errors
- **ALWAYS** handle error states in components
- **ALWAYS** display user-friendly error messages
- **ALWAYS** implement fallbacks for loading failures

## 🔨 Refactoring Guidelines

### When to Refactor
- **ALWAYS** refactor when a file exceeds 300 lines
- **ALWAYS** extract duplicated logic into helpers
- **ALWAYS** separate mixed responsibilities

### How to Refactor
- **ALWAYS** create tests before refactoring
- **ALWAYS** refactor in small steps
- **ALWAYS** maintain compatibility during transition

## 📋 Code Review Checklist

### Before Making Changes
- [ ] Code follows the defined modular architecture
- [ ] All imports are correct and organized
- [ ] Environment variables documented if new
- [ ] Tests pass and cover new cases
- [ ] Documentation updated if necessary
- [ ] No temporary or cache files included

### During Review
- [ ] Business logic in the right modules
- [ ] Appropriate error handling
- [ ] Acceptable performance
- [ ] Security respected (no exposed secrets)
- [ ] UI/UX consistent with design system

## 🔮 Future Considerations

### Scalability
- **ALWAYS** think about scalability when adding features
- **ALWAYS** optimize database/API queries
- **ALWAYS** implement pagination for lists

### Maintenance
- **ALWAYS** keep dependencies up to date
- **ALWAYS** clean up obsolete code regularly
- **ALWAYS** monitor production performance

---

## 🎯 Enforcement

These rules must be followed strictly to maintain codebase quality and consistency. Any deviation must be justified and documented.