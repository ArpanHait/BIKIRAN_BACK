-- ============================================================================
-- 🚀 Bikiran Career Mitra — Production Schema & RLS Policies
-- Supabase Project: jpjfkmvkqssfdhpyktim
-- ============================================================================

-- 1. Profiles Table (1:1 with Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  gender TEXT CHECK (gender IN ('Male', 'Female', 'Other')),
  whatsapp_number TEXT,
  mobile_number TEXT,
  class_level TEXT,
  stream TEXT,
  school_name TEXT,
  state TEXT,
  subscription_tier TEXT DEFAULT 'basic' CHECK (subscription_tier IN ('basic', 'advance')),
  role TEXT DEFAULT 'general' CHECK (role IN ('general', 'admin')),
  form_submitted TEXT DEFAULT 'no' CHECK (form_submitted IN ('yes', 'no')),
  has_local_avatar BOOLEAN DEFAULT false,
  avatar_url TEXT,
  last_login_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Login History Table (Audit log for compliance and security)
CREATE TABLE IF NOT EXISTS public.login_history (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  login_timestamp TIMESTAMPTZ DEFAULT now(),
  login_method TEXT DEFAULT 'email',
  device_platform TEXT
);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.login_history ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies for Profiles
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- 5. RLS Policies for Login History
DROP POLICY IF EXISTS "Users can view own login history" ON public.login_history;
CREATE POLICY "Users can view own login history"
  ON public.login_history FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own login history" ON public.login_history;
CREATE POLICY "Users can insert own login history"
  ON public.login_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 6. Automatic updated_at Trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_profiles_updated ON public.profiles;
CREATE TRIGGER on_profiles_updated
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- 7. Automatic Profile Creation Trigger on Supabase Auth SignUp
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
