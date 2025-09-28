---
trigger: always_on
alwaysApply: true
---

# Common Mistakes to Avoid - Template SUPABASE NEXTJS FASTAPI

## 🚫 Architecture Anti-Patterns

### Backend Anti-Patterns

#### ❌ Monolithic main.py
```python
# DON'T: Everything in one file
# main.py (500+ lines)
from fastapi import FastAPI
app = FastAPI()

# All routes here
@app.post("/auth/login")
@app.post("/auth/signup") 
@app.get("/user/profile")
# ... 50+ more routes
```

#### ✅ Solution: Modular Structure
```python
# DO: Use the proper architecture
# api/app.py
from api.views import auth_router, user_router

app.include_router(auth_router)
app.include_router(user_router)
```

#### ❌ Direct Database Logic in Routes
```python
# DON'T: Database queries in routes
@router.get("/users")
async def get_users():
    supabase = create_client(url, key)
    result = supabase.table("users").select("*").execute()
    return result.data
```

#### ✅ Solution: Use Helpers
```python
# DO: Separate database logic
# api/helpers/user.py
async def get_all_users():
    supabase = get_supabase_service_client()
    return supabase.table("users").select("*").execute()

# api/views/user.py
@router.get("/users")
async def get_users():
    return await UserHelpers.get_all_users()
```

### Frontend Anti-Patterns

#### ❌ API Calls in Components
```typescript
// DON'T: Direct API calls in components
const UserProfile = () => {
  const [user, setUser] = useState(null);
  
  useEffect(() => {
    fetch('/api/user/profile')
      .then(res => res.json())
      .then(setUser);
  }, []);
  
  return <div>{user?.name}</div>;
};
```

#### ✅ Solution: Use Services
```typescript
// DO: Use centralized services
// services/user.ts
export const userService = {
  getProfile: () => api.get('/user/profile')
};

// components/UserProfile.tsx
const UserProfile = () => {
  const { data: user } = useQuery('user-profile', userService.getProfile);
  return <div>{user?.name}</div>;
};
```

#### ❌ Mixed State Management
```typescript
// DON'T: Scattered state management
const App = () => {
  const [user, setUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);
  
  // Auth logic scattered everywhere
};
```

#### ✅ Solution: Centralized Context
```typescript
// DO: Use AuthContext
const App = () => {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
};
```

## 🔐 Security Mistakes

### ❌ Exposing Secrets
```typescript
// DON'T: Secrets in frontend code
const SUPABASE_SERVICE_KEY = "service_key_123"; // NEVER!

// DON'T: Secrets in git
// .env
SUPABASE_SERVICE_KEY=real_secret_key_here
```

#### ✅ Solution: Proper Secret Management
```python
# DO: Backend only secrets
# api/config.py
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY", "")

# .env.example
SUPABASE_SERVICE_KEY=your_service_key_here
```

### ❌ Client-Side Token Validation
```typescript
// DON'T: Validate tokens on frontend
const isValidToken = (token: string) => {
  // Client-side validation is not secure
  return jwt.verify(token, secret);
};
```

#### ✅ Solution: Server-Side Validation
```python
# DO: Always validate on backend
async def verify_token(credentials: HTTPAuthorizationCredentials):
    supabase_service = get_supabase_service_client()
    user_response = supabase_service.auth.get_user(credentials.credentials)
    # Proper server-side validation
```

## 🎨 UI/UX Mistakes

### ❌ Wrong OAuth Button Style (Against User Preference)
```tsx
// DON'T: Text-based OAuth buttons
<Button>
  <GoogleIcon />
  Sign in with Google
</Button>
```

#### ✅ Solution: Icon-Only Buttons (User Preference)
```tsx
// DO: Icon-only minimalist style
<Button variant="outline" size="icon" aria-label="Sign in with Google">
  <GoogleIcon />
</Button>
```

### ❌ French UI Text (Against Project Requirements)
```typescript
// DON'T: French interface text
const messages = {
  login: "Se connecter",
  email: "Adresse e-mail",
  password: "Mot de passe"
};
```

#### ✅ Solution: English UI (Project Requirement)
```typescript
// DO: English interface text
const messages = {
  login: "Sign In",
  email: "Email Address", 
  password: "Password"
};
```

### ❌ Hardcoded Text in Components
```tsx
// DON'T: Hardcoded strings
const LoginForm = () => (
  <form>
    <label>Email</label>
    <label>Password</label>
    <button>Sign In</button>
  </form>
);
```

#### ✅ Solution: Centralized Text
```tsx
// DO: Use constants or i18n
import { messages } from '@/lib/messages';

const LoginForm = () => (
  <form>
    <label>{messages.auth.email}</label>
    <label>{messages.auth.password}</label>
    <button>{messages.auth.signIn}</button>
  </form>
);
```

## 🔧 Development Mistakes

### ❌ Wrong Development Commands
```bash
# DON'T: Use old or wrong commands
python main.py  # Old way
npm start       # Wrong for dev mode
```

#### ✅ Solution: Proper Commands
```bash
# DO: Use the standardized commands
uv run run.py dev     # Backend development
npm run dev           # Frontend development
```

### ❌ Mixed Package Managers
```bash
# DON'T: Mix package managers
pip install fastapi   # Should use UV
yarn add react        # Should use npm
```

#### ✅ Solution: Consistent Tools
```bash
# DO: Use project-defined tools
uv add fastapi        # Backend dependencies
npm install react     # Frontend dependencies
```

### ❌ Committing Generated Files
```bash
# DON'T: Commit these files
git add __pycache__/
git add .next/
git add node_modules/
git add .env
```

#### ✅ Solution: Proper .gitignore
```gitignore
# DO: Use proper .gitignore
__pycache__/
.next/
node_modules/
.env
*.pyc
```

