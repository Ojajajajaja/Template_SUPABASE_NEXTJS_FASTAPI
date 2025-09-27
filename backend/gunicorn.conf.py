# Gunicorn configuration file for FastAPI
# Configuration optimisée pour la production

import multiprocessing
import os

# Server Socket
bind = f"0.0.0.0:{os.getenv('API_PORT', 8000)}"

# Worker processes
# Formule recommandée : (2 x CPU cores) + 1
workers = multiprocessing.cpu_count() * 2 + 1

# Type de worker pour FastAPI (ASGI)
worker_class = "uvicorn.workers.UvicornWorker"

# Worker connections (pour les workers async)
worker_connections = 1000

# Timeout configuration
timeout = 120
keepalive = 60

# Maximum requests per worker (pour éviter les fuites mémoire)
max_requests = 1000
max_requests_jitter = 100

# Preload application (améliore les performances)
# ATTENTION: peut causer des problèmes avec Supabase en local
# Désactivé pour éviter les problèmes de connexions partagées
preload_app = False

# Logging
accesslog = "-"
errorlog = "-"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = "fastapi_backend"

# Security
limit_request_line = 8190
limit_request_fields = 100
limit_request_field_size = 8190

# Enable statsd for monitoring (optionnel)
# statsd_host = "localhost:8125"

# Worker restarts
# Redémarre automatiquement les workers qui consomment trop de mémoire
# worker_tmp_dir = "/dev/shm"  # Linux only, commenté pour macOS
worker_tmp_dir = None  # Utilise le répertoire temporaire par défaut

# Graceful timeout pour les restarts
graceful_timeout = 30

# SSL (si nécessaire en production)
# keyfile = "/path/to/keyfile"
# certfile = "/path/to/certfile"

# User/Group pour la sécurité (en production)
# user = "www-data"
# group = "www-data"

# Configuration des signaux
forwarded_allow_ips = "*"
proxy_allow_ips = "*"

# Amélioration des performances
sendfile = True

# Configuration d'environnement
def when_ready(server):
    """Appelé quand le serveur est prêt à recevoir des requêtes"""
    server.log.info("Server is ready. Spawning workers")

def worker_int(worker):
    """Appelé quand un worker reçoit un signal INT ou QUIT"""
    worker.log.info("worker received INT or QUIT signal")

def pre_fork(server, worker):
    """Appelé avant de créer un worker"""
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def post_fork(server, worker):
    """Appelé après la création d'un worker"""
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def pre_exec(server):
    """Appelé avant l'exécution du serveur"""
    server.log.info("Forked child, re-executing.")

def worker_abort(worker):
    """Appelé quand un worker est aborté"""
    worker.log.info("worker received SIGABRT signal")