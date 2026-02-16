-- ============================================
-- Blood Donation System - Database Schema
-- Run this in Supabase SQL Editor (supabase.com → SQL Editor → New Query)
-- ============================================

-- 1. PROFILES TABLE (extends Supabase auth.users)
-- Replaces: User + Citizen + Secretary + Role entities from Spring Boot
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  first_name text not null,
  last_name text not null,
  phone_number text,
  area text,
  blood_type text check (blood_type in ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
  age integer check (age >= 18 and age <= 100),
  role text not null default 'citizen' check (role in ('citizen', 'secretary', 'admin')),
  created_at timestamptz default now()
);

-- 2. DONATION APPLICATIONS TABLE
-- Replaces: DonationApplication entity from Spring Boot
create table public.donation_applications (
  id uuid default gen_random_uuid() primary key,
  citizen_id uuid references public.profiles(id) on delete cascade not null,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),

  -- Health questionnaire (9 boolean fields from original)
  is_free_of_infections boolean not null,
  has_tattoos_or_piercings boolean not null,
  has_recent_procedures boolean not null,
  has_travel_to_risk_areas boolean not null,
  has_risk_behavior boolean not null,
  is_recently_pregnant boolean not null,
  is_breastfeeding boolean not null,
  has_drug_use boolean not null,
  has_aids boolean not null,

  rejection_reason text,
  reviewed_by uuid references public.profiles(id),
  created_at timestamptz default now(),
  reviewed_at timestamptz
);

-- 3. INDEXES
create index idx_applications_citizen on public.donation_applications(citizen_id);
create index idx_applications_status on public.donation_applications(status);
create index idx_applications_reviewed_by on public.donation_applications(reviewed_by);

-- ============================================
-- ROW LEVEL SECURITY (replaces Spring Security)
-- ============================================

alter table public.profiles enable row level security;
alter table public.donation_applications enable row level security;

-- PROFILES POLICIES

-- Everyone can read their own profile
create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

-- Secretaries can view citizen profiles (to review applications)
create policy "Secretaries can view all profiles"
  on public.profiles for select
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('secretary', 'admin')
    )
  );

-- Users can update their own profile
create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Admins can do everything with profiles
create policy "Admins full access to profiles"
  on public.profiles for all
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- Allow insert during registration (the trigger handles this)
create policy "Allow profile creation on signup"
  on public.profiles for insert
  with check (auth.uid() = id);

-- DONATION APPLICATIONS POLICIES

-- Citizens can view their own applications
create policy "Citizens can view own applications"
  on public.donation_applications for select
  using (auth.uid() = citizen_id);

-- Citizens can create applications
create policy "Citizens can create applications"
  on public.donation_applications for insert
  with check (auth.uid() = citizen_id);

-- Secretaries can view all applications
create policy "Secretaries can view all applications"
  on public.donation_applications for select
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('secretary', 'admin')
    )
  );

-- Secretaries can update application status
create policy "Secretaries can update applications"
  on public.donation_applications for update
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('secretary', 'admin')
    )
  );

-- Admins full access to applications
create policy "Admins full access to applications"
  on public.donation_applications for all
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- ============================================
-- AUTO-CREATE PROFILE ON SIGNUP (trigger)
-- This replaces the Spring Boot signup logic that
-- created both a User and a Citizen entity
-- ============================================

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, first_name, last_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'first_name', ''),
    coalesce(new.raw_user_meta_data->>'last_name', ''),
    coalesce(new.raw_user_meta_data->>'role', 'citizen')
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================
-- SEED DATA: Create an admin user role
-- After running this, sign up with any email, then
-- run the update below to make that user an admin
-- ============================================

-- To promote a user to admin (run after they sign up):
-- update public.profiles set role = 'admin' where email = 'your-admin@email.com';

-- To promote a user to secretary:
-- update public.profiles set role = 'secretary' where email = 'your-secretary@email.com';
