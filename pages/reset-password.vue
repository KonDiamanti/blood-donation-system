<script setup lang="ts">
definePageMeta({ layout: 'default' })

const client = useSupabaseClient()

const password = ref('')
const confirmPassword = ref('')
const error = ref('')
const loading = ref(false)
const success = ref(false)

const rules = computed(() => ({
  length:  password.value.length >= 8,
  upper:   /[A-Z]/.test(password.value),
  number:  /[0-9]/.test(password.value),
  symbol:  /[^A-Za-z0-9]/.test(password.value),
}))

const allMet = computed(() => Object.values(rules.value).every(Boolean))

async function handleReset() {
  error.value = ''
  if (!allMet.value) {
    error.value = 'Please meet all password requirements'
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
              placeholder="Create a strong password"
            />

            <!-- Strength bars -->
            <div v-if="password.length > 0" class="mt-2 flex gap-1">
              <div
                v-for="i in 4"
                :key="i"
                class="h-1 flex-1 rounded-full transition-colors duration-300"
                :class="Object.values(rules).filter(Boolean).length >= i ? 'bg-green-500' : 'bg-gray-200'"
              />
            </div>

            <!-- Requirements checklist -->
            <ul v-if="password.length > 0" class="mt-2 space-y-1">
              <li
                v-for="{ key, label } in [
                  { key: 'length', label: 'At least 8 characters' },
                  { key: 'upper',  label: 'One uppercase letter' },
                  { key: 'number', label: 'One number' },
                  { key: 'symbol', label: 'One special character' },
                ]"
                :key="key"
                class="flex items-center gap-1.5 text-xs transition-colors duration-200"
                :class="rules[key as keyof typeof rules] ? 'text-green-600' : 'text-gray-400'"
              >
                <svg v-if="rules[key as keyof typeof rules]" class="w-3.5 h-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                </svg>
                <svg v-else class="w-3.5 h-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                  <circle cx="12" cy="12" r="9" stroke-width="2" />
                </svg>
                {{ label }}
              </li>
            </ul>
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
