#!/bin/bash

# Build script for the project
# Executes synchronization commands for backend, frontend and supabase

set -e  # Stop script if a command fails

echo "Starting build script..."

# Synchronize backend with uv
echo "Synchronizing backend..."
cd backend/
uv sync
cd ../

# Install frontend dependencies
echo "Installing frontend dependencies..."
cd frontend/
npm install
cd ../

# Update Docker images for Supabase
echo "Updating Docker images for Supabase..."
cd supabase/

# Check if user has docker permissions
if ! docker info >/dev/null 2>&1; then
    echo "Warning: Docker access denied. This might be due to permissions."
    echo "If you just added the user to docker group, you may need to:"
    echo "  1. Log out and log back in, OR"
    echo "  2. Run: newgrp docker"
    echo "Attempting to continue with current permissions..."
fi

docker compose pull
docker compose up -d

# Wait for database to be ready
echo "Waiting for database to be available..."
sleep 20

# Check that database is really ready
echo "Checking database availability..."
if ! docker compose exec -T db pg_isready -U postgres -d postgres; then
    echo "Warning: Database not ready. Waiting additional time..."
    sleep 10
    docker compose exec -T db pg_isready -U postgres -d postgres
fi

# Copy and execute seed SQL script
echo "Copying seed script to database..."
if ! docker compose cp ../.setup/supabase/seed-oja.sql db:/tmp/seed-oja.sql; then
    echo "Error: Could not copy seed script. Check Docker permissions."
    exit 1
fi

echo "Executing database seed script..."
if ! docker compose exec -T db psql -U postgres -d postgres -f /tmp/seed-oja.sql; then
    echo "Error: Could not execute seed script. Check database connection."
    exit 1
fi

cd ../



echo "Build script completed successfully!"