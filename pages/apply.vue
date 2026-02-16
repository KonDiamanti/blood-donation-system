<script setup lang="ts">
definePageMeta({
  middleware: 'auth',
})

const client = useSupabaseClient()

const loading = ref(true)
const success = ref(false)
const error = ref('')
const canApply = ref(true)
const lastApplicationDate = ref<string | null>(null)
const lastApplicationStatus = ref<string | null>(null)
const lastRejectionReason = ref<string | null>(null)

const questions = [
  { key: 'is_free_of_infections', label: 'Are you currently free of any infections?', invert: false },
  { key: 'has_tattoos_or_piercings', label: 'Have you gotten any tattoos or piercings in the last 6 months?', invert: true },
  { key: 'has_recent_procedures', label: 'Have you had any medical procedures in the last 6 months?', invert: true },
  { key: 'has_travel_to_risk_areas', label: 'Have you traveled to any risk areas recently?', invert: true },
  { key: 'has_risk_behavior', label: 'Have you engaged in any high-risk behavior?', invert: true },
  { key: 'is_recently_pregnant', label: 'Have you been pregnant recently?', invert: true },
  { key: 'is_breastfeeding', label: 'Are you currently breastfeeding?', invert: true },
  { key: 'has_drug_use', label: 'Have you used any intravenous drugs?', invert: true },
  { key: 'has_aids', label: 'Have you been diagnosed with HIV/AIDS?', invert: true },
]

const answers = reactive<Record<string, boolean | null>>(
  Object.fromEntries(questions.map(q => [q.key, null]))
)

onMounted(async () => {
  const { data: { user } } = await client.auth.getUser()
  if (!user) {
    loading.value = false
    return
  }

  const threeMonthsAgo = new Date()
  threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3)

  const { data: recentApps } = await client
    .from('donation_applications')
    .select('created_at, status, rejection_reason')
    .eq('citizen_id', user.id)
    .gte('created_at', threeMonthsAgo.toISOString())
    .order('created_at', { ascending: false })
    .limit(1)

  if (recentApps && recentApps.length > 0) {
    const recentApp = recentApps[0]
    lastApplicationDate.value = recentApp.created_at
    lastApplicationStatus.value = recentApp.status
    lastRejectionReason.value = recentApp.rejection_reason

    if (recentApp.status === 'approved' || recentApp.status === 'pending') {
      canApply.value = false
    }
  }

  loading.value = false
})

