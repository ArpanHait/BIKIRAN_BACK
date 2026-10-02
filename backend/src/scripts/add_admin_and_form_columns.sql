-- ============================================================================
-- 🚀 Bikiran Career Mitra — Add 'role' (Admin) and 'form_submitted' Columns
-- Database: Supabase PostgreSQL (public.profiles)
-- ============================================================================

-- 1. Add 'role' column for Admin access (Default: 'general')
-- Allowed values: 'general', 'admin'
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'general' 
CHECK (role IN ('general', 'admin'));

-- 2. Add 'form_submitted' column for Tracking In-App Form Submissions (Default: 'no')
-- Allowed values: 'yes', 'no'
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS form_submitted TEXT DEFAULT 'no' 
CHECK (form_submitted IN ('yes', 'no'));

-- 3. (Optional) Backfill any existing NULL records to default values
UPDATE public.profiles 
SET role = 'general' 
WHERE role IS NULL;

UPDATE public.profiles 
SET form_submitted = 'no' 
WHERE form_submitted IS NULL;

-- 4. Create index on role and form_submitted for fast admin queries
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_form_submitted ON public.profiles(form_submitted);

-- 5. Update auth signup trigger to automatically save all new users as 'general' & 'no'
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    email,
    first_name,
    last_name,
    gender,
    whatsapp_number,
    mobile_number,
    class_level,
    stream,
    school_name,
    state,
    subscription_tier,
    role,
    form_submitted
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'gender', 'Male'),
    COALESCE(NEW.raw_user_meta_data->>'whatsapp_number', ''),
    COALESCE(NEW.raw_user_meta_data->>'mobile_number', ''),
    COALESCE(NEW.raw_user_meta_data->>'class_level', 'Class 12'),
    COALESCE(NEW.raw_user_meta_data->>'stream', 'Science Stream'),
    COALESCE(NEW.raw_user_meta_data->>'school_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'state', 'West Bengal'),
    COALESCE(NEW.raw_user_meta_data->>'subscription_tier', 'basic'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'general'),
    COALESCE(NEW.raw_user_meta_data->>'form_submitted', 'no')
  )
  ON CONFLICT (id) DO UPDATE SET
    role = COALESCE(public.profiles.role, 'general'),
    form_submitted = COALESCE(public.profiles.form_submitted, 'no'),
    last_login_at = now(),
    updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 👑 HELPER QUERIES FOR YOUR ORGANIZATION:
-- ============================================================================

-- 👉 How to grant ADMIN access to an organization member:
UPDATE public.profiles 
SET role = 'admin' 
WHERE email = 'your-member-email@bikiran.org';

-- 👉 How to mark a user's form as submitted ('yes'):
UPDATE public.profiles 
SET form_submitted = 'yes' 
WHERE email = 'student-email@example.com';

-- 👉 How to list all organization admins:
SELECT id, email, first_name, last_name, role, created_at 
FROM public.profiles 
WHERE role = 'admin';

-- 👉 How to list all users who submitted the form:
SELECT id, email, first_name, last_name, form_submitted, updated_at 
FROM public.profiles 
WHERE form_submitted = 'yes';
