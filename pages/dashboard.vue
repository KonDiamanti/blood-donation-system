<script setup lang="ts">
definePageMeta({
  middleware: 'auth',
})

const client = useSupabaseClient()

const profile = ref<{ role: string; first_name: string; last_name: string } | null>(null)
const applications = ref<any[]>([])
const loading = ref(true)
const errorMsg = ref('')

async function loadProfile() {
  loading.value = true
  errorMsg.value = ''

  const { data: { user } } = await client.auth.getUser()

  if (!user?.id) {
    errorMsg.value = 'Not logged in'
    loading.value = false
    return
  }

  const { data, error } = await client
    .from('profiles')
    .select('role, first_name, last_name')
    .eq('id', user.id)
    .single()

  if (error) {
    console.error('Profile fetch error:', error)
    errorMsg.value = `Could not load profile: ${error.message}`
    loading.value = false
    return
  }

  if (!data) {
    await client.auth.signOut()
    return navigateTo('/login')
  }

  profile.value = data

  if (data.role === 'secretary') {
    return navigateTo('/secretary/applications')
  }
  if (data.role === 'admin') {
    return navigateTo('/admin/users')
  }

  const { data: apps } = await client
    .from('donation_applications')
    .select(`
      id,
      status,
      created_at,
      rejection_reason,
      appointments (
        id,
        clinic_id,
        appointment_date,
        appointment_time,
        status,
        clinics (
          name
        )
      )
    `)
    .eq('citizen_id', user.id)
    .order('created_at', { ascending: false })
    .limit(5)

  applications.value = apps || []
  loading.value = false
}

onMounted(loadProfile)

const statusColor = (status: string) => {
  switch (status) {
    case 'approved': return 'bg-green-100 text-green-800'
    case 'rejected': return 'bg-red-100 text-red-800'
    default: return 'bg-warning-100 text-warning-800'
  }
}
</script>

<template>
  <div class="max-w-5xl mx-auto px-4 py-6">
    <div v-if="loading" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600"></div>
    </div>

    <div v-else-if="errorMsg" class="bg-red-50 border border-red-200 rounded-lg p-5 text-center">
      <p class="text-sm text-red-700 mb-3">{{ errorMsg }}</p>
      <button
        @click="loadProfile"
        class="bg-gray-900 text-white px-5 py-2 rounded-md font-semibold text-sm hover:bg-black transition mr-2"
      >
        Retry
      </button>
      <NuxtLink
        to="/login"
        class="bg-white border-2 border-gray-900 text-gray-900 px-5 py-2 rounded-md font-semibold text-sm hover:bg-gray-50 transition"
      >
        Back to Login
      </NuxtLink>
    </div>

    <template v-else-if="profile">
      <h1 class="text-2xl font-bold text-gray-900 mb-1">
        Hello, {{ profile.first_name }}
      </h1>
      <p class="text-sm text-gray-500 mb-6">Welcome to your donor dashboard</p>

      <div class="grid md:grid-cols-2 gap-4 mb-6">
        <NuxtLink
          to="/apply"
          class="bg-gray-900 text-white rounded-lg p-4 hover:bg-black transition group"
        >
          <h3 class="text-base font-semibold mb-0.5">New Application</h3>
          <p class="text-gray-300 text-xs">Submit a new blood donation application</p>
        </NuxtLink>

        <NuxtLink
          to="/my-applications"
          class="bg-white border border-gray-200 rounded-lg p-4 hover:border-gray-300 transition"
        >
          <h3 class="text-base font-semibold text-gray-900 mb-0.5">My Applications</h3>
          <p class="text-gray-500 text-xs">View all your submitted applications</p>
        </NuxtLink>
      </div>

      <div v-if="applications.length > 0">
        <h2 class="text-lg font-bold text-gray-900 mb-3">Recent Applications</h2>
        <div class="space-y-3">
          <div
            v-for="app in applications"
            :key="app.id"
            class="bg-white border border-gray-200 rounded-lg p-4"
          >
            <div class="flex items-start justify-between mb-3">
              <div>
                <p class="text-xs text-gray-500">Submitted {{ new Date(app.created_at).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' }) }}</p>
              </div>
              <span
                :class="statusColor(app.status)"
                class="text-[10px] font-semibold px-2 py-1 rounded-full capitalize"
              >
                {{ app.status }}
              </span>
            </div>


            <div v-if="app.status === 'rejected' && app.rejection_reason" class="mb-3 bg-red-50 border border-red-200 rounded p-2.5">
              <p class="text-[10px] font-semibold text-red-900 mb-1">Rejection Reason:</p>
              <p class="text-xs text-red-800">{{ app.rejection_reason }}</p>
            </div>


            <div v-if="app.appointments && app.appointments.length > 0" class="mt-3 bg-primary-50 border border-primary-200 rounded p-2.5">
              <div class="flex items-center gap-1.5 mb-1.5">
                <svg class="w-3.5 h-3.5 text-primary-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                <span class="text-[10px] font-semibold text-primary-900">Appointment Scheduled</span>
              </div>
              <div class="grid grid-cols-1 gap-1">
                <div class="flex items-start gap-1.5">
                  <svg class="w-3 h-3 text-primary-600 flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  <span class="text-[10px] text-primary-800 font-medium">{{ app.appointments[0].clinics?.name }}</span>
                </div>
                <div class="flex items-center gap-1.5">
                  <svg class="w-3 h-3 text-primary-600 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                  </svg>
                  <span class="text-[10px] text-primary-700">{{ new Date(app.appointments[0].appointment_date).toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric' }) }} • {{ app.appointments[0].appointment_time }}</span>
                </div>
              </div>
            </div>


            <div v-else-if="app.status === 'approved'" class="mt-3">
              <NuxtLink
                :to="`/book-appointment?application=${app.id}`"
                class="inline-flex items-center gap-1.5 bg-gray-900 text-white px-4 py-2 rounded-md text-sm font-semibold hover:bg-black transition"
              >
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                Book Appointment
              </NuxtLink>
            </div>
          </div>
        </div>
      </div>

      <div v-else class="bg-white border border-gray-200 rounded-lg p-6 text-center">
        <p class="text-sm text-gray-500 mb-3">You haven't submitted any applications yet.</p>
        <NuxtLink
          to="/apply"
          class="inline-block bg-gray-900 text-white px-5 py-2 rounded-md text-sm font-semibold hover:bg-black transition"
        >
          Apply Now
        </NuxtLink>
      </div>
    </template>
  </div>
</template>
