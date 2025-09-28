---
trigger: always_on
alwaysApply: true
---

# Security Rules - CRITICAL ENFORCEMENT

## Environment Variables Security (ABSOLUTE RULES)

### Environment Variable Validation (MANDATORY)
- **ALWAYS** validate critical environment variables at application startup
- **NEVER** proceed if required environment variables are missing
- **ALWAYS** use centralized configuration validation

### Critical Environment Variables (NEVER EXPOSE)
```python
# ✅ CORRECT: Backend-only secrets
# api/config.py
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY", "")
SUPABASE_URL = os.getenv("SUPABASE_URL", "")

# ❌ FORBIDDEN: Frontend exposure
// NEVER do this in frontend code
const serviceKey = process.env.SUPABASE_SERVICE_KEY; // SECURITY VIOLATION
```

### Environment File Rules (STRICT)
- **NEVER** commit .env files with real values
- **ALWAYS** provide .env.example with placeholder values
- **ALWAYS** document all environment variables
- **NEVER** include production credentials in any committed file

## Frontend Security Rules (ABSOLUTE)

### Secret Exposure Prevention (CRITICAL)
- **NEVER** expose service keys in frontend code
- **NEVER** expose JWT secrets in frontend code
- **NEVER** expose database credentials in frontend code
- **NEVER** expose API private keys in frontend code

### Frontend-Safe Variables ONLY
```typescript
// ✅ ALLOWED: Public configuration
const publicConfig = {
  supabaseUrl: process.env.NEXT_PUBLIC_SUPABASE_URL,
  supabaseAnonKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
};

// ❌ FORBIDDEN: Secret variables in frontend
const secrets = {
  serviceKey: process.env.SUPABASE_SERVICE_KEY,    // SECURITY VIOLATION
  jwtSecret: process.env.JWT_SECRET,               // SECURITY VIOLATION
  dbPassword: process.env.DATABASE_PASSWORD        // SECURITY VIOLATION
};
```

## Authentication Security (MANDATORY)

### Token Validation Rules (ABSOLUTE)
- **ALWAYS** validate tokens on server-side ONLY
- **NEVER** validate tokens on client-side
- **ALWAYS** use Supabase Auth for token verification
- **NEVER** trust client-side token validation

### Token Handling Implementation
```python
# ✅ CORRECT: Server-side token validation
async def verify_token(credentials: HTTPAuthorizationCredentials):
    supabase_service = get_supabase_service_client()
    user_response = supabase_service.auth.get_user(credentials.credentials)
    if not user_response or not user_response.user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user_response

# ❌ FORBIDDEN: Client-side token validation
// NEVER do this in frontend
const isValidToken = (token) => {
    return jwt.verify(token, secret); // SECURITY VIOLATION
};
```

### OAuth Security Rules (CRITICAL)
- **ALWAYS** handle OAuth callbacks on backend
- **NEVER** expose OAuth client secrets in frontend
- **ALWAYS** validate OAuth tokens server-side
- **ALWAYS** use secure OAuth flow patterns

## Database Security (ABSOLUTE)

### Database Access Rules (MANDATORY)
- **NEVER** expose database credentials in frontend
- **ALWAYS** use Supabase RLS (Row Level Security)
- **ALWAYS** validate user permissions server-side
- **NEVER** trust client-side database queries

### Supabase Security Implementation
```python
# ✅ CORRECT: Server-side database access with service key
def get_supabase_service_client():
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_KEY)

# ❌ FORBIDDEN: Service key exposure
// NEVER expose service key in frontend
const supabase = createClient(url, serviceKey); // SECURITY VIOLATION
```

## Input Validation Security (MANDATORY)

### Data Validation Rules (ABSOLUTE)
- **ALWAYS** validate all input data with Pydantic models
- **ALWAYS** sanitize user input
- **ALWAYS** validate data types and formats
- **NEVER** trust unvalidated input

### Input Validation Implementation
```python
# ✅ CORRECT: Pydantic validation
class LoginData(BaseModel):
    email: str
    password: str
    
    @validator('email')
    def validate_email(cls, v):
        if not re.match(r'^[^@]+@[^@]+\.[^@]+$', v):
            raise ValueError('Invalid email format')
        return v

# ❌ FORBIDDEN: No validation
@router.post("/login")
async def login(data: dict):  # No validation - SECURITY RISK
    # Direct use without validation
```

## API Security (CRITICAL)

### Endpoint Protection Rules (MANDATORY)
- **ALWAYS** protect sensitive endpoints with authentication
- **ALWAYS** implement proper CORS configuration
- **ALWAYS** validate request origins
- **NEVER** expose internal API endpoints publicly

### CORS Configuration (STRICT)
```python
# ✅ CORRECT: Restricted CORS origins
CORS_ORIGINS = [
    "https://yourdomain.com",
    "http://localhost:3000"  # Only for development
]

# ❌ FORBIDDEN: Permissive CORS
CORS_ORIGINS = ["*"]  # SECURITY VIOLATION
```

