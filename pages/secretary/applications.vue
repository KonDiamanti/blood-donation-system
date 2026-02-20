<script setup lang="ts">
definePageMeta({
  middleware: 'auth',
  requiredRole: 'secretary',
})

const client = useSupabaseClient()

const applications = ref<any[]>([])
const loading = ref(true)
const filter = ref<'all' | 'pending' | 'approved' | 'rejected'>('pending')
const selectedApp = ref<any>(null)
const citizenDetails = ref<any>(null)
const rejectionReason = ref('')
const actionLoading = ref(false)
const isEditing = ref(false)

async function loadApplications() {
  loading.value = true

  let query = client
    .from('donation_applications')
    .select('*, citizen:profiles!citizen_id(first_name, last_name, email, blood_type, area, phone_number, age)')
    .order('created_at', { ascending: false })

  if (filter.value !== 'all') {
    query = query.eq('status', filter.value)
  }

  const { data } = await query
  applications.value = data || []
  loading.value = false
}

onMounted(loadApplications)
watch(filter, loadApplications)

function viewApplication(app: any) {
  selectedApp.value = app
  rejectionReason.value = app.rejection_reason || ''
  isEditing.value = false
}

function startEditing() {
  isEditing.value = true
}

function cancelEditing() {
  if (selectedApp.value) {
    rejectionReason.value = selectedApp.value.rejection_reason || ''
  }
  isEditing.value = false
}

async function updateStatus(status: 'approved' | 'rejected') {
  if (!selectedApp.value) return
  actionLoading.value = true

  const { data: { user } } = await client.auth.getUser()
  if (!user) {
    actionLoading.value = false
    return
  }

  const { error } = await (client as any)
    .from('donation_applications')
    .update({
      status,
      rejection_reason: status === 'rejected' ? rejectionReason.value : null,
      reviewed_by: user.id,
      reviewed_at: new Date().toISOString(),
    })
    .eq('id', selectedApp.value.id)

  if (!error) {
    const citizenEmail = selectedApp.value.citizen?.email
    const citizenFirstName = selectedApp.value.citizen?.first_name
    console.log('[Email] Sending to:', citizenEmail, 'status:', status)

    const emailResult = await $fetch('/api/email/send-application-status', {
      method: 'POST',
      body: {
        email: citizenEmail,
        firstName: citizenFirstName,
        status,
        applicationId: selectedApp.value.id,
        rejectionReason: status === 'rejected' ? rejectionReason.value : undefined,
      },
    }).catch((err) => { console.error('[Email] Fetch error:', err); return null })

    console.log('[Email] Result:', emailResult)

    isEditing.value = false
    selectedApp.value = null
    await loadApplications()
  }

  actionLoading.value = false
}

