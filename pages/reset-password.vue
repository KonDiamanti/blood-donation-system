<script setup lang="ts">
definePageMeta({ layout: 'default' })

const client = useSupabaseClient()

const password = ref('')
const confirmPassword = ref('')
const error = ref('')
const loading = ref(false)
const success = ref(false)

async function handleReset() {
  error.value = ''
  if (password.value.length < 6) {
    error.value = 'Password must be at least 6 characters'
    return
  }
  if (password.value !== confirmPassword.value) {
    error.value = 'Passwords do not match'
    return
  }
  loading.value = true
  const { error: updateError } = await client.auth.updateUser({ password: password.value })
  if (updateError) {
    error.value = updateError.message
  } else {
    success.value = true
    setTimeout(() => navigateTo('/login'), 2000)
  }
  loading.value = false
}
</script>

<template>
  <div class="min-h-[70vh] flex items-center justify-center px-4">
    <div class="w-full max-w-md">
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h1 class="text-xl font-bold text-gray-900 mb-1">Set new password</h1>
        <p class="text-sm text-gray-500 mb-5">Enter your new password below.</p>

        <div v-if="error" class="bg-red-50 text-red-700 text-xs rounded p-2.5 mb-4 border border-red-200">
          {{ error }}
        </div>

        <div v-if="success" class="bg-green-50 text-green-700 text-xs rounded p-2.5 mb-4 border border-green-200">
          Password updated! Redirecting to login...
        </div>

        <form v-if="!success" @submit.prevent="handleReset" class="space-y-4">
          <div>
            <label class="block text-xs font-medium text-gray-700 mb-1">New Password</label>
            <input
              v-model="password"
              type="password"
              required
              autocomplete="new-password"
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
              placeholder="At least 6 characters"
            />
          </div>

          <div>
            <label class="block text-xs font-medium text-gray-700 mb-1">Confirm Password</label>
            <input
              v-model="confirmPassword"
              type="password"
              required
              autocomplete="new-password"
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
              placeholder="Repeat your password"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full bg-gray-900 text-white py-2 text-sm rounded font-semibold hover:bg-black transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ loading ? 'Updating...' : 'Update Password' }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>
