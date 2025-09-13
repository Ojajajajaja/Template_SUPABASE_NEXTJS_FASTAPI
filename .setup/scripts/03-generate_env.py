import os
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

def create_frontend_env(env_vars, jwt_secret, anon_key, service_role_key):
    """Create the frontend .env.local file"""
    content = f"""# Frontend environment variables

NEXT_PUBLIC_API_PREFIX={env_vars.get('API_PREFIX', '/api/v1')}
NEXT_PUBLIC_API_URL=http://localhost:{env_vars.get('API_PORT', '8000')}
NEXT_FRONTEND_PORT={env_vars.get('FRONTEND_PORT', '3000')}
NEXT_PUBLIC_PROJECT_NAME={env_vars.get('PROJECT_NAME', 'TheSuperProject').strip('"')}
"""
    
    # Create the .env.local file in the frontend directory
    with open('frontend/.env.local', 'w') as f:
        f.write(content)
    print("Created .env.local for frontend")

def create_backend_env(env_vars, jwt_secret, anon_key, service_role_key):
    """Create the backend .env file"""
    content = f"""# Backend environment variables

PROJECT_NAME={env_vars.get('PROJECT_NAME', 'TheSuperProject').strip('"')}
SUPABASE_URL=http://localhost:{env_vars.get('KONG_HTTP_PORT', '8000')}
SUPABASE_ANON_KEY={anon_key}
SUPABASE_SERVICE_KEY={service_role_key}
API_PREFIX={env_vars.get('API_PREFIX', '/api/v1')}
API_PORT={env_vars.get('API_PORT', '8000')}
CORS_ORIGINS=http://localhost:{env_vars.get('FRONTEND_PORT', '3000')}
"""
    
    with open('backend/.env', 'w') as f:
        f.write(content)
    print("Created .env for backend")

def update_supabase_env(env_vars, jwt_secret, anon_key, service_role_key, secret_key_base, vault_enc_key):
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
    
    # Write the updated content back to the file
    with open(supabase_env_path, 'w') as f:
        f.write(content)
    print("Updated .env for supabase")

def update_docker_compose_files(project_name):
    """Update docker-compose.yml files with project name"""
    # Replace spaces with hyphens in project name
    project_name_slug = project_name.replace(' ', '-').lower()
    
    # Update main docker-compose.yml
    with open('supabase/docker-compose.yml', 'r') as f:
        content = f.read()
    
    # Update the name
    content = re.sub(r'name:\s*supabase', f'name: {project_name_slug}', content)
    
    # Update container names - put "supabase" first, then service, then project name
    # Format: supabase-{service}-{projectname}
    # We need to replace the current container names which are in the format "{project_name}-{service}"
    content = content.replace('container_name: thesuperproject-studio', 
                             f'container_name: supabase-studio-{project_name_slug}')
    content = content.replace('container_name: thesuperproject-kong', 
                             f'container_name: supabase-kong-{project_name_slug}')
    content = content.replace('container_name: thesuperproject-auth', 
                             f'container_name: supabase-auth-{project_name_slug}')
    content = content.replace('container_name: thesuperproject-rest', 
                             f'container_name: supabase-rest-{project_name_slug}')
    content = content.replace('container_name: thesuperproject-storage', 
                             f'container_name: supabase-storage-{project_name_slug}')
    content = content.replace('container_name: thesuperproject-imgproxy', 
                             f'container_name: supabase-imgproxy-{project_name_slug}')
    content = content.replace('container_name: thesuperproject-meta', 
                             f'container_name: supabase-meta-{project_name_slug}')
    content = content.replace('container_name: thesuperproject-edge-functions', 
                             f'container_name: supabase-edge-functions-{project_name_slug}')
    content = content.replace('container_name: thesuperproject-analytics', 
                             f'container_name: supabase-analytics-{project_name_slug}')
    content = content.replace('container_name: thesuperproject-db', 
                             f'container_name: supabase-db-{project_name_slug}')
    content = content.replace('container_name: thesuperproject-vector', 
                             f'container_name: supabase-vector-{project_name_slug}')
    content = content.replace('container_name: thesuperproject-pooler', 
                             f'container_name: supabase-pooler-{project_name_slug}')
    content = content.replace('container_name: thesuperproject-realtime-dev.supabase-realtime', 
                             f'container_name: supabase-realtime-dev-{project_name_slug}.supabase-realtime')
    
    with open('supabase/docker-compose.yml', 'w') as f:
        f.write(content)
    print("Updated supabase/docker-compose.yml")
    
    # Update docker-compose.s3.yml if it exists
    s3_file_path = 'supabase/docker-compose.s3.yml'
    if os.path.exists(s3_file_path):
        with open(s3_file_path, 'r') as f:
            content_s3 = f.read()
        
        # Update container names in s3 file
        # Format: supabase-{service}-{projectname}
        content_s3 = content_s3.replace('container_name: thesuperproject-storage', 
                                       f'container_name: supabase-storage-{project_name_slug}')
        content_s3 = content_s3.replace('container_name: thesuperproject-imgproxy', 
                                       f'container_name: supabase-imgproxy-{project_name_slug}')
        
        with open(s3_file_path, 'w') as f:
            f.write(content_s3)
        print("Updated supabase/docker-compose.s3.yml")

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

def main():
    # Read .env.config
    env_vars = read_env_config('.setup/.env.config')
    
    # Generate keys
    jwt_secret = generate_jwt_secret()
    anon_key, service_role_key = generate_supabase_keys(jwt_secret)
    secret_key_base, vault_enc_key = generate_encryption_keys()
    
    # Create environment files
    create_frontend_env(env_vars, jwt_secret, anon_key, service_role_key)
    create_backend_env(env_vars, jwt_secret, anon_key, service_role_key)
    update_supabase_env(env_vars, jwt_secret, anon_key, service_role_key, secret_key_base, vault_enc_key)
    
    # Update docker-compose files
    project_name = env_vars.get('PROJECT_NAME', 'TheSuperProject').strip('"')
    update_docker_compose_files(project_name)
    
    # Update .env.config with generated keys
    update_env_config_with_keys(jwt_secret, anon_key, service_role_key, secret_key_base, vault_enc_key)
    
    print("All environment files created successfully!")

if __name__ == "__main__":
    main()