## 📦 Import Mistakes

### ❌ Circular Imports
```python
# DON'T: Circular dependencies
# api/models/user.py
from api.helpers.auth import verify_user

# api/helpers/auth.py  
from api.models.user import User  # Circular!
```

#### ✅ Solution: Proper Dependency Direction
```python
# DO: Clear dependency hierarchy
# api/models/ -> Base models (no internal imports)
# api/helpers/ -> Can import from models
# api/views/ -> Can import from helpers and models
```

### ❌ Relative Import Mess
```python
# DON'T: Complex relative imports
from ...models.user import User
from ....helpers.auth import verify_token
```

#### ✅ Solution: Absolute Imports
```python
# DO: Use absolute imports
from api.models.user import User
from api.helpers.auth import verify_token
```

## 🧪 Testing Mistakes

### ❌ No Tests for Critical Paths
```python
# DON'T: Skip testing authentication
# No tests for login, signup, token validation
```

#### ✅ Solution: Test Critical Features
```python
# DO: Test authentication flows
def test_login_success():
    # Test successful login
    pass

def test_login_invalid_credentials():
    # Test failed login
    pass

def test_token_validation():
    # Test token verification
    pass
```

### ❌ Tests with External Dependencies
```python
# DON'T: Test against real Supabase
def test_user_creation():
    supabase = create_client(REAL_URL, REAL_KEY)  # Bad!
    # This will affect production data
```

#### ✅ Solution: Mock External Services
```python
# DO: Mock external dependencies
@patch('api.helpers.auth.get_supabase_service_client')
def test_user_creation(mock_supabase):
    mock_supabase.return_value.auth.sign_up.return_value = mock_response
    # Test with mocked service
```

## 🚀 Deployment Mistakes

### ❌ Wrong Production Configuration
```python
# DON'T: Debug mode in production
DEBUG = True  # Never in production!
CORS_ORIGINS = ["*"]  # Too permissive!
```

#### ✅ Solution: Environment-Aware Config
```python
# DO: Environment-specific settings
DEBUG = os.getenv("ENVIRONMENT") == "development"
CORS_ORIGINS = get_cors_origins_for_env()
```

### ❌ Missing Health Checks
```python
# DON'T: No health endpoints
# Production app without health checks
```

#### ✅ Solution: Implement Health Checks
```python
# DO: Include health endpoints
@router.get("/health")
def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow()}
```

## 📊 Performance Mistakes

### ❌ Blocking Operations
```python
# DON'T: Synchronous I/O operations
def get_user_data(user_id):
    response = requests.get(f"/api/users/{user_id}")  # Blocks!
    return response.json()
```

#### ✅ Solution: Async Operations
```python
# DO: Use async for I/O
async def get_user_data(user_id):
    async with httpx.AsyncClient() as client:
        response = await client.get(f"/api/users/{user_id}")
        return response.json()
```

### ❌ N+1 Query Problem
```typescript
// DON'T: Multiple API calls in loops
const UserList = ({ userIds }) => {
  const [users, setUsers] = useState([]);
  
  useEffect(() => {
    userIds.forEach(async id => {
      const user = await fetchUser(id);  // N+1 problem!
      setUsers(prev => [...prev, user]);
    });
  }, [userIds]);
};
```

#### ✅ Solution: Batch Operations
```typescript
// DO: Batch API calls
const UserList = ({ userIds }) => {
  const { data: users } = useQuery(
    ['users', userIds],
    () => fetchUsers(userIds)  // Single batch call
  );
};
```

## 🔍 Code Quality Mistakes

### ❌ No Error Handling
```python
# DON'T: Ignore potential errors
@router.post("/auth/login")
async def login(credentials: LoginData):
    user = supabase.auth.sign_in_with_password(credentials)
    return user  # What if this fails?
```

#### ✅ Solution: Proper Error Handling
```python
# DO: Handle errors appropriately
@router.post("/auth/login")
async def login(credentials: LoginData):
    try:
        user = supabase.auth.sign_in_with_password(credentials)
        return user
    except Exception as e:
        raise HTTPException(status_code=401, detail="Authentication failed")
```

### ❌ Magic Numbers and Strings
```python
# DON'T: Magic values
if user.role == "admin":  # Magic string
    timeout = 3600  # Magic number
```

#### ✅ Solution: Named Constants
```python
# DO: Use named constants
class UserRoles:
    ADMIN = "admin"
    USER = "user"

class TimeoutSettings:
    SESSION_TIMEOUT = 3600  # 1 hour

if user.role == UserRoles.ADMIN:
    timeout = TimeoutSettings.SESSION_TIMEOUT
```

## 📋 Quick Mistake Checklist

Before committing, check for these common mistakes:

- [ ] No monolithic files > 300 lines
- [ ] No secrets in frontend code
- [ ] No French text in UI (English only)
- [ ] OAuth buttons are icon-only
- [ ] Using proper development commands
- [ ] No circular imports
- [ ] Error handling implemented
- [ ] Tests for critical paths
- [ ] No generated files committed
- [ ] Environment variables properly managed
- [ ] Async operations for I/O
- [ ] Proper CORS configuration
- [ ] Health check endpoints included

## 🎯 Red Flags to Watch For

### Immediate Action Required
- Secrets committed to git
- Production credentials in code
- Services down due to missing env vars
- Authentication bypassed or broken

### Code Review Blockers
- Monolithic architecture violations
- Missing error handling in auth flows
- French text in user interface
- Direct database queries in routes
- No tests for new auth features

### Performance Concerns
- Synchronous operations in async contexts
- N+1 query patterns
- Missing pagination on large datasets
- Unoptimized database queries