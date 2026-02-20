<script setup lang="ts">
definePageMeta({ layout: 'default' })

const client = useSupabaseClient()
const route = useRoute()

const error = ref('')
const verifying = ref(true)
const confirmed = ref(false)

onMounted(async () => {
  const tokenHash = route.query.token_hash as string
  const type = route.query.type as string
  const code = route.query.code as string

  let success = false

  if (tokenHash && type) {
    const { error: verifyError } = await client.auth.verifyOtp({
      token_hash: tokenHash,
      type: type as any,
    })
    if (verifyError) {
      error.value = verifyError.message
    } else {
      success = true
    }
  } else if (code) {
    const { error: exchangeError } = await client.auth.exchangeCodeForSession(code)
    if (exchangeError) {
      error.value = exchangeError.message
    } else {
      success = true
    }
  } else {
    error.value = 'Invalid confirmation link.'
  }

  verifying.value = false

  if (success) {
    confirmed.value = true
    setTimeout(() => navigateTo('/dashboard'), 2500)
  }
})
</script>

<template>
  <div class="min-h-[70vh] flex items-center justify-center px-4">
    <div class="w-full max-w-sm text-center">

      <div v-if="verifying" class="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto mb-3"></div>
        <p class="text-sm text-gray-600">Verifying your email...</p>
      </div>

      <div v-else-if="confirmed" class="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
        <div class="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-3">
          <svg class="w-6 h-6 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h2 class="text-base font-bold text-gray-900 mb-1">Email confirmed!</h2>
        <p class="text-xs text-gray-500">Thank you for confirming your account. Redirecting you to the dashboard...</p>
      </div>

      <div v-else-if="error" class="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
        <div class="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-3">
          <svg class="w-6 h-6 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </div>
        <h2 class="text-base font-bold text-gray-900 mb-1">Verification failed</h2>
        <p class="text-xs text-gray-500 mb-4">{{ error }}</p>
        <NuxtLink to="/login" class="text-xs text-primary-600 hover:text-primary-700 font-medium">
          Go to login
        </NuxtLink>
      </div>

    </div>
  </div>
</template>
