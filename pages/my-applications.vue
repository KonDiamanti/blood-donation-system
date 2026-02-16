<script setup lang="ts">
definePageMeta({
  middleware: 'auth',
})

const client = useSupabaseClient()

const applications = ref<any[]>([])
const loading = ref(true)

onMounted(async () => {
  const { data: { user } } = await client.auth.getUser()
  if (!user) return

  const { data } = await client
    .from('donation_applications')
    .select('id, status, rejection_reason, created_at, reviewed_at')
    .eq('citizen_id', user.id)
    .order('created_at', { ascending: false })

  applications.value = data || []
  loading.value = false
})

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
</script>

<template>
  <div class="max-w-4xl mx-auto px-4 py-6">
    <div class="flex items-center justify-between mb-5">
      <div>
        <h1 class="text-xl font-bold text-gray-900">My Applications</h1>
        <p class="text-xs text-gray-500 mt-0.5">Track the status of your donation applications</p>
      </div>
      <NuxtLink
        to="/apply"
        class="bg-gray-900 text-white px-4 py-2 rounded text-sm font-semibold hover:bg-black transition"
      >
        New Application
      </NuxtLink>
    </div>

    <div v-if="loading" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600"></div>
    </div>

    <div v-else-if="applications.length === 0" class="bg-white border border-gray-200 rounded p-8 text-center">
      <p class="text-sm text-gray-500 mb-3">You haven't submitted any applications yet.</p>
      <NuxtLink
        to="/apply"
        class="inline-block bg-gray-900 text-white px-5 py-2 rounded text-sm font-semibold hover:bg-black transition"
      >
        Submit Your First Application
      </NuxtLink>
    </div>

    <div v-else class="space-y-3">
      <div
        v-for="app in applications"
        :key="app.id"
        class="bg-white border border-gray-200 rounded p-4"
      >
        <div class="flex items-start justify-between">
          <div>
            <p class="text-xs text-gray-500">Submitted {{ formatDate(app.created_at) }}</p>
            <p v-if="app.reviewed_at" class="text-xs text-gray-400 mt-0.5">
              Reviewed {{ formatDate(app.reviewed_at) }}
            </p>
          </div>
          <span
            :class="statusColor(app.status)"
            class="text-[10px] font-semibold px-2 py-1 rounded-full capitalize"
          >
            {{ app.status }}
          </span>
        </div>

        <div v-if="app.status === 'rejected' && app.rejection_reason" class="mt-3 bg-red-50 border border-red-200 rounded p-2.5">
          <p class="text-[10px] font-semibold text-red-900 mb-1">Rejection Reason:</p>
          <p class="text-xs text-red-800">{{ app.rejection_reason }}</p>
        </div>
      </div>
    </div>
  </div>
</template>
