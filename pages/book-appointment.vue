<script setup lang="ts">
import type { Clinic, DonationApplication } from '~/types'

definePageMeta({
  middleware: 'auth',
})

const client = useSupabaseClient()
const route = useRoute()

const applicationId = route.query.application as string

const application = ref<DonationApplication | null>(null)
const clinics = ref<Clinic[]>([])
const selectedClinic = ref<Clinic | null>(null)
const currentUser = ref<{ email: string; first_name: string } | null>(null)
const selectedDate = ref('')
const tempSelectedDate = ref('')
const loading = ref(true)
const saving = ref(false)
const error = ref('')
const success = ref(false)
const showConfirmation = ref(false)

const currentMonth = ref(new Date())
const today = new Date()
today.setHours(0, 0, 0, 0)

const dateStepRef = ref<HTMLElement | null>(null)

onMounted(async () => {
  const { data: { user } } = await client.auth.getUser()
  if (!user) return

  const { data: profile } = await client
    .from('profiles')
    .select('email, first_name')
    .eq('id', user.id)
    .single()

  if (profile) currentUser.value = profile

  const { data: app } = await (client as any)
    .from('donation_applications')
    .select('*')
    .eq('id', applicationId)
    .eq('citizen_id', user.id)
    .single()

  if (!app || app.status !== 'approved') {
    error.value = 'Application not found or not approved'
    loading.value = false
    return
  }

  application.value = app

  const { data: clinicData } = await client
    .from('clinics')
    .select('*')
    .order('name')

  clinics.value = clinicData || []
  loading.value = false

  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  currentMonth.value = new Date(tomorrow.getFullYear(), tomorrow.getMonth(), 1)
})

watch(selectedClinic, async (newClinic) => {
  selectedDate.value = ''
  tempSelectedDate.value = ''

  if (newClinic) {
    await nextTick()
    setTimeout(() => {
      dateStepRef.value?.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }, 300)
  }
})

const minDate = computed((): string => {
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  return tomorrow.toISOString().split('T')[0]!
})

const maxDate = computed((): string => {
  const threeMonths = new Date()
  threeMonths.setMonth(threeMonths.getMonth() + 3)
  return threeMonths.toISOString().split('T')[0]!
})

const currentMonthDisplay = computed(() => {
  return currentMonth.value.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })
})

const isCurrentMonth = computed(() => {
  const minDateObj = new Date(minDate.value)
  return currentMonth.value.getMonth() === minDateObj.getMonth() &&
         currentMonth.value.getFullYear() === minDateObj.getFullYear()
})

const isLastMonth = computed(() => {
  const maxDateObj = new Date(maxDate.value)
  return currentMonth.value.getMonth() === maxDateObj.getMonth() &&
         currentMonth.value.getFullYear() === maxDateObj.getFullYear()
})

const calendarDays = computed(() => {
  const year = currentMonth.value.getFullYear()
  const month = currentMonth.value.getMonth()

  const firstDay = new Date(year, month, 1)
  const lastDay = new Date(year, month + 1, 0)
  const startingDayOfWeek = firstDay.getDay()
  const totalDays = lastDay.getDate()

  const days = []
  const minDateObj = new Date(minDate.value)
  const maxDateObj = new Date(maxDate.value)

  const prevMonthLastDay = new Date(year, month, 0).getDate()
  for (let i = startingDayOfWeek - 1; i >= 0; i--) {
    const day = prevMonthLastDay - i
    const date = new Date(year, month - 1, day)
    days.push({
      day,
      date: date.toISOString().split('T')[0]!,
      isCurrentMonth: false,
      isSelectable: false,
      isSelected: false,
      isToday: false
    })
  }

  for (let day = 1; day <= totalDays; day++) {
    const date = new Date(year, month, day)
    const dateStr = date.toISOString().split('T')[0]!
    const isSelectable = date >= minDateObj && date <= maxDateObj
    const isToday = date.getTime() === today.getTime()

    days.push({
      day,
      date: dateStr,
      isCurrentMonth: true,
      isSelectable,
      isSelected: tempSelectedDate.value === dateStr,
      isToday
    })
  }

  const remainingDays = 42 - days.length
  for (let day = 1; day <= remainingDays; day++) {
    const date = new Date(year, month + 1, day)
    days.push({
      day,
      date: date.toISOString().split('T')[0]!,
      isCurrentMonth: false,
      isSelectable: false,
      isSelected: false,
      isToday: false
    })
  }

  return days
})

function previousMonth() {
  currentMonth.value = new Date(currentMonth.value.getFullYear(), currentMonth.value.getMonth() - 1, 1)
}

function nextMonth() {
  currentMonth.value = new Date(currentMonth.value.getFullYear(), currentMonth.value.getMonth() + 1, 1)
}

function selectDateFromCalendar(date: string) {
  tempSelectedDate.value = date
}

