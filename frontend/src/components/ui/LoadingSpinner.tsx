// Composant de chargement réutilisable
import { ComponentProps } from '@/types';

interface LoadingSpinnerProps extends ComponentProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
  color?: 'indigo' | 'blue' | 'green' | 'red' | 'gray';
  text?: string;
}

const sizeClasses = {
  sm: 'h-4 w-4',
  md: 'h-8 w-8', 
  lg: 'h-16 w-16',
  xl: 'h-32 w-32',
};

const colorClasses = {
  indigo: 'border-indigo-500',
  blue: 'border-blue-500',
  green: 'border-green-500', 
  red: 'border-red-500',
  gray: 'border-gray-500',
};

export const LoadingSpinner: React.FC<LoadingSpinnerProps> = ({
  size = 'md',
  color = 'indigo',
  text,
  className = '',
}) => {
  return (
    <div className={`flex flex-col items-center justify-center ${className}`}>
      <div
        className={`animate-spin rounded-full border-t-2 border-b-2 ${sizeClasses[size]} ${colorClasses[color]}`}
      />
      {text && (
        <p className="mt-2 text-sm text-gray-600">{text}</p>
      )}
    </div>
  );
};

export default LoadingSpinner;