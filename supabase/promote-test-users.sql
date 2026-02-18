-- ========================================
-- PROMOTE TEST USERS TO DIFFERENT ROLES
-- ========================================
--
-- STEP 1: Create users in Supabase Dashboard first!
-- Go to: Authentication → Users → Add User
-- Create these 3 users with password "password123":
--   - admin@test.com (first: Admin, last: User)
--   - secretary@test.com (first: Maria, last: Secretary)
--   - citizen@test.com (first: John, last: Donor)
-- Make sure to check "Auto Confirm User"
--
-- STEP 2: Run this SQL to set their roles and data
-- ========================================

-- Promote admin@test.com to admin role
UPDATE profiles
SET
  role = 'admin',
  first_name = 'Admin',
  last_name = 'User',
  phone_number = '+30 210 1234567',
  area = 'Athens, Greece',
  age = 35
WHERE email = 'admin@test.com';

-- Promote secretary@test.com to secretary role
UPDATE profiles
SET
  role = 'secretary',
  first_name = 'Maria',
  last_name = 'Secretary',
  phone_number = '+30 210 7654321',
  area = 'Athens, Greece',
  age = 30
WHERE email = 'secretary@test.com';

-- Update citizen@test.com with full profile data
UPDATE profiles
SET
  role = 'citizen',
  first_name = 'John',
  last_name = 'Donor',
  phone_number = '+30 231 0123456',
  area = 'Thessaloniki, Greece',
  blood_type = 'A+',
  age = 28
WHERE email = 'citizen@test.com';

-- Verify the results
SELECT
  email,
  role,
  first_name,
  last_name,
  blood_type,
  age,
  area
FROM profiles
WHERE email IN ('admin@test.com', 'secretary@test.com', 'citizen@test.com')
ORDER BY
  CASE role
    WHEN 'admin' THEN 1
    WHEN 'secretary' THEN 2
    WHEN 'citizen' THEN 3
  END;