const statusColor = (status: string) => {
  switch (status) {
    case 'approved': return 'bg-green-100 text-green-800'
    case 'rejected': return 'bg-red-100 text-red-800'
    default: return 'bg-warning-100 text-warning-800'
  }
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

const healthQuestions = [
  { key: 'is_free_of_infections', label: 'Free of infections', inverted: true },
  { key: 'has_tattoos_or_piercings', label: 'Recent tattoos/piercings', inverted: false },
  { key: 'has_recent_procedures', label: 'Recent medical procedures', inverted: false },
  { key: 'has_travel_to_risk_areas', label: 'Travel to risk areas', inverted: false },
  { key: 'has_risk_behavior', label: 'High-risk behavior', inverted: false },
  { key: 'is_recently_pregnant', label: 'Recently pregnant', inverted: false },
  { key: 'is_breastfeeding', label: 'Currently breastfeeding', inverted: false },
  { key: 'has_drug_use', label: 'Intravenous drug use', inverted: false },
  { key: 'has_aids', label: 'HIV/AIDS diagnosis', inverted: false },
]
</script>

<template>
  <div class="max-w-6xl mx-auto px-4 py-12">
    <h1 class="text-3xl font-bold text-gray-900 mb-2">Applications</h1>
    <p class="text-gray-500 mb-8">Review and manage blood donation applications</p>

    <!-- Filter tabs -->
    <div class="flex gap-2 mb-6">
      <button
        v-for="f in (['all', 'pending', 'approved', 'rejected'] as const)"
        :key="f"
        @click="filter = f"
        :class="[
          'px-4 py-2 rounded-lg text-sm font-medium transition capitalize',
          filter === f
            ? 'bg-primary-600 text-white'
            : 'bg-white border border-gray-200 text-gray-600 hover:bg-gray-50'
        ]"
      >
        {{ f }}
      </button>
    </div>

    <div v-if="loading" class="flex justify-center py-20">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
    </div>

    <div v-else-if="applications.length === 0" class="bg-white border border-gray-200 rounded-xl p-12 text-center">
      <p class="text-gray-500">No {{ filter === 'all' ? '' : filter }} applications found.</p>
    </div>

    <!-- Applications list -->
    <div v-else class="space-y-3">
      <div
        v-for="app in applications"
        :key="app.id"
        @click="viewApplication(app)"
        class="bg-white border border-gray-200 rounded-xl p-5 cursor-pointer hover:border-gray-300 transition"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="font-medium text-gray-900">
              {{ app.citizen?.first_name }} {{ app.citizen?.last_name }}
            </p>
            <p class="text-sm text-gray-500">{{ app.citizen?.email }}</p>
            <p class="text-sm text-gray-400 mt-1">{{ formatDate(app.created_at) }}</p>
          </div>
          <div class="flex items-center gap-3">
            <span v-if="app.citizen?.blood_type" class="text-sm font-medium text-gray-600 bg-gray-100 px-2 py-1 rounded">
              {{ app.citizen.blood_type }}
            </span>
            <span
              :class="statusColor(app.status)"
              class="text-xs font-medium px-3 py-1 rounded-full capitalize"
            >
              {{ app.status }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Application detail modal -->
    <Teleport to="body">
      <div
        v-if="selectedApp"
        class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
        @click.self="selectedApp = null"
      >
        <div class="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto p-8">
          <div class="flex items-start justify-between mb-6">
            <div>
              <h2 class="text-xl font-bold text-gray-900">Application Details</h2>
              <p class="text-sm text-gray-500 mt-1">Submitted {{ formatDate(selectedApp.created_at) }}</p>
            </div>
            <button @click="selectedApp = null" class="text-gray-400 hover:text-gray-600">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <!-- Citizen info -->
          <div class="bg-gray-50 rounded-xl p-5 mb-6">
            <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-3">Citizen Information</h3>
            <div class="grid grid-cols-2 gap-3 text-sm">
              <div>
                <span class="text-gray-500">Name:</span>
                <span class="ml-2 text-gray-900 font-medium">{{ selectedApp.citizen?.first_name }} {{ selectedApp.citizen?.last_name }}</span>
              </div>
              <div>
                <span class="text-gray-500">Email:</span>
                <span class="ml-2 text-gray-900">{{ selectedApp.citizen?.email }}</span>
              </div>
              <div>
                <span class="text-gray-500">Blood Type:</span>
                <span class="ml-2 text-gray-900 font-medium">{{ selectedApp.citizen?.blood_type || 'N/A' }}</span>
              </div>
              <div>
                <span class="text-gray-500">Age:</span>
                <span class="ml-2 text-gray-900">{{ selectedApp.citizen?.age || 'N/A' }}</span>
              </div>
              <div>
                <span class="text-gray-500">Phone:</span>
                <span class="ml-2 text-gray-900">{{ selectedApp.citizen?.phone_number || 'N/A' }}</span>
              </div>
              <div>
                <span class="text-gray-500">Area:</span>
                <span class="ml-2 text-gray-900">{{ selectedApp.citizen?.area || 'N/A' }}</span>
              </div>
            </div>
          </div>

          <!-- Health questionnaire -->
          <div class="mb-6">
            <h3 class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">Health Questionnaire</h3>
            <div class="space-y-1">
              <div
                v-for="q in healthQuestions"
                :key="q.key"
                class="flex items-center justify-between py-2 px-3 rounded border"
                :class="(q.inverted ? !selectedApp[q.key] : selectedApp[q.key]) ? 'bg-red-50 border-red-200' : 'bg-white border-gray-200'"
              >
                <span class="text-xs text-gray-700">{{ q.label }}</span>
                <div class="flex items-center gap-1.5 w-16 justify-end">
                  <span
                    :class="(q.inverted ? !selectedApp[q.key] : selectedApp[q.key]) ? 'text-red-600' : 'text-green-600'"
                  >
                    <svg v-if="selectedApp[q.key]" class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                      <path v-if="!(q.inverted ? !selectedApp[q.key] : selectedApp[q.key])" fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                      <path v-else fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                    </svg>
                    <svg v-else class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                      <path v-if="!(q.inverted ? !selectedApp[q.key] : selectedApp[q.key])" fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                      <path v-else fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                    </svg>
                  </span>
                  <span class="text-xs font-medium text-gray-600 w-7 text-left">{{ selectedApp[q.key] ? 'Yes' : 'No' }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Actions for pending applications OR editing mode -->
          <div v-if="selectedApp.status === 'pending' || isEditing" class="border-t border-gray-200 pt-4 mt-4">
            <div class="mb-3">
              <label class="block text-xs font-medium text-gray-700 mb-1">Rejection reason (optional)</label>
              <textarea
                v-model="rejectionReason"
                rows="2"
                class="w-full px-3 py-2 text-xs border border-gray-300 rounded focus:ring-1 focus:ring-primary-500 focus:border-primary-500 outline-none transition resize-none"
                placeholder="Required if rejecting..."
              ></textarea>
            </div>
            <div class="flex gap-2">
              <button
                @click="updateStatus('approved')"
                :disabled="actionLoading"
                class="flex-1 bg-green-600 text-white py-2 rounded text-xs font-semibold hover:bg-green-700 transition disabled:opacity-50"
              >
                {{ actionLoading ? 'Processing...' : 'Approve' }}
              </button>
              <button
                @click="updateStatus('rejected')"
                :disabled="actionLoading"
                class="flex-1 bg-red-600 text-white py-2 rounded text-xs font-semibold hover:bg-red-700 transition disabled:opacity-50"
              >
                {{ actionLoading ? 'Processing...' : 'Reject' }}
              </button>
              <button
                v-if="isEditing"
                @click="cancelEditing"
                :disabled="actionLoading"
                class="px-4 bg-gray-200 text-gray-700 py-2 rounded text-xs font-semibold hover:bg-gray-300 transition disabled:opacity-50"
              >
                Cancel
              </button>
            </div>
          </div>

          <!-- Already reviewed - Show status and Edit button -->
          <div v-else class="border-t border-gray-200 pt-6">
            <div class="flex items-start justify-between">
              <div>
                <p class="text-sm text-gray-500">
                  This application was
                  <span :class="selectedApp.status === 'approved' ? 'text-green-700' : 'text-red-700'" class="font-medium">
                    {{ selectedApp.status }}
                  </span>
                  <span v-if="selectedApp.reviewed_at"> on {{ formatDate(selectedApp.reviewed_at) }}</span>
                </p>
                <p v-if="selectedApp.rejection_reason" class="text-sm text-red-700 mt-2 bg-red-50 rounded p-2">
                  <span class="font-medium">Reason:</span> {{ selectedApp.rejection_reason }}
                </p>
              </div>
              <button
                @click="startEditing"
                class="bg-gray-900 text-white px-4 py-2 rounded text-xs font-semibold hover:bg-black transition"
              >
                Edit
              </button>
            </div>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>
