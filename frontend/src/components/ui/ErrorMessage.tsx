// Composant d'affichage d'erreur réutilisable
import { ComponentProps } from '@/types';

interface ErrorMessageProps extends ComponentProps {
  message: string;
  onDismiss?: () => void;
  variant?: 'error' | 'warning' | 'info';
}

const variantClasses = {
  error: 'bg-red-50 text-red-800 border-red-200',
  warning: 'bg-yellow-50 text-yellow-800 border-yellow-200',
  info: 'bg-blue-50 text-blue-800 border-blue-200',
};

export const ErrorMessage: React.FC<ErrorMessageProps> = ({
  message,
  onDismiss,
  variant = 'error',
  className = '',
}) => {
  return (
    <div className={`border rounded-md p-4 ${variantClasses[variant]} ${className}`}>
      <div className="flex justify-between items-start">
        <p className="text-sm">{message}</p>
        {onDismiss && (
          <button
            onClick={onDismiss}
            className="ml-2 text-current opacity-60 hover:opacity-100"
            aria-label="Fermer"
          >
            <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        )}
      </div>
    </div>
  );
};

export default ErrorMessage;