### Rate Limiting (RECOMMENDED)
- **ALWAYS** implement rate limiting for authentication endpoints
- **ALWAYS** monitor for suspicious activity
- **ALWAYS** log security events

## File Upload Security (MANDATORY)

### File Validation Rules (STRICT)
- **ALWAYS** validate file types and sizes
- **ALWAYS** scan uploads for malicious content
- **NEVER** execute uploaded files
- **ALWAYS** store uploads in secure locations

### Upload Security Implementation
```python
# ✅ CORRECT: Secure file upload
def validate_upload(file):
    allowed_types = ['image/jpeg', 'image/png', 'image/gif']
    max_size = 5 * 1024 * 1024  # 5MB
    
    if file.content_type not in allowed_types:
        raise HTTPException(400, "Invalid file type")
    if file.size > max_size:
        raise HTTPException(400, "File too large")
```

## Session Security (CRITICAL)

### Session Management Rules (ABSOLUTE)
- **ALWAYS** use secure session cookies
- **ALWAYS** implement session timeout
- **ALWAYS** invalidate sessions on logout
- **NEVER** store sensitive data in sessions

### Session Configuration
```python
# ✅ CORRECT: Secure session settings
SESSION_CONFIG = {
    'httponly': True,
    'secure': True,  # HTTPS only
    'samesite': 'strict',
    'max_age': 3600  # 1 hour
}
```

## Error Handling Security (MANDATORY)

### Error Information Rules (STRICT)
- **NEVER** expose sensitive information in error messages
- **ALWAYS** log detailed errors server-side only
- **ALWAYS** return generic error messages to clients
- **NEVER** expose system internals in errors

### Secure Error Handling
```python
# ✅ CORRECT: Generic error responses
try:
    # Database operation
    pass
except Exception as e:
    logger.error(f"Database error: {e}")  # Log details server-side
    raise HTTPException(500, "Internal server error")  # Generic client message

# ❌ FORBIDDEN: Detailed error exposure
except Exception as e:
    raise HTTPException(500, str(e))  # SECURITY VIOLATION - exposes internals
```

## Logging Security (MANDATORY)

### Logging Rules (CRITICAL)
- **NEVER** log sensitive data (passwords, tokens, secrets)
- **ALWAYS** log security events
- **ALWAYS** protect log files
- **ALWAYS** implement log rotation

### Secure Logging Implementation
```python
# ✅ CORRECT: Secure logging
logger.info(f"User login attempt: {user.email}")
logger.warning(f"Failed login for: {user.email}")

# ❌ FORBIDDEN: Sensitive data logging
logger.info(f"User login: {user.email} with password: {password}")  # VIOLATION
logger.info(f"Token: {access_token}")  # VIOLATION
```

## Deployment Security (ABSOLUTE)

### Production Security Rules (MANDATORY)
- **ALWAYS** use HTTPS in production
- **ALWAYS** enable security headers
- **ALWAYS** use environment-specific configurations
- **NEVER** use debug mode in production

### Security Headers (REQUIRED)
```python
# ✅ REQUIRED: Security headers
SECURITY_HEADERS = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains'
}
```

## Monitoring and Alerting (MANDATORY)

### Security Monitoring Rules (CRITICAL)
- **ALWAYS** monitor for security events
- **ALWAYS** alert on suspicious activity
- **ALWAYS** track authentication failures
- **ALWAYS** monitor for data access patterns

### Health Check Security (REQUIRED)
- **ALWAYS** implement health check endpoints
- **NEVER** expose sensitive information in health checks
- **ALWAYS** monitor application security status

## Backup and Recovery Security (MANDATORY)

### Backup Security Rules (ABSOLUTE)
- **ALWAYS** encrypt backup data
- **ALWAYS** secure backup storage
- **ALWAYS** test backup recovery procedures
- **NEVER** store backups with production data

## Third-Party Security (CRITICAL)

### Dependency Security Rules (MANDATORY)
- **ALWAYS** audit third-party dependencies
- **ALWAYS** keep dependencies updated
- **ALWAYS** monitor for security vulnerabilities
- **NEVER** use deprecated or insecure packages

### Supabase Security Configuration
```python
# ✅ CORRECT: Secure Supabase configuration
supabase_config = {
    'url': settings.SUPABASE_URL,
    'key': settings.SUPABASE_SERVICE_KEY,  # Server-side only
    'options': {
        'schema': 'public',
        'auto_refresh_token': True,
        'persist_session': False  # For server-side usage
    }
}
```

## ENFORCEMENT RULES (ABSOLUTE)

### Security Violations are FORBIDDEN
- Exposing secrets in frontend code
- Client-side token validation
- Permissive CORS configurations
- Missing input validation
- Detailed error message exposure
- Logging sensitive data
- Debug mode in production

### Security Requirements are MANDATORY
- Server-side token validation
- Environment variable validation
- Input data validation
- Secure session management
- Proper error handling
- Security monitoring
- Regular security audits

### Immediate Action Required for Violations
- Code review rejection
- Security patch deployment
- Incident investigation
- Process improvement