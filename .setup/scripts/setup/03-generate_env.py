import os
import sys
import time
import secrets
import base64
import hashlib
import re

# Using the system's jwt library instead of requiring external pyjwt
# since we're using uv for dependency management
def generate_jwt_token(payload, secret):
    """Simple JWT token generator without external dependencies"""
    import json
    import hmac
    import hashlib
    import base64
    import time
    
    # Header
    header = {"alg": "HS256", "typ": "JWT"}
    
    # Encode header and payload
    header_encoded = base64.urlsafe_b64encode(json.dumps(header).encode()).decode().rstrip('=')
    payload_encoded = base64.urlsafe_b64encode(json.dumps(payload).encode()).decode().rstrip('=')
    
    # Create signature
    signature_input = f"{header_encoded}.{payload_encoded}"
    signature = hmac.new(secret.encode(), signature_input.encode(), hashlib.sha256).digest()
    signature_encoded = base64.urlsafe_b64encode(signature).decode().rstrip('=')
    
    # Return complete token
    return f"{header_encoded}.{payload_encoded}.{signature_encoded}"

def read_env_config(config_path):
    """Read the .env.config file and return a dictionary of variables"""
    env_vars = {}
    with open(config_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                # Handle both = and == assignments
                if '=' in line and not line.startswith('='):
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.split('#')[0].strip().strip('"').strip("'")
                    # Handle == syntax
                    if key.endswith('='):
                        key = key[:-1]
                    env_vars[key] = value
    return env_vars

def generate_jwt_secret():
    """Generate a random JWT secret"""
    return secrets.token_urlsafe(32)

def generate_supabase_keys(jwt_secret):
    """Generate Supabase ANON and SERVICE_ROLE keys"""
    iat = int(time.time())
    exp = iat + 20 * 365 * 24 * 60 * 60  # 20 years
    
    anon_payload = {
        "role": "anon",
        "iss": "supabase",
        "iat": iat,
        "exp": exp
    }
    
    service_role_payload = {
        "role": "service_role",
        "iss": "supabase",
        "iat": iat,
        "exp": exp
    }
    
    anon_token = generate_jwt_token(anon_payload, jwt_secret)
    service_role_token = generate_jwt_token(service_role_payload, jwt_secret)
    
    return anon_token, service_role_token

def generate_encryption_keys():
    """Generate SECRET_KEY_BASE and VAULT_ENC_KEY"""
    key = secrets.token_bytes(32)
    secret_key_base = base64.b64encode(key).decode()
    vault_enc_key = hashlib.sha256(key).hexdigest()
    return secret_key_base, vault_enc_key

def create_frontend_env(env_vars, jwt_secret, anon_key, service_role_key, deployment_mode='development'):
    """Create the frontend .env.local file"""
    
    if deployment_mode == 'production':
        api_url = f"https://{env_vars.get('BACKEND_DOMAIN', 'api.example.com')}"
    else:
        api_url = f"http://localhost:{env_vars.get('API_PORT', '8000')}"
    
    content = f"""# Frontend environment variables

NEXT_PUBLIC_API_PREFIX={env_vars.get('API_PREFIX', '/api/v1')}
NEXT_PUBLIC_API_URL={api_url}
NEXT_FRONTEND_PORT={env_vars.get('FRONTEND_PORT', '3000')}
NEXT_PUBLIC_PROJECT_NAME={env_vars.get('PROJECT_NAME', 'TheSuperProject').strip('"')}
"""
    
    # Create the .env.local file in the frontend directory
    with open('frontend/.env.local', 'w') as f:
        f.write(content)
    print("Created .env.local for frontend")

def create_backend_env(env_vars, jwt_secret, anon_key, service_role_key, deployment_mode='development'):
    """Create the backend .env file"""
    
    if deployment_mode == 'production':
        supabase_url = f"https://{env_vars.get('SUPABASE_DOMAIN', 'supabase.example.com')}"
        cors_origins = f"https://{env_vars.get('FRONTEND_DOMAIN', 'example.com')}"
    else:
        supabase_url = f"http://localhost:{env_vars.get('KONG_HTTP_PORT', '8000')}"
        cors_origins = f"http://localhost:{env_vars.get('FRONTEND_PORT', '3000')}"
    
    content = f"""# Backend environment variables

PROJECT_NAME={env_vars.get('PROJECT_NAME', 'TheSuperProject').strip('"')}
SUPABASE_URL={supabase_url}
SUPABASE_ANON_KEY={anon_key}
SUPABASE_SERVICE_KEY={service_role_key}
API_PREFIX={env_vars.get('API_PREFIX', '/api/v1')}
API_PORT={env_vars.get('API_PORT', '8000')}
CORS_ORIGINS={cors_origins}
"""
    
    with open('backend/.env', 'w') as f:
        f.write(content)
    print("Created .env for backend")

def update_supabase_env(env_vars, jwt_secret, anon_key, service_role_key, secret_key_base, vault_enc_key, deployment_mode='development'):
    """Update the supabase .env file with the required variables"""
    supabase_env_path = 'supabase/.env'
    
    # Read the existing supabase .env file
    with open(supabase_env_path, 'r') as f:
        content = f.read()
    
    # Update the required variables
    # Passwords
    content = re.sub(r'POSTGRES_PASSWORD=.*', f'POSTGRES_PASSWORD={env_vars.get("PASSWORD_POSTGRES", "passwordpostgres")}', content)
    content = re.sub(r'DASHBOARD_USERNAME=.*', f'DASHBOARD_USERNAME={env_vars.get("USERNAME_SUPABASE", "supabase")}', content)
    content = re.sub(r'DASHBOARD_PASSWORD=.*', f'DASHBOARD_PASSWORD={env_vars.get("PASSWORD_SUPABASE", "passwordsupabase")}', content)
    
    # Keys
    content = re.sub(r'JWT_SECRET=.*', f'JWT_SECRET={jwt_secret}', content)
    content = re.sub(r'ANON_KEY=.*', f'ANON_KEY={anon_key}', content)
    content = re.sub(r'SERVICE_ROLE_KEY=.*', f'SERVICE_ROLE_KEY={service_role_key}', content)
    content = re.sub(r'SECRET_KEY_BASE=.*', f'SECRET_KEY_BASE={secret_key_base}', content)
    content = re.sub(r'VAULT_ENC_KEY=.*', f'VAULT_ENC_KEY={vault_enc_key}', content)
    
    # Ports
    content = re.sub(r'POSTGRES_PORT=.*', f'POSTGRES_PORT={env_vars.get("POSTGRES_PORT", "5432")}', content)
    content = re.sub(r'POOLER_PROXY_PORT_TRANSACTION=.*', f'POOLER_PROXY_PORT_TRANSACTION={env_vars.get("POOLER_PROXY_PORT_TRANSACTION", "6543")}', content)
    content = re.sub(r'KONG_HTTP_PORT=.*', f'KONG_HTTP_PORT={env_vars.get("KONG_HTTP_PORT", "8000")}', content)
    content = re.sub(r'KONG_HTTPS_PORT=.*', f'KONG_HTTPS_PORT={env_vars.get("KONG_HTTPS_PORT", "8443")}', content)
    content = re.sub(r'STUDIO_PORT=.*', f'STUDIO_PORT={env_vars.get("STUDIO_PORT", "3000")}', content)
    
    # Email configuration
    content = re.sub(r'ENABLE_EMAIL_AUTOCONFIRM=.*', f'ENABLE_EMAIL_AUTOCONFIRM={env_vars.get("ENABLE_EMAIL_AUTOCONFIRM", "false")}', content)
    
    # Production or development URLs
    if deployment_mode == 'production':
        supabase_domain = env_vars.get('SUPABASE_DOMAIN', 'supabase.example.com')
        frontend_domain = env_vars.get('FRONTEND_DOMAIN', 'example.com')
        
        api_external_url = f"https://{supabase_domain}"
        supabase_public_url = f"https://{supabase_domain}"
        site_url = f"https://{frontend_domain}"
        additional_redirect_urls = f"https://{frontend_domain}/callback"
    else:
        kong_port = env_vars.get('KONG_HTTP_PORT', '8000')
        frontend_port = env_vars.get('FRONTEND_PORT', '3000')
        
        api_external_url = f"http://localhost:{kong_port}"
        supabase_public_url = f"http://localhost:{kong_port}"
        site_url = f"http://localhost:{frontend_port}"
        additional_redirect_urls = f"http://localhost:{frontend_port}/callback"
    
    # Update URLs
    content = re.sub(r'API_EXTERNAL_URL=.*', f'API_EXTERNAL_URL={api_external_url}', content)
    content = re.sub(r'SUPABASE_PUBLIC_URL=.*', f'SUPABASE_PUBLIC_URL={supabase_public_url}', content)
    content = re.sub(r'SITE_URL=.*', f'SITE_URL={site_url}', content)
    content = re.sub(r'ADDITIONAL_REDIRECT_URLS=.*', f'ADDITIONAL_REDIRECT_URLS={additional_redirect_urls}', content)
    
    # Write the updated content back to the file
    with open(supabase_env_path, 'w') as f:
        f.write(content)
    print("Updated .env for supabase")

def update_env_config_with_keys(jwt_secret, anon_key, service_role_key, secret_key_base, vault_enc_key):
    """Update .env.config file with generated keys, replacing existing ones"""
    env_config_path = '.setup/.env.config'
    
    # Read the existing .env.config file
    with open(env_config_path, 'r') as f:
        content = f.read()
    
    # Remove any existing generated keys section
    if "# Generated keys" in content:
        # Find the start of the generated keys section
        generated_keys_start = content.find("# Generated keys")
        if generated_keys_start != -1:
            # Find the end of the generated keys section (next section or end of file)
            next_section_start = content.find("\n#", generated_keys_start + 1)
            if next_section_start != -1:
                # Remove from generated keys start to next section start
                content = content[:generated_keys_start] + content[next_section_start:]
            else:
                # Remove from generated keys start to end of file
                content = content[:generated_keys_start]
    
    # Add the new generated keys at the end
    content += f"\n# Generated keys\n"
    content += f"SUPABASE_JWT_SECRET={jwt_secret}\n"
    content += f"SUPABASE_ANON_KEY={anon_key}\n"
    content += f"SUPABASE_SERVICE_ROLE_KEY={service_role_key}\n"
    content += f"SECRET_KEY_BASE={secret_key_base}\n"
    content += f"VAULT_ENC_KEY={vault_enc_key}\n"
    
    # Write the updated content back to the file
    with open(env_config_path, 'w') as f:
        f.write(content)
    print("Updated .env.config with generated keys")

def update_supabase_docker_compose(project_name):
    """Update supabase/docker-compose.yml project name"""
    docker_compose_path = 'supabase/docker-compose.yml'
    
    # Check if the docker-compose.yml file exists
    if not os.path.exists(docker_compose_path):
        print(f"Warning: {docker_compose_path} not found, skipping docker-compose update")
        return
    
    try:
        # Replace spaces with hyphens in project name
        project_name_slug = project_name.replace(' ', '-').lower()
        
        # Read the docker-compose.yml file
        with open(docker_compose_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # First: Replace all occurrences of "supabase-" with "supabase-PROJECT_NAME-"
        content = content.replace('supabase-', f'supabase-{project_name_slug}-')
        
        # Second: Update the project name: replace "name: supabase" with "name: supabase-PROJECT_NAME"
        content = re.sub(r'name:\s*supabase\s*$', f'name: supabase-{project_name_slug}', content, flags=re.MULTILINE)
        
        # Write the updated content back to the file
        with open(docker_compose_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"Updated {docker_compose_path} project name to: supabase-{project_name_slug}")
        print(f"Updated all container names: supabase-* -> supabase-{project_name_slug}-*")
        
    except Exception as e:
        print(f"Error updating docker-compose.yml: {e}")
        print("Continuing without docker-compose update...")

def main():
    # Get deployment mode from command line arguments
    deployment_mode = 'development'  # Default
    if len(sys.argv) > 1:
        deployment_mode = sys.argv[1]
    
    print(f"Deployment mode: {deployment_mode}")
    
    # Read .env.config
    env_vars = read_env_config('.setup/.env.config')
    
    # Generate keys
    jwt_secret = generate_jwt_secret()
    anon_key, service_role_key = generate_supabase_keys(jwt_secret)
    secret_key_base, vault_enc_key = generate_encryption_keys()
    
    # Create environment files
    create_frontend_env(env_vars, jwt_secret, anon_key, service_role_key, deployment_mode)
    create_backend_env(env_vars, jwt_secret, anon_key, service_role_key, deployment_mode)
    update_supabase_env(env_vars, jwt_secret, anon_key, service_role_key, secret_key_base, vault_enc_key, deployment_mode)
    
    # Update supabase docker-compose.yml project name
    project_name = env_vars.get('PROJECT_NAME', 'TheSuperProject').strip('"')
    update_supabase_docker_compose(project_name)
    
    # Update .env.config with generated keys
    update_env_config_with_keys(jwt_secret, anon_key, service_role_key, secret_key_base, vault_enc_key)
    
    if deployment_mode == 'production':
        print("Environment files created successfully for PRODUCTION!")
        print(f"Frontend URL: https://{env_vars.get('FRONTEND_DOMAIN', 'example.com')}")
        print(f"Backend URL: https://{env_vars.get('BACKEND_DOMAIN', 'api.example.com')}")
        print(f"Supabase URL: https://{env_vars.get('SUPABASE_DOMAIN', 'supabase.example.com')}")
    else:
        print("Environment files created successfully for DEVELOPMENT!")

if __name__ == "__main__":
    main()