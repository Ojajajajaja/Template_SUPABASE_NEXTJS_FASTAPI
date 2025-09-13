// Hook personnalisé pour accéder à la configuration du projet
import { config } from '../config';

export const useConfig = () => {
  return config;
};