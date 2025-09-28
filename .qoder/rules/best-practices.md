---
trigger: always_on
alwaysApply: true
---

# Best Practices - Template SUPABASE NEXTJS FASTAPI

## 📐 Code Organization Patterns

### Backend Module Pattern
```python
# ✅ CORRECT: Structured module
# api/views/auth.py
from fastapi import APIRouter
from api.models import AuthModels
from api.helpers import AuthHelpers

router = APIRouter()

@router.post("/login")
async def login(data: AuthModels.LoginData):
    return await AuthHelpers.authenticate_user(data)
```

```python
# ❌ INCORRECT: Monolithic approach
# All auth logic in one massive file
```

### Frontend Component Pattern
```typescript
// ✅ CORRECT: Clean component structure
// components/auth/LoginForm.tsx
interface LoginFormProps {
  onSuccess: (user: User) => void;
  onError: (error: string) => void;
}

export const LoginForm: React.FC<LoginFormProps> = ({ onSuccess, onError }) => {
  // Component logic here
};
```

```typescript
// ❌ INCORRECT: Mixed concerns
// Component doing API calls, state management, and UI
```

## 🔄 Data Flow Patterns

### API Service Pattern
```typescript
// ✅ CORRECT: Centralized API service
// services/auth.ts
export const authService = {
  login: async (credentials: LoginData): Promise<AuthResponse> => {
    const response = await api.post('/auth/login', credentials);
    return response.data;
  }
};

// components/LoginForm.tsx
import { authService } from '@/services/auth';
```

```typescript
// ❌ INCORRECT: Direct fetch in components
const LoginForm = () => {
  const handleLogin = async () => {
    const response = await fetch('/api/auth/login', { ... });
    // Direct API call in component
  };
};
```

### State Management Pattern
```typescript
// ✅ CORRECT: Context-based state management
// lib/contexts/AuthContext.tsx
export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  
  // Auth logic here
  
  return (
    <AuthContext.Provider value={{ user, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};
```

## 🛡️ Security Patterns

### Environment Variables Pattern
```python
# ✅ CORRECT: Centralized config validation
# api/config.py
class Settings:
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_SERVICE_KEY: str = os.getenv("SUPABASE_SERVICE_KEY", "")
    
    def validate_env_vars(self) -> None:
        required = {"SUPABASE_URL": self.SUPABASE_URL}
        missing = [k for k, v in required.items() if not v]
        if missing:
            raise ValueError(f"Missing env vars: {missing}")
```

```python
# ❌ INCORRECT: Scattered env access
SUPABASE_URL = os.getenv("SUPABASE_URL")  # In multiple files
```

### Token Handling Pattern
```typescript
// ✅ CORRECT: Secure token management
// lib/auth.ts
export const getAuthToken = (): string | null => {
  // Get from secure storage
  return localStorage.getItem('auth_token');
};

export const setAuthToken = (token: string): void => {
  localStorage.setItem('auth_token', token);
};
```

## 🎨 UI Component Patterns

### OAuth Button Pattern (Following User Preference)
```tsx
// ✅ CORRECT: Icon-only OAuth buttons (User Preference)
interface OAuthButtonProps {
  provider: 'google' | 'github';
  onClick: () => void;
}

export const OAuthButton: React.FC<OAuthButtonProps> = ({ provider, onClick }) => {
  const icons = {
    google: <GoogleIcon />,
    github: <GitHubIcon />
  };
  
  return (
    <Button
      variant="outline"
      size="icon"
      onClick={onClick}
      aria-label={`Sign in with ${provider}`}
    >
      {icons[provider]}
    </Button>
  );
};
```

```tsx
// ❌ INCORRECT: Text-based OAuth buttons (Against user preference)
<Button>Sign in with Google</Button>
```

### Responsive Component Pattern
```tsx
// ✅ CORRECT: Mobile-first responsive design
export const Navigation = () => {
  return (
    <nav className="flex flex-col md:flex-row gap-4 md:gap-8">
      <UserMenu />
      <ThemeToggle />
    </nav>
  );
};
```

## 🔧 Error Handling Patterns

### Backend Error Pattern
```python
# ✅ CORRECT: Structured error handling
# api/helpers/errors.py
class AuthenticationError(HTTPException):
    def __init__(self, detail: str = "Authentication failed"):
        super().__init__(status_code=401, detail=detail)

# api/views/auth.py
@router.post("/login")
async def login(data: LoginData):
    try:
        return await authenticate_user(data)
    except InvalidCredentials:
        raise AuthenticationError("Invalid email or password")
```

### Frontend Error Pattern
```typescript
// ✅ CORRECT: User-friendly error handling
export const useAuth = () => {
  const [error, setError] = useState<string | null>(null);
  
  const login = async (credentials: LoginData) => {
    try {
      setError(null);
      const result = await authService.login(credentials);
      return result;
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Login failed';
      setError(message);
      throw err;
    }
  };
  
  return { login, error };
};
```

## 📦 Dependency Management Patterns

