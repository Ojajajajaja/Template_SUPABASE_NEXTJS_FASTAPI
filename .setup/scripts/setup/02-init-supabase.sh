#!/bin/bash

# Script to initialize Supabase Docker
echo "Initializing Supabase Docker..."

# Check if supabase directory already exists
if [ -d "supabase" ]; then
    echo "The 'supabase' directory already exists. Renaming to 'supabase_old'..."
    # Rename existing directory
    mv supabase supabase_old
    echo "Successfully renamed."
fi

# Clone Supabase repository with depth 1 for quick retrieval
echo "Cloning Supabase repository..."
git clone --depth 1 https://github.com/supabase/supabase

# Create Supabase project directory
echo "Creating Supabase project directory..."
mkdir supabase-project

# Copy Docker files from cloned repository to project
echo "Copying Docker files..."
cp -rf supabase/docker/* supabase-project

# Copy environment file
echo "Copying environment file..."
cp supabase/docker/.env.example supabase-project/.env.example
cp supabase/docker/.env.example supabase-project/.env

# Remove cloned repository
echo "Cleaning up cloned repository..."
rm -rf supabase/

# Rename project directory to 'supabase'
echo "Finalizing: renaming project directory..."
mv supabase-project supabase

# Additional commands
echo "Copying additional files..."
cp .setup/supabase/.gitignore supabase/

echo "Initialization completed successfully!"
echo "The 'supabase' directory is now ready to be used."