-- ========================================
-- CREATE TEST USERS - PURE SQL APPROACH
-- ========================================
-- This creates users directly in auth.users
-- Password for all users: "password123"
-- ========================================

-- First, create the auth users (this bypasses the normal signup flow)
-- The handle_new_user trigger will automatically create profile entries

DO $$
DECLARE
  admin_id uuid := gen_random_uuid();
  secretary_id uuid := gen_random_uuid();
  citizen_id uuid := gen_random_uuid();
BEGIN
  -- Create admin user in auth.users
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    aud,
    role,
    created_at,
    updated_at
  ) VALUES (
    admin_id,
    '00000000-0000-0000-0000-000000000000',
    'admin@test.com',
    '$2a$10$X0JQCiJ6xQ/JgQIRzWzXQeGPMz0a0OgvLyPXYdvHTfiFLrqFPqTje', -- bcrypt("password123")
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"first_name":"Admin","last_name":"User"}',
    'authenticated',
    'authenticated',
    now(),
    now()
  ) ON CONFLICT (email) DO NOTHING;

  -- Create secretary user in auth.users
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    aud,
    role,
    created_at,
    updated_at
  ) VALUES (
    secretary_id,
    '00000000-0000-0000-0000-000000000000',
    'secretary@test.com',
    '$2a$10$X0JQCiJ6xQ/JgQIRzWzXQeGPMz0a0OgvLyPXYdvHTfiFLrqFPqTje', -- bcrypt("password123")
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"first_name":"Maria","last_name":"Secretary"}',
    'authenticated',
    'authenticated',
    now(),
    now()
  ) ON CONFLICT (email) DO NOTHING;

  -- Create citizen user in auth.users
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    aud,
    role,
    created_at,
    updated_at
  ) VALUES (
    citizen_id,
    '00000000-0000-0000-0000-000000000000',
    'citizen@test.com',
    '$2a$10$X0JQCiJ6xQ/JgQIRzWzXQeGPMz0a0OgvLyPXYdvHTfiFLrqFPqTje', -- bcrypt("password123")
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"first_name":"John","last_name":"Donor"}',
    'authenticated',
    'authenticated',
    now(),
    now()
  ) ON CONFLICT (email) DO NOTHING;

  -- Also create identities for each user
  INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES
    (admin_id, admin_id, json_build_object('sub', admin_id::text, 'email', 'admin@test.com'), 'email', now(), now(), now()),
    (secretary_id, secretary_id, json_build_object('sub', secretary_id::text, 'email', 'secretary@test.com'), 'email', now(), now(), now()),
    (citizen_id, citizen_id, json_build_object('sub', citizen_id::text, 'email', 'citizen@test.com'), 'email', now(), now(), now())
  ON CONFLICT (provider, id) DO NOTHING;

  -- Manually create profiles (in case trigger doesn't run)
  INSERT INTO public.profiles (id, email, first_name, last_name, role, created_at)
  VALUES
    (admin_id, 'admin@test.com', 'Admin', 'User', 'citizen', now()),
    (secretary_id, 'secretary@test.com', 'Maria', 'Secretary', 'citizen', now()),
    (citizen_id, 'citizen@test.com', 'John', 'Donor', 'citizen', now())
  ON CONFLICT (id) DO NOTHING;

END $$;

-- Now update the profiles with correct roles and data
UPDATE public.profiles
SET
  role = 'admin',
  first_name = 'Admin',
  last_name = 'User',
  phone_number = '+30 6900000001',
  area = 'Athens, Greece',
  age = 35
WHERE email = 'admin@test.com';

UPDATE public.profiles
SET
  role = 'secretary',
  first_name = 'Maria',
  last_name = 'Secretary',
  phone_number = '+30 6900000002',
  area = 'Athens, Greece',
  age = 30
WHERE email = 'secretary@test.com';

UPDATE public.profiles
SET
  role = 'citizen',
  first_name = 'John',
  last_name = 'Donor',
  phone_number = '+30 6900000003',
  area = 'Thessaloniki, Greece',
  blood_type = 'A+',
  age = 28
WHERE email = 'citizen@test.com';

-- Show results
SELECT 'Test users created successfully!' as message;
SELECT
  p.email,
  p.role,
  p.first_name,
  p.last_name,
  p.blood_type,
  p.age
FROM public.profiles p
WHERE p.email IN ('admin@test.com', 'secretary@test.com', 'citizen@test.com')
ORDER BY
  CASE p.role
    WHEN 'admin' THEN 1
    WHEN 'secretary' THEN 2
    WHEN 'citizen' THEN 3
  END;
