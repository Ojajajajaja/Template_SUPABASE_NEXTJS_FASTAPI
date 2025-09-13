#!/usr/bin/env node

// Script pour démarrer le serveur de développement avec le port défini dans .env.local

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

// Définir le répertoire de travail comme le répertoire du script
const workingDir = process.cwd();

// Lire le fichier .env.local
const envPath = path.join(workingDir, '.env.local');
let port = 3000; // Port par défaut

if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf8');
  const portMatch = envContent.match(/NEXT_FRONTEND_PORT=(\d+)/);
  if (portMatch && portMatch[1]) {
    port = portMatch[1];
  }
}

console.log(`Démarrage du serveur de développement sur le port ${port}...`);

// Démarrer Next.js avec le port spécifié
const child = spawn('next', ['dev', '-p', port], {
  stdio: 'inherit', // Cela permet de transmettre directement la sortie à la console
  cwd: workingDir // Définir explicitement le répertoire de travail
});

// Gérer les erreurs
child.on('error', (error) => {
  console.error(`Erreur lors du démarrage de Next.js: ${error.message}`);
});

// Gérer la fermeture du processus
child.on('close', (code) => {
  if (code !== 0) {
    console.log(`Le processus Next.js s'est arrêté avec le code ${code}`);
  }
});