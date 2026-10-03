-- ============================================================================
-- 🛡️ Bikiran Career Mitra — Privilege Escalation Defense Trigger
-- Supabase Project: jpjfkmvkqssfdhpyktim
-- File: backend/src/scripts/protect_privileges.sql
-- ============================================================================
--
-- ℹ️ PURPOSE:
-- Protects public.profiles from client-side privilege escalation.
-- Even if an attacker decompiles the mobile APK and extracts the anon key,
-- this BEFORE UPDATE trigger prevents any non-service-role caller from:
-- 1. Altering their own 'role' (e.g. promoting themselves to 'admin').
-- 2. Altering their own 'subscription_tier' (e.g. self-granting 'advance' tier).
--
-- Only trusted backend services using the SUPABASE_SERVICE_ROLE_KEY or database
-- administrators can modify these sensitive columns.

CREATE OR REPLACE FUNCTION public.protect_profile_privileges()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the operation is performed by a standard authenticated user (not service_role)
  -- In Supabase, current_setting('request.jwt.claims', true) contains the JWT claims.
  -- Service-role calls do not have a user JWT or have role 'service_role'.
  IF coalesce(auth.jwt()->>'role', '') = 'authenticated' OR coalesce(auth.role(), '') = 'anon' THEN
    
    -- 1. Lock 'role' column from client modification
    IF NEW.role IS DISTINCT FROM OLD.role THEN
      RAISE EXCEPTION 'Security Violation: Student role cannot be altered directly from the client.'
        USING ERRCODE = '42501';
    END IF;

    -- 2. Lock 'subscription_tier' column from client modification
    IF NEW.subscription_tier IS DISTINCT FROM OLD.subscription_tier THEN
      RAISE EXCEPTION 'Security Violation: Subscription tier cannot be altered without backend payment verification.'
        USING ERRCODE = '42501';
    END IF;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach the trigger to public.profiles
DROP TRIGGER IF EXISTS trg_protect_profile_privileges ON public.profiles;

CREATE TRIGGER trg_protect_profile_privileges
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.protect_profile_privileges();

COMMENT ON FUNCTION public.protect_profile_privileges IS 
  'Enforces database-level protection preventing students from elevating their role to admin or activating advance subscription tier directly from the mobile app.';
