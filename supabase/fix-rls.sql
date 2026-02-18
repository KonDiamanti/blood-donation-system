-- ============================================
-- FIX: Infinite recursion in profiles RLS policies
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. Create a helper function that bypasses RLS to check user role
create or replace function public.get_my_role()
returns text as $$
  select role from public.profiles where id = auth.uid();
$$ language sql security definer stable;

-- 2. Drop ALL existing policies on profiles
drop policy if exists "Users can view own profile" on public.profiles;
drop policy if exists "Secretaries can view all profiles" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
drop policy if exists "Admins full access to profiles" on public.profiles;
drop policy if exists "Allow profile creation on signup" on public.profiles;

-- 3. Recreate policies using the helper function (no recursion)

-- Everyone can read their own profile
create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

-- Secretaries and admins can view all profiles
create policy "Secretaries can view all profiles"
  on public.profiles for select
  using (public.get_my_role() in ('secretary', 'admin'));

-- Users can update their own profile
create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Admins can do everything with profiles
create policy "Admins full access to profiles"
  on public.profiles for all
  using (public.get_my_role() = 'admin');

-- Allow profile creation on signup
create policy "Allow profile creation on signup"
  on public.profiles for insert
  with check (auth.uid() = id);

-- 4. Also fix donation_applications policies that reference profiles
drop policy if exists "Secretaries can view all applications" on public.donation_applications;
drop policy if exists "Secretaries can update applications" on public.donation_applications;
drop policy if exists "Admins full access to applications" on public.donation_applications;

create policy "Secretaries can view all applications"
  on public.donation_applications for select
  using (public.get_my_role() in ('secretary', 'admin'));

create policy "Secretaries can update applications"
  on public.donation_applications for update
  using (public.get_my_role() in ('secretary', 'admin'));

create policy "Admins full access to applications"
  on public.donation_applications for all
  using (public.get_my_role() = 'admin');