async function handleSubmit() {
  const unanswered = questions.filter(q => answers[q.key] === null)
  if (unanswered.length > 0) {
    error.value = 'Please answer all questions before submitting.'
    return
  }

  error.value = ''
  loading.value = true

  const { data: { user } } = await client.auth.getUser()
  if (!user) {
    error.value = 'Not logged in'
    loading.value = false
    return
  }

  const { error: insertError } = await client
    .from('donation_applications')
    .insert({
      citizen_id: user.id,
      is_free_of_infections: answers.is_free_of_infections,
      has_tattoos_or_piercings: answers.has_tattoos_or_piercings,
      has_recent_procedures: answers.has_recent_procedures,
      has_travel_to_risk_areas: answers.has_travel_to_risk_areas,
      has_risk_behavior: answers.has_risk_behavior,
      is_recently_pregnant: answers.is_recently_pregnant,
      is_breastfeeding: answers.is_breastfeeding,
      has_drug_use: answers.has_drug_use,
      has_aids: answers.has_aids,
    })

  if (insertError) {
    error.value = insertError.message
    loading.value = false
    return
  }

  success.value = true
  loading.value = false
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

function getNextEligibleDate(dateStr: string) {
  const date = new Date(dateStr)
  date.setMonth(date.getMonth() + 3)
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}
</script>

<template>
  <div class="max-w-3xl mx-auto px-4 py-6">
    <h1 class="text-xl font-bold text-gray-900 mb-1">Donation Application</h1>
    <p class="text-sm text-gray-500 mb-3">Please answer the following health questionnaire honestly.</p>

    <div v-if="loading" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600"></div>
    </div>

    <div v-else-if="success" class="bg-green-50 border border-green-200 rounded p-5 text-center">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-success-500 mx-auto mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <h2 class="text-lg font-semibold text-green-800 mb-1">Application Submitted</h2>
      <p class="text-xs text-green-700 mb-4">Your application is pending review by a secretary.</p>
      <div class="flex flex-col sm:flex-row gap-2 justify-center items-center">
        <NuxtLink
          to="/my-applications"
          class="w-full sm:w-auto bg-gray-900 text-white px-6 py-2.5 rounded text-sm font-semibold hover:bg-black transition text-center"
        >
          View My Applications
        </NuxtLink>
        <NuxtLink
          to="/dashboard"
          class="w-full sm:w-auto bg-white border-2 border-gray-900 text-gray-900 px-6 py-2.5 rounded text-sm font-semibold hover:bg-gray-50 transition text-center"
        >
          Back to Dashboard
        </NuxtLink>
      </div>
    </div>

    <div v-else-if="!canApply && lastApplicationStatus === 'pending'" class="bg-blue-50 border border-blue-200 rounded-lg p-8 text-center">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 text-blue-500 mx-auto mb-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <h2 class="text-xl font-bold text-gray-900 mb-2">Application Pending Review</h2>
      <p class="text-sm text-gray-700 mb-1">You submitted an application on {{ formatDate(lastApplicationDate!) }}.</p>
      <p class="text-sm text-gray-600 mb-6">Your application is currently under review by our medical staff. Please check your applications page for updates.</p>
      <div class="flex flex-col sm:flex-row gap-2 justify-center">
        <NuxtLink
          to="/my-applications"
          class="bg-gray-900 text-white px-8 py-2.5 rounded-lg text-sm font-semibold hover:bg-black transition"
        >
          View My Applications
        </NuxtLink>
        <NuxtLink
          to="/dashboard"
          class="bg-gray-900 text-white px-8 py-2.5 rounded-lg text-sm font-semibold hover:bg-black transition"
        >
          Back to Dashboard
        </NuxtLink>
      </div>
    </div>

    <div v-else-if="!canApply && lastApplicationStatus === 'approved'" class="bg-white border border-gray-200 rounded-lg p-8 text-center">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 mx-auto mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <h2 class="text-2xl font-bold text-gray-900 mb-3">Application Not Allowed</h2>
      <p class="text-sm text-gray-700 mb-4">You submitted an application on {{ formatDate(lastApplicationDate!) }}.</p>
      <p class="text-base text-gray-800 mb-6">For your health and safety, you must wait 3 months between donation applications. You will be eligible to apply again on <strong>{{ getNextEligibleDate(lastApplicationDate!) }}</strong>.</p>
      <NuxtLink
        to="/dashboard"
        class="inline-block bg-gray-900 text-white px-8 py-3 rounded-lg text-sm font-semibold hover:bg-black transition"
      >
        Back to Dashboard
      </NuxtLink>
    </div>

    <div v-else-if="lastApplicationStatus === 'rejected' && lastApplicationDate" class="bg-orange-50 border border-orange-200 rounded-lg p-4 mb-4">
      <div class="flex gap-2.5">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7 text-orange-500 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
        <div class="flex-1">
          <h2 class="text-base font-semibold text-orange-800 mb-0.5">Previous Application Rejected</h2>
          <p class="text-xs text-orange-700 mb-2.5">Your application from {{ formatDate(lastApplicationDate) }} was not approved.</p>

          <div v-if="lastRejectionReason" class="bg-white rounded p-2 mb-2 border border-orange-200">
            <p class="text-[10px] font-semibold text-orange-900 mb-0.5">Rejection Reason:</p>
            <p class="text-xs text-orange-800">{{ lastRejectionReason }}</p>
          </div>

          <div class="bg-white rounded p-2 mb-2 border border-orange-200">
            <p class="text-[10px] font-semibold text-orange-900 mb-1">What can I do?</p>
            <ul class="text-[10px] text-orange-800 space-y-0.5 list-disc list-inside leading-relaxed">
              <li>If resolved, submit a new application below</li>
              <li>Contact medical staff for questions</li>
              <li>Ensure accurate health responses</li>
            </ul>
          </div>

          <NuxtLink
            to="/dashboard"
            class="block text-center bg-gray-900 text-white px-6 py-2 rounded text-xs font-semibold hover:bg-black transition"
          >
            Back to Dashboard
          </NuxtLink>
        </div>
      </div>
    </div>

    <form v-else @submit.prevent="handleSubmit">
      <div class="bg-warning-50 border border-warning-200 rounded p-2.5 mb-4">
        <div class="flex gap-1.5">
          <svg class="w-4 h-4 text-warning-600 flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <div>
            <p class="text-[10px] font-semibold text-warning-900 mb-0.5">Health Notice</p>
            <p class="text-[10px] text-warning-700">For your safety and health, blood donations are only permitted every 3 months (90 days). This allows your body adequate time to replenish donated blood cells.</p>
          </div>
        </div>
      </div>

      <div v-if="error" class="bg-red-50 text-red-700 text-xs rounded p-2.5 mb-4">
        {{ error }}
      </div>

      <div class="space-y-2">
        <div
          v-for="(question, index) in questions"
          :key="question.key"
          class="bg-white border border-gray-200 rounded p-3"
        >
          <p class="text-gray-900 text-xs font-medium mb-2">
            {{ index + 1 }}. {{ question.label }}
          </p>
          <div class="flex gap-3">
            <label class="flex items-center gap-1.5 cursor-pointer">
              <input
                type="radio"
                :name="question.key"
                :value="true"
                v-model="answers[question.key]"
                class="w-3.5 h-3.5 text-primary-600 focus:ring-primary-500"
              />
              <span class="text-xs text-gray-700">Yes</span>
            </label>
            <label class="flex items-center gap-1.5 cursor-pointer">
              <input
                type="radio"
                :name="question.key"
                :value="false"
                v-model="answers[question.key]"
                class="w-3.5 h-3.5 text-primary-600 focus:ring-primary-500"
              />
              <span class="text-xs text-gray-700">No</span>
            </label>
          </div>
        </div>
      </div>

      <button
        type="submit"
        :disabled="loading"
        class="mt-5 w-full bg-gray-900 text-white py-2.5 rounded text-sm font-semibold hover:bg-black transition disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {{ loading ? 'Submitting...' : 'Submit Application' }}
      </button>
    </form>

    <div v-if="canApply" class="bg-gray-100 border border-gray-200 rounded p-2 mt-3 text-center">
      <p class="text-[10px] font-medium text-gray-700 mb-0.5">Questions? Contact support</p>
      <a href="mailto:support@blooddonation.org" class="text-xs font-medium text-gray-900 underline hover:text-gray-700">
        support@blooddonation.org
      </a>
    </div>
  </div>
</template>