### Backend Dependencies
```toml
# ✅ CORRECT: Organized pyproject.toml
[project]
name = "backend-api"
dependencies = [
    "fastapi>=0.104.0",
    "uvicorn[standard]>=0.24.0",
    "supabase>=2.0.0",
    "pydantic>=2.5.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "black>=23.0.0",
    "ruff>=0.1.0",
]
```

### Frontend Dependencies
```json
// ✅ CORRECT: Clear package.json structure
{
  "dependencies": {
    "next": "14.0.0",
    "react": "18.2.0",
    "@supabase/supabase-js": "^2.38.0"
  },
  "devDependencies": {
    "@types/react": "18.2.0",
    "typescript": "5.2.0",
    "eslint": "8.52.0"
  }
}
```

## 🧪 Testing Patterns

### Backend Testing Pattern
```python
# ✅ CORRECT: Isolated unit tests
# tests/test_auth.py
import pytest
from api.helpers.auth import verify_token

@pytest.fixture
def mock_supabase_client():
    # Mock Supabase client
    pass

async def test_verify_token_valid(mock_supabase_client):
    # Test with valid token
    result = await verify_token("valid_token")
    assert result.user is not None
```

### Frontend Testing Pattern
```typescript
// ✅ CORRECT: Component testing
// __tests__/LoginForm.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { LoginForm } from '@/components/auth/LoginForm';

describe('LoginForm', () => {
  it('should call onSuccess when login succeeds', async () => {
    const mockOnSuccess = jest.fn();
    render(<LoginForm onSuccess={mockOnSuccess} onError={jest.fn()} />);
    
    // Test implementation
  });
});
```

## 📊 Performance Patterns

### Backend Performance
```python
# ✅ CORRECT: Async operations
async def get_user_profile(user_id: str):
    async with get_db_session() as session:
        result = await session.execute(
            select(UserProfile).where(UserProfile.id == user_id)
        )
        return result.scalar_one_or_none()
```

### Frontend Performance
```typescript
// ✅ CORRECT: Optimized components
import { memo, useMemo } from 'react';

export const UserList = memo(({ users, filter }) => {
  const filteredUsers = useMemo(() => 
    users.filter(user => user.name.includes(filter)),
    [users, filter]
  );
  
  return (
    <div>
      {filteredUsers.map(user => <UserCard key={user.id} user={user} />)}
    </div>
  );
});
```

## 🌐 Internationalization Patterns

### Text Content (English Only - Per Project Requirements)
```typescript
// ✅ CORRECT: English interface text
export const messages = {
  login: {
    title: "Sign In",
    email: "Email Address",
    password: "Password",
    submit: "Sign In",
    forgotPassword: "Forgot your password?",
  },
  errors: {
    invalidCredentials: "Invalid email or password",
    networkError: "Connection failed. Please try again.",
  }
};
```

```typescript
// ❌ INCORRECT: Mixed languages or French UI
const messages = {
  title: "Se connecter", // French not allowed for UI
  submit: "Connexion",
};
```

## 📋 Documentation Patterns

### Code Documentation
```python
# ✅ CORRECT: Clear docstrings
async def authenticate_user(credentials: LoginData) -> AuthResponse:
    """
    Authenticate a user with email and password.
    
    Args:
        credentials: User login credentials containing email and password
        
    Returns:
        AuthResponse: Contains access token and user information
        
    Raises:
        AuthenticationError: When credentials are invalid
        HTTPException: When Supabase service is unavailable
    """
    # Implementation here
```

### API Documentation
```python
# ✅ CORRECT: FastAPI endpoint documentation
@router.post(
    "/login",
    response_model=AuthResponse,
    summary="User authentication",
    description="Authenticate user with email and password credentials",
    responses={
        200: {"description": "Successfully authenticated"},
        401: {"description": "Invalid credentials"},
        500: {"description": "Server error"}
    }
)
async def login(credentials: LoginData):
    # Implementation here
```

## 🚀 Deployment Patterns

### Environment-Specific Configs
```python
# ✅ CORRECT: Environment-aware configuration
class Settings:
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    DEBUG: bool = ENVIRONMENT == "development"
    
    @property
    def cors_origins(self) -> List[str]:
        if self.ENVIRONMENT == "production":
            return ["https://yourdomain.com"]
        return ["http://localhost:3000"]
```

---

## 🎯 Checklist Before Every Commit

- [ ] Code follows the architectural patterns defined
- [ ] No sensitive data in commit
- [ ] Tests pass locally
- [ ] Imports are organized and clean
- [ ] Error handling is implemented
- [ ] UI text is in English
- [ ] OAuth buttons use icons only
- [ ] Dependencies are properly declared
- [ ] Documentation is updated if needed
- [ ] Performance considerations addressed

## 🔍 Code Review Focus Areas

1. **Architecture Compliance**: Does the code follow the modular structure?
2. **Security**: Are secrets properly handled?
3. **Performance**: Are there any obvious bottlenecks?
4. **User Experience**: Is the UI consistent and accessible?
5. **Maintainability**: Is the code easy to understand and modify?
6. **Testing**: Are critical paths covered by tests?