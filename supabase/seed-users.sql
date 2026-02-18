-- ========================================
-- SEED TEST USERS
-- ========================================
--
-- IMPORTANT: You cannot create Supabase Auth users via SQL alone.
-- You must first create these users via the Supabase Dashboard:
--
-- Steps:
-- 1. Go to: Authentication → Users → Add User
-- 2. Create these 3 users (use password: password123 for all):
--    - admin@test.com
--    - secretary@test.com
--    - citizen@test.com
-- 3. Enable "Auto Confirm" so they don't need email verification
-- 4. Then run THIS SQL to set their roles and data:
--
-- ========================================

-- Update admin user
UPDATE profiles
SET
  role = 'admin',
  first_name = 'Admin',
  last_name = 'User',
  phone_number = '+30 6900000001',
  area = 'Athens, Greece',
  age = 35
WHERE email = 'admin@test.com';

-- Update secretary user
UPDATE profiles
SET
  role = 'secretary',
  first_name = 'Maria',
  last_name = 'Secretary',
  phone_number = '+30 6900000002',
  area = 'Athens, Greece',
  age = 30
WHERE email = 'secretary@test.com';

-- Update citizen user with sample data
UPDATE profiles
SET
  role = 'citizen',
  first_name = 'John',
  last_name = 'Donor',
  phone_number = '+30 6900000003',
  area = 'Thessaloniki, Greece',
  blood_type = 'A+',
  age = 28
WHERE email = 'citizen@test.com';

-- Verify the updates
SELECT
  email,
  role,
  first_name,
  last_name,
  blood_type,
  age
FROM profiles
WHERE email IN ('admin@test.com', 'secretary@test.com', 'citizen@test.com')
ORDER BY
  CASE role
    WHEN 'admin' THEN 1
    WHEN 'secretary' THEN 2
    WHEN 'citizen' THEN 3
  END;
