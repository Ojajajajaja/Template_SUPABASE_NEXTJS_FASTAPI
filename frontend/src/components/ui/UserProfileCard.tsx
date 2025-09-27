// Reusable user profile card component
import { UserProfile, ComponentProps } from '@/types';
import { Card, CardContent } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';

interface UserProfileCardProps extends ComponentProps {
  profile: UserProfile;
  isLoading?: boolean;
  showEditButton?: boolean;
}

export const UserProfileCard: React.FC<UserProfileCardProps> = ({
  profile,
  isLoading = false,
  showEditButton = false,
  className = '',
}) => {
  if (isLoading) {
    return (
      <Card className={className}>
        <CardContent className="pt-6">
          <div className="flex justify-between items-start mb-4">
            <Skeleton className="h-6 w-32" />
            {showEditButton && <Skeleton className="h-8 w-16" />}
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="space-y-2">
                <Skeleton className="h-4 w-20" />
                <Skeleton className="h-5 w-32" />
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={className}>
      <CardContent className="pt-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <ProfileField label="First Name" value={profile.first_name} />
          <ProfileField label="Last Name" value={profile.last_name} />
          <ProfileField label="Full Name" value={profile.full_name} />
          <ProfileField label="Email" value={profile.email} />
          <ProfileField label="Phone" value={profile.phone} />
          <ProfileField 
            label="Role" 
            value={profile.role} 
            className="capitalize" 
          />
        </div>
      </CardContent>
    </Card>
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
  <div className="space-y-1">
    <p className="text-sm font-medium text-muted-foreground">{label}</p>
    <p className={`text-foreground ${className}`}>{value || 'N/A'}</p>
  </div>
);

export default UserProfileCard;