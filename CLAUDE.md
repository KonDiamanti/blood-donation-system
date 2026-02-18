# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Blood Donation Management System built with Nuxt 3, TypeScript, Supabase, and Tailwind CSS. Manages the complete blood donation workflow including citizen applications, secretary review, appointment booking, and admin user management.

## Commands

```bash
# Development
npm run dev              # Start dev server on http://localhost:3000

# Build
npm run build           # Build for production
npm run generate        # Generate static site
npm run preview         # Preview production build
```

## Architecture

### User Roles & Access Flow

Three distinct user roles with different access levels:
- **citizen**: Submit donation applications, book appointments, view own applications
- **secretary**: Review and approve/reject citizen applications
- **admin**: Manage users and system configuration

Role-based access is enforced via:
1. `middleware/auth.ts` - Checks authentication and `requiredRole` from page meta
2. Pages use `definePageMeta({ middleware: 'auth', requiredRole: 'secretary' })`
3. Dashboard auto-redirects users to role-appropriate pages

### Authentication Pattern

**IMPORTANT**: Always use `client.auth.getUser()` directly, NOT `useSupabaseUser()` ref:
```typescript
const { data: { user } } = await client.auth.getUser()
```
This ensures fresh data and avoids sync issues with the reactive ref.

### Database Schema (via Supabase)

Key tables and their relationships:
- **profiles** - User data with role, linked to auth.users
- **donation_applications** - Health questionnaire responses, status (pending/approved/rejected)
  - Has 3-month restriction: citizens can only apply once every 90 days
- **clinics** - Donation centers with location and hours
- **appointments** - Links approved applications to clinics with date/time

### 3-Month Donation Restriction Logic

Critical business rule implemented in `pages/apply.vue`:
```typescript
// Check for applications in last 3 months
const threeMonthsAgo = new Date()
threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3)

const { data: recentApps } = await client
  .from('donation_applications')
  .select('created_at')
  .eq('citizen_id', user.id)
  .gte('created_at', threeMonthsAgo.toISOString())
  .limit(1)
```
Always check this restriction before allowing new applications.

### UI/Styling Conventions

**Color Palette** (defined in `tailwind.config.ts`):
- `primary` - Hermes Blue (#29348D)
- `success` - Vintage Emerald (#1F8343)
- `danger` - Shiny Red (#EE3545)
- `warning` - Apollo Yellow (#F8E645)

**Button Standards** (established for consistency):
- Primary actions: `bg-gray-900 text-white hover:bg-black`
- Secondary actions: `bg-white border-2 border-gray-900 text-gray-900 hover:bg-gray-50`
- Always use `font-semibold` for buttons
- Green (`bg-green-600`) for approve/success actions
- Red (`bg-red-600`) for reject/danger actions

**Design Philosophy**:
- Compact, professional layout (not "childish" or oversized)
- Small text sizes (`text-xs`, `text-sm`) for information density
- Minimal padding and spacing
- Clean, scannable interfaces for secretaries

### Page Structure

**Citizen Flow**:
- `/apply` - Health questionnaire submission (with 3-month check)
- `/dashboard` - View recent applications and quick actions
- `/my-applications` - Full application history
- `/book-appointment` - Calendar-based appointment booking for approved applications
- `/profile` - Update personal information

**Secretary Flow**:
- `/secretary/applications` - Review pending applications with health questionnaire
  - Shows yes/no answers with visual indicators (checkmark/X in green/red)
  - Approve/reject buttons with optional rejection reason

**Admin Flow**:
- `/admin/users` - User management

### Common Patterns

**Modal Pattern** (used in secretary and appointment pages):
```vue
<Teleport to="body">
  <div v-if="showModal" class="fixed inset-0 bg-black/50 ...">
    <!-- Modal content -->
  </div>
</Teleport>
```

**Loading States**:
```vue
<div v-if="loading" class="flex justify-center py-12">
  <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600"></div>
</div>
```

**Date Formatting**:
```typescript
// For display
new Date(dateStr).toLocaleDateString('en-US', {
  year: 'numeric', month: 'short', day: 'numeric'
})

// For database queries (always use ISO strings)
new Date().toISOString()
```

## Key Files

- `tailwind.config.ts` - Custom color palette configuration
- `types/index.ts` - TypeScript interfaces for all database entities
- `middleware/auth.ts` - Authentication and role-based access control
- `nuxt.config.ts` - Supabase module config with `redirect: false`

## Supabase Configuration

The project uses `@nuxtjs/supabase` with:
- Auto-imports: `useSupabaseClient()` available in all components
- `redirect: false` - Custom auth flow instead of automatic redirects
- Direct `client.auth.getUser()` calls for reliable auth state

## Important Notes

- Always validate user roles before showing sensitive data
- Health questionnaire has inverted logic for some questions (e.g., "Free of infections" should be Yes)
- Walk-in appointments mean citizens visit during clinic hours (no specific time slot)
- Secretary view should show yes/no answers aligned in columns with consistent width
