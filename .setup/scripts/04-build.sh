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
docker compose pull
docker compose up -d

# Wait for database to be ready
echo "Waiting for database to be available..."
sleep 20

# Check that database is really ready
echo "Checking database availability..."
docker compose exec -T db pg_isready -U postgres -d postgres

# Copy and execute seed SQL script
echo "Copying seed script to database..."
docker compose cp ../.setup/supabase/seed-oja.sql db:/tmp/seed-oja.sql

echo "Executing database seed script..."
docker compose exec -T db psql -U postgres -d postgres -f /tmp/seed-oja.sql

cd ../

# Remove .git directory
echo "Removing .git directory..."
rm -rf .git

echo "Build script completed successfully!"