# 🩸 Blood Donation Management System

This is a redesign of a university project. Original repositories: [Frontend](https://github.com/KonDiamanti/DS-Blood-Donation-System-Frontend) | [Backend](https://github.com/AAleksandros/HUA-DIT-Distributed-Systems)

A modern, full-stack blood donation management platform built with Nuxt 3, Vue 3, TypeScript, and Supabase.

A live demo can be found [here](https://blood-donation-system-neon.vercel.app/)

[![Tech Stack](https://img.shields.io/badge/Nuxt-3-00DC82)](https://nuxt.com)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6)](https://www.typescriptlang.org/)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E)](https://supabase.com)

---

## About

A comprehensive blood donation management system that connects donors with medical facilities, streamlining the entire donation process from eligibility screening to appointment scheduling. Built as a **full-stack portfolio project** to demonstrate modern web development practices with Vue 3 ecosystem and Supabase backend.

### Key Features

**For Donors (Citizens):**

- Secure authentication (register, login, password reset)
- Health questionnaire for donation eligibility
- Application status tracking
- View scheduled appointments
- Profile management with blood type tracking
- Password change functionality

**For Secretaries:**

- Review and manage donation applications
- Approve or reject applications with detailed reasons
- Filter applications by status (pending, approved, rejected)
- Edit application decisions
- View donor health information and details

**For Administrators:**

- Assign secretaries or citizens

---

## Tech Stack

**Frontend:**

- **Nuxt 3** - Vue 3 meta-framework with SSR
- **Vue 3** - Progressive JavaScript framework
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first styling

**Backend:**

- **Nuxt Server API Routes** - Backend API endpoints
- **Supabase** - PostgreSQL database + authentication
- **Row-Level Security (RLS)** - Database security policies

**Architecture:**

- **Monorepo** - Single codebase for frontend and backend
- **Full-stack framework** approach for simplified development and deployment

---

## Project Structure

This project uses a monorepo structure with Nuxt 3's full-stack capabilities:

```
blood-donation-system/
├── pages/              # Vue pages (auto-routed)
├── components/         # Reusable Vue components
├── layouts/            # Layout components
├── middleware/         # Route middleware (auth)
├── server/api/         # Backend API endpoints
├── supabase/          # Database migrations & SQL
├── assets/            # CSS & static assets
└── types/             # TypeScript type definitions
```

---

## Database Schema

### Core Tables

- **profiles** - User profiles with blood type and contact info
- **donation_applications** - Donation eligibility applications
- **clinics** - Blood donation centers
- **appointments** - Scheduled donation appointments
- **secretaries** - Secretary assignments for application review
