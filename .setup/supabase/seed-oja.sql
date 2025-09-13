-- 1. Création de l'ENUM pour les rôles
-- Utilisation d'un bloc DO pour gérer la création conditionnelle
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('user', 'mod', 'admin', 'superadmin');
  END IF;
END
$$;

-- 2. Table des profils avec full_name, email et téléphone
create table if not exists public.user_profiles (
    id uuid primary key references auth.users (id) on delete cascade,
    username text unique,
    full_name text,
    email text unique,
    phone text,
    role user_role not null default 'user',
    created_at timestamptz not null default now()
);

-- 3. Trigger pour auto-créer le profil à chaque nouvel utilisateur
create or replace function public.handle_new_user()
returns trigger as $$
declare
    v_first_name text;
    v_last_name  text;
    v_full_name  text;
    v_phone      text;
begin
    -- Extraction des métadonnées utilisateur
    v_first_name := new.raw_user_meta_data->>'first_name';
    v_last_name  := new.raw_user_meta_data->>'last_name';
    v_full_name  := new.raw_user_meta_data->>'full_name';
    v_phone      := new.raw_user_meta_data->>'phone';

    -- Si full_name n'est pas fourni, le construire à partir du prénom et nom
    if v_full_name is null then
        v_full_name := concat_ws(' ', v_first_name, v_last_name);
    end if;

    -- Insertion dans la table user_profiles
    insert into public.user_profiles (id, username, full_name, email, phone)
    values (
        new.id,
        new.email,  -- username = email par défaut
        v_full_name,
        new.email,
        v_phone
    );

    return new;
end;
$$ language plpgsql security definer
   set search_path = public;

-- 4. Attacher le trigger à la table des users de Supabase
-- Utilisation d'un bloc DO pour gérer la création conditionnelle du trigger
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created') THEN
    DROP TRIGGER on_auth_user_created ON auth.users;
  END IF;
  
  CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
END
$$;