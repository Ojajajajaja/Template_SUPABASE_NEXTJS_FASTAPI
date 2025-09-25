// Composant de carte de profil utilisateur réutilisable
import { UserProfile, ComponentProps } from '@/types';

interface UserProfileCardProps extends ComponentProps {
  profile: UserProfile;
  isLoading?: boolean;
  showEditButton?: boolean;
  onEdit?: () => void;
}

export const UserProfileCard: React.FC<UserProfileCardProps> = ({
  profile,
  isLoading = false,
  showEditButton = false,
  onEdit,
  className = '',
}) => {
  if (isLoading) {
    return (
      <div className={`bg-white py-4 px-6 shadow rounded ${className}`}>
        <div className="animate-pulse">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {[...Array(6)].map((_, i) => (
              <div key={i}>
                <div className="h-4 bg-gray-200 rounded w-1/3 mb-2"></div>
                <div className="h-5 bg-gray-300 rounded w-2/3"></div>
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className={`bg-white py-4 px-6 shadow rounded ${className}`}>
      <div className="flex justify-between items-start mb-4">
        <h3 className="text-lg font-medium text-gray-900">Profil Utilisateur</h3>
        {showEditButton && onEdit && (
          <button
            onClick={onEdit}
            className="text-sm text-indigo-600 hover:text-indigo-900 font-medium"
          >
            Modifier
          </button>
        )}
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <ProfileField label="Prénom" value={profile.first_name} />
        <ProfileField label="Nom" value={profile.last_name} />
        <ProfileField label="Nom complet" value={profile.full_name} />
        <ProfileField label="Email" value={profile.email} />
        <ProfileField label="Téléphone" value={profile.phone} />
        <ProfileField 
          label="Rôle" 
          value={profile.role} 
          className="capitalize" 
        />
      </div>
    </div>
  );
};

interface ProfileFieldProps {
  label: string;
  value: string;
  className?: string;
}

const ProfileField: React.FC<ProfileFieldProps> = ({ 
  label, 
  value, 
  className = '' 
}) => (
  <div>
    <p className="text-sm font-medium text-gray-500">{label}</p>
    <p className={`text-gray-900 ${className}`}>{value || 'N/A'}</p>
  </div>
);

export default UserProfileCard;