function confirmDateSelection() {
  if (!tempSelectedDate.value) return
  selectedDate.value = tempSelectedDate.value
  showConfirmation.value = true
}

function formatDisplayDate(dateStr: string) {
  const date = new Date(dateStr)
  return date.toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

function cancelBooking() {
  showConfirmation.value = false
}

async function confirmBooking() {
  error.value = ''
  saving.value = true

  const { data: { user } } = await client.auth.getUser()
  if (!user) {
    error.value = 'Not logged in'
    saving.value = false
    return
  }

  const { error: insertError } = await (client as any)
    .from('appointments')
    .insert({
      application_id: applicationId,
      citizen_id: user.id,
      clinic_id: selectedClinic.value!.id,
      appointment_date: selectedDate.value,
      appointment_time: '09:00', // Default time
      notes: 'Walk-in appointment - visit during clinic operating hours',
    })

  if (insertError) {
    error.value = insertError.message
    saving.value = false
    showConfirmation.value = false
    return
  }

  if (currentUser.value) {
    await $fetch('/api/email/send-appointment-confirmation', {
      method: 'POST',
      body: {
        email: currentUser.value.email,
        firstName: currentUser.value.first_name,
        clinicName: selectedClinic.value!.name,
        clinicAddress: `${selectedClinic.value!.address}, ${selectedClinic.value!.area}`,
        appointmentDate: selectedDate.value,
      },
    }).catch(() => {})
  }

  success.value = true
  saving.value = false
  showConfirmation.value = false
}
</script>

<template>
  <div class="max-w-4xl mx-auto px-4 py-5">
    <h1 class="text-xl font-bold text-gray-900 mb-1">Book Your Donation Appointment</h1>
    <p class="text-xs text-gray-600 mb-3">Select a clinic and schedule your blood donation</p>

    <div class="bg-warning-50 border border-warning-200 rounded p-2.5 mb-3">
      <div class="flex gap-1.5">
        <svg class="w-4 h-4 text-warning-600 flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <div>
          <p class="text-[10px] font-semibold text-warning-900 mb-0.5">Walk-in Appointment</p>
          <p class="text-[10px] text-warning-700">This appointment reserves your slot at the clinic. You may visit during the clinic's operating hours on your selected date.</p>
        </div>
      </div>
    </div>

    <div v-if="loading" class="flex justify-center py-8">
      <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600"></div>
    </div>

    <div v-else-if="error && !application" class="bg-red-50 border border-red-200 rounded p-4 text-center">
      <p class="text-xs text-red-700">{{ error }}</p>
      <NuxtLink to="/dashboard" class="mt-2 inline-block text-xs text-primary-600 hover:text-primary-700">
        Return to Dashboard
      </NuxtLink>
    </div>

    <div v-else-if="success" class="bg-green-50 border border-green-200 rounded p-5 text-center">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-success-500 mx-auto mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <h2 class="text-lg font-bold text-green-800 mb-1">Appointment Booked!</h2>
      <p class="text-xs text-green-700 mb-0.5">Your donation appointment has been scheduled</p>
      <p class="text-xs text-green-700 mb-3">
        <strong>{{ selectedClinic?.name }}</strong><br>
        {{ formatDisplayDate(selectedDate) }}
      </p>
      <div class="flex gap-2 justify-center">
        <NuxtLink to="/my-applications" class="bg-gray-900 text-white px-4 py-1.5 rounded text-xs font-semibold hover:bg-black transition">
          View Applications
        </NuxtLink>
        <NuxtLink to="/dashboard" class="bg-white border-2 border-gray-900 text-gray-900 px-4 py-1.5 rounded text-xs font-semibold hover:bg-gray-50 transition">
          Dashboard
        </NuxtLink>
      </div>
    </div>

    <form v-else @submit.prevent class="space-y-3">
      <div v-if="error" class="bg-red-50 text-red-700 rounded p-2.5 text-xs">
        {{ error }}
      </div>

      <div class="bg-white rounded shadow-sm border border-gray-200 p-3">
        <h2 class="text-sm font-bold text-gray-900 mb-2">1. Select a Clinic</h2>
        <div class="grid gap-1.5">
          <div
            v-for="clinic in clinics"
            :key="clinic.id"
            @click="selectedClinic = clinic; selectedDate = ''"
            class="border rounded p-2.5 cursor-pointer transition"
            :class="selectedClinic?.id === clinic.id ? 'border-primary-600 bg-primary-50' : 'border-gray-200 hover:border-gray-300'"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <h3 class="font-semibold text-xs text-gray-900">{{ clinic.name }}</h3>
                <p class="text-[10px] text-gray-600 mt-0.5">📍 {{ clinic.address }}, {{ clinic.area }}</p>
                <p class="text-[10px] text-gray-600">📞 {{ clinic.phone }}</p>
              </div>
              <div
                v-if="selectedClinic?.id === clinic.id"
                class="flex-shrink-0 w-4 h-4 bg-primary-600 rounded-full flex items-center justify-center"
              >
                <svg class="w-2.5 h-2.5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                </svg>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div ref="dateStepRef" v-if="selectedClinic" class="bg-white rounded shadow-sm border border-gray-200 p-3 scroll-mt-16">
        <h2 class="text-sm font-bold text-gray-900 mb-2">2. Select Date</h2>

        <div class="max-w-xs mx-auto mb-2">
          <div class="flex items-center justify-between mb-1.5">
            <button
              type="button"
              @click="previousMonth"
              :disabled="isCurrentMonth"
              class="p-0.5 rounded hover:bg-gray-100 disabled:opacity-30 disabled:cursor-not-allowed transition"
            >
              <svg class="w-3.5 h-3.5 text-gray-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h3 class="text-xs font-semibold text-gray-900">
              {{ currentMonthDisplay }}
            </h3>
            <button
              type="button"
              @click="nextMonth"
              :disabled="isLastMonth"
              class="p-0.5 rounded hover:bg-gray-100 disabled:opacity-30 disabled:cursor-not-allowed transition"
            >
              <svg class="w-3.5 h-3.5 text-gray-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>

          <div class="grid grid-cols-7 gap-px mb-0.5">
            <div v-for="day in ['S', 'M', 'T', 'W', 'T', 'F', 'S']" :key="day" class="text-center text-[9px] font-medium text-gray-500 py-0.5">
              {{ day }}
            </div>
          </div>

          <div class="grid grid-cols-7 gap-0.5">
            <button
              v-for="day in calendarDays"
              :key="day.date"
              type="button"
              @click="selectDateFromCalendar(day.date)"
              :disabled="!day.isCurrentMonth || !day.isSelectable"
              class="aspect-square flex items-center justify-center rounded text-[10px] font-medium transition min-h-[20px]"
              :class="{
                'text-gray-400 cursor-not-allowed': !day.isCurrentMonth,
                'text-gray-300 cursor-not-allowed': day.isCurrentMonth && !day.isSelectable,
                'text-gray-700 hover:bg-primary-100': day.isCurrentMonth && day.isSelectable && !day.isSelected && !day.isToday,
                'bg-primary-600 text-white font-bold': day.isSelected,
                'border border-primary-600 text-primary-600 font-bold': day.isToday && !day.isSelected,
                'hover:bg-primary-700': day.isSelected
              }"
            >
              {{ day.day }}
            </button>
          </div>
        </div>

        <div v-if="tempSelectedDate" class="bg-gray-50 border border-gray-200 rounded p-1.5 mb-1.5 max-w-xs mx-auto">
          <p class="text-[10px] text-gray-600">Selected: <span class="font-semibold text-gray-900">{{ formatDisplayDate(tempSelectedDate) }}</span></p>
        </div>

        <button
          v-if="tempSelectedDate && tempSelectedDate !== selectedDate"
          type="button"
          @click="confirmDateSelection"
          class="w-full max-w-xs mx-auto block bg-gray-900 text-white py-1.5 rounded text-xs font-semibold hover:bg-black transition"
        >
          Confirm Date
        </button>
      </div>

    </form>

    <div v-if="showConfirmation" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded shadow-xl max-w-sm w-full p-4">
        <h3 class="text-base font-bold text-gray-900 mb-3">Confirm Appointment</h3>

        <div class="mb-4">
          <p class="text-xs text-gray-600 mb-2">Are you sure you want to book an appointment?</p>

          <div class="bg-gray-50 rounded p-2 mb-1.5">
            <p class="text-[10px] text-gray-500 mb-0.5">Clinic</p>
            <p class="font-semibold text-xs text-gray-900">{{ selectedClinic?.name }}</p>
          </div>

          <div class="bg-gray-50 rounded p-2">
            <p class="text-[10px] text-gray-500 mb-0.5">Date</p>
            <p class="font-semibold text-xs text-gray-900">{{ formatDisplayDate(selectedDate) }}</p>
          </div>
        </div>

        <div v-if="error" class="bg-red-50 text-red-700 rounded p-2 text-[10px] mb-3">
          {{ error }}
        </div>

        <div class="flex gap-2">
          <button
            @click="confirmBooking"
            :disabled="saving"
            class="flex-1 bg-gray-900 text-white py-2 rounded text-xs font-semibold hover:bg-black transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ saving ? 'Booking...' : 'Confirm' }}
          </button>
          <button
            @click="cancelBooking"
            :disabled="saving"
            class="flex-1 bg-white border-2 border-gray-900 text-gray-900 py-2 rounded text-xs font-semibold hover:bg-gray-50 transition disabled:opacity-50"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
