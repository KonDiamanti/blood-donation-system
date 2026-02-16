-- ========================================
-- APPOINTMENTS & CLINICS SCHEMA
-- ========================================
-- Run this after the main schema.sql

-- Clinics/Hospitals table
CREATE TABLE IF NOT EXISTS public.clinics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  address text NOT NULL,
  area text NOT NULL,
  phone text NOT NULL,
  email text,
  opening_hours jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

-- Appointments table
CREATE TABLE IF NOT EXISTS public.appointments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id uuid NOT NULL REFERENCES public.donation_applications(id) ON DELETE CASCADE,
  citizen_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  clinic_id uuid NOT NULL REFERENCES public.clinics(id) ON DELETE RESTRICT,
  appointment_date date NOT NULL,
  appointment_time time NOT NULL,
  status text NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled', 'no-show')),
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(clinic_id, appointment_date, appointment_time)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_appointments_citizen ON public.appointments(citizen_id);
CREATE INDEX IF NOT EXISTS idx_appointments_clinic ON public.appointments(clinic_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON public.appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_application ON public.appointments(application_id);

-- RLS Policies for clinics (public read)
ALTER TABLE public.clinics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view clinics"
  ON public.clinics
  FOR SELECT
  TO authenticated
  USING (true);

-- RLS Policies for appointments
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;

-- Citizens can view their own appointments
CREATE POLICY "Citizens can view own appointments"
  ON public.appointments
  FOR SELECT
  TO authenticated
  USING (citizen_id = auth.uid());

-- Citizens can create appointments for their approved applications
CREATE POLICY "Citizens can create appointments"
  ON public.appointments
  FOR INSERT
  TO authenticated
  WITH CHECK (
    citizen_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM public.donation_applications
      WHERE id = application_id
        AND citizen_id = auth.uid()
        AND status = 'approved'
    )
  );

-- Citizens can update/cancel their own future appointments
CREATE POLICY "Citizens can update own appointments"
  ON public.appointments
  FOR UPDATE
  TO authenticated
  USING (citizen_id = auth.uid() AND appointment_date >= CURRENT_DATE);

-- Secretaries and admins can view all appointments
CREATE POLICY "Secretaries can view all appointments"
  ON public.appointments
  FOR SELECT
  TO authenticated
  USING (get_my_role() IN ('secretary', 'admin'));

-- Secretaries and admins can update appointments
CREATE POLICY "Secretaries can update appointments"
  ON public.appointments
  FOR UPDATE
  TO authenticated
  USING (get_my_role() IN ('secretary', 'admin'));

-- Insert Athens hospitals/clinics
INSERT INTO public.clinics (name, address, area, phone, email, opening_hours) VALUES
  (
    'Evangelismos General Hospital',
    '45-47 Ipsilantou Street, 10676',
    'Kolonaki, Athens',
    '+30 213 204 1000',
    'bloodbank@evangelismos.gr',
    '{
      "monday": ["08:00-14:00", "15:00-20:00"],
      "tuesday": ["08:00-14:00", "15:00-20:00"],
      "wednesday": ["08:00-14:00", "15:00-20:00"],
      "thursday": ["08:00-14:00", "15:00-20:00"],
      "friday": ["08:00-14:00", "15:00-20:00"],
      "saturday": ["09:00-13:00"],
      "sunday": []
    }'
  ),
  (
    'Attikon University Hospital',
    '1 Rimini Street, 12462',
    'Haidari, Athens',
    '+30 210 583 2000',
    'donations@attikon.gr',
    '{
      "monday": ["07:30-14:30"],
      "tuesday": ["07:30-14:30"],
      "wednesday": ["07:30-14:30"],
      "thursday": ["07:30-14:30"],
      "friday": ["07:30-14:30"],
      "saturday": [],
      "sunday": []
    }'
  ),
  (
    'Laiko General Hospital',
    '17 Agiou Thoma Street, 11527',
    'Goudi, Athens',
    '+30 213 206 3000',
    'aimodosía@laiko.gr',
    '{
      "monday": ["08:00-15:00"],
      "tuesday": ["08:00-15:00"],
      "wednesday": ["08:00-15:00"],
      "thursday": ["08:00-15:00"],
      "friday": ["08:00-15:00"],
      "saturday": ["08:00-13:00"],
      "sunday": []
    }'
  ),
  (
    'Hippokrateion General Hospital',
    '114 Vasilissis Sofias Avenue, 11527',
    'Goudi, Athens',
    '+30 213 208 8000',
    'blood@hippocratio.gr',
    '{
      "monday": ["08:00-14:00", "16:00-20:00"],
      "tuesday": ["08:00-14:00", "16:00-20:00"],
      "wednesday": ["08:00-14:00", "16:00-20:00"],
      "thursday": ["08:00-14:00", "16:00-20:00"],
      "friday": ["08:00-14:00"],
      "saturday": [],
      "sunday": []
    }'
  ),
  (
    'Aretaieion University Hospital',
    '76 Vasilissis Sofias Avenue, 11528',
    'Central Athens',
    '+30 210 729 9111',
    'donations@aretaieio.gr',
    '{
      "monday": ["08:30-14:00"],
      "tuesday": ["08:30-14:00"],
      "wednesday": ["08:30-14:00"],
      "thursday": ["08:30-14:00"],
      "friday": ["08:30-14:00"],
      "saturday": [],
      "sunday": []
    }'
  ),
  (
    'KAT General Hospital',
    '2 Nikis Street, 14561',
    'Kifisia, Athens',
    '+30 213 208 6000',
    'blood.donation@kat-hosp.gr',
    '{
      "monday": ["08:00-13:00"],
      "tuesday": ["08:00-13:00"],
      "wednesday": ["08:00-13:00"],
      "thursday": ["08:00-13:00"],
      "friday": ["08:00-13:00"],
      "saturday": [],
      "sunday": []
    }'
  ),
  (
    'Sotiria General Hospital',
    '152 Mesogion Avenue, 11527',
    'Ambelokipi, Athens',
    '+30 210 778 4911',
    'bloodcenter@sotiria.gr',
    '{
      "monday": ["08:00-14:00", "15:00-19:00"],
      "tuesday": ["08:00-14:00", "15:00-19:00"],
      "wednesday": ["08:00-14:00", "15:00-19:00"],
      "thursday": ["08:00-14:00", "15:00-19:00"],
      "friday": ["08:00-14:00"],
      "saturday": ["09:00-12:00"],
      "sunday": []
    }'
  )
ON CONFLICT DO NOTHING;

-- Show inserted clinics
SELECT name, area, phone FROM public.clinics ORDER BY name;
