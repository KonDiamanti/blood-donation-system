export type UserRole = 'citizen' | 'secretary' | 'admin'

export type ApplicationStatus = 'pending' | 'approved' | 'rejected'

export type AppointmentStatus = 'scheduled' | 'completed' | 'cancelled' | 'no-show'

export interface Profile {
  id: string
  email: string
  first_name: string
  last_name: string
  phone_number: string | null
  area: string | null
  blood_type: string | null
  age: number | null
  role: UserRole
  created_at: string
}

export interface DonationApplication {
  id: string
  citizen_id: string
  status: ApplicationStatus
  is_free_of_infections: boolean
  has_tattoos_or_piercings: boolean
  has_recent_procedures: boolean
  has_travel_to_risk_areas: boolean
  has_risk_behavior: boolean
  is_recently_pregnant: boolean
  is_breastfeeding: boolean
  has_drug_use: boolean
  has_aids: boolean
  rejection_reason: string | null
  reviewed_by: string | null
  created_at: string
  reviewed_at: string | null
  // Joined fields
  citizen?: Profile
  reviewer?: Profile
}

export interface Clinic {
  id: string
  name: string
  address: string
  area: string
  phone: string
  email: string | null
  opening_hours: {
    monday?: string[]
    tuesday?: string[]
    wednesday?: string[]
    thursday?: string[]
    friday?: string[]
    saturday?: string[]
    sunday?: string[]
  }
  created_at: string
}

export interface Appointment {
  id: string
  application_id: string
  citizen_id: string
  clinic_id: string
  appointment_date: string
  appointment_time: string
  status: AppointmentStatus
  notes: string | null
  created_at: string
  updated_at: string
  // Joined fields
  clinic?: Clinic
  citizen?: Profile
  application?: DonationApplication
}
