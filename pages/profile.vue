<script setup lang="ts">
definePageMeta({
  middleware: 'auth',
})

const client = useSupabaseClient()

const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']

const form = reactive({
  first_name: '',
  last_name: '',
  phone_number: '',
  area: '',
  blood_type: '',
  age: null as number | null,
})

const loading = ref(true)
const saving = ref(false)
const success = ref(false)
const error = ref('')
const userEmail = ref('')

const passwordForm = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
})
const passwordSaving = ref(false)
const passwordSuccess = ref(false)
const passwordError = ref('')
const showPasswordForm = ref(false)

onMounted(async () => {
  const { data: { user } } = await client.auth.getUser()
  if (!user) return

  userEmail.value = user.email || ''

  const { data } = await client
    .from('profiles')
    .select('first_name, last_name, phone_number, area, blood_type, age')
    .eq('id', user.id)
    .single()

  if (data) {
    form.first_name = data.first_name || ''
    form.last_name = data.last_name || ''
    form.phone_number = data.phone_number || ''
    form.area = data.area || ''
    form.blood_type = data.blood_type || ''
    form.age = data.age
  }

  loading.value = false
})

async function handleSave() {
  error.value = ''
  success.value = false
  saving.value = true

  const { data: { user } } = await client.auth.getUser()
  if (!user) {
    error.value = 'Not logged in'
    saving.value = false
    return
  }

  const { error: updateError } = await client
    .from('profiles')
    .update({
      first_name: form.first_name,
      last_name: form.last_name,
      phone_number: form.phone_number || null,
      area: form.area || null,
      blood_type: form.blood_type || null,
      age: form.age,
    })
    .eq('id', user.id)

  if (updateError) {
    error.value = updateError.message
    saving.value = false
    return
  }

  success.value = true
  saving.value = false
  setTimeout(() => { success.value = false }, 3000)
}

async function handlePasswordChange() {
  passwordError.value = ''
  passwordSuccess.value = false

  if (passwordForm.newPassword !== passwordForm.confirmPassword) {
    passwordError.value = 'New passwords do not match'
    return
  }

  if (passwordForm.newPassword.length < 6) {
    passwordError.value = 'Password must be at least 6 characters'
    return
  }

  passwordSaving.value = true

  const { error: updateError } = await client.auth.updateUser({
    password: passwordForm.newPassword
  })

  if (updateError) {
    passwordError.value = updateError.message
    passwordSaving.value = false
    return
  }

  passwordSuccess.value = true
  passwordSaving.value = false
  passwordForm.currentPassword = ''
  passwordForm.newPassword = ''
  passwordForm.confirmPassword = ''
  setTimeout(() => { passwordSuccess.value = false }, 3000)
}
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 py-6">
    <h1 class="text-xl font-bold text-gray-900 mb-1">Profile</h1>
    <p class="text-sm text-gray-500 mb-5">Manage your personal information</p>

    <div v-if="loading" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600"></div>
    </div>

    <form v-else @submit.prevent="handleSave" class="space-y-4">
      <div v-if="error" class="bg-red-50 text-red-700 text-xs rounded p-2.5">
        {{ error }}
      </div>
      <div v-if="success" class="bg-green-50 text-green-700 text-xs rounded p-2.5">
        Profile updated successfully.
      </div>

      <div class="bg-white border border-gray-200 rounded p-4 space-y-3">
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-medium text-gray-700 mb-1">First name</label>
            <input
              v-model="form.first_name"
              type="text"
              required
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
            />
          </div>
          <div>
            <label class="block text-xs font-medium text-gray-700 mb-1">Last name</label>
            <input
              v-model="form.last_name"
              type="text"
              required
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
            />
          </div>
        </div>

        <div>
          <label class="block text-xs font-medium text-gray-700 mb-1">Email</label>
          <input
            :value="userEmail"
            type="email"
            disabled
            class="w-full px-3 py-2 text-sm border border-gray-200 rounded bg-gray-50 text-gray-500 cursor-not-allowed"
          />
        </div>

        <div>
          <label class="block text-xs font-medium text-gray-700 mb-1">Phone number</label>
          <input
            v-model="form.phone_number"
            type="tel"
            class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
            placeholder="+30 6XX XXX XXXX"
          />
        </div>

        <div>
          <label class="block text-xs font-medium text-gray-700 mb-1">Area</label>
          <input
            v-model="form.area"
            type="text"
            class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
            placeholder="Athens, Greece"
          />
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-medium text-gray-700 mb-1">Blood type</label>
            <select
              v-model="form.blood_type"
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
            >
              <option value="">Select blood type</option>
              <option v-for="bt in bloodTypes" :key="bt" :value="bt">{{ bt }}</option>
            </select>
          </div>
          <div>
            <label class="block text-xs font-medium text-gray-700 mb-1">Age</label>
            <input
              v-model.number="form.age"
              type="number"
              min="18"
              max="100"
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
            />
          </div>
        </div>
      </div>

      <button
        type="submit"
        :disabled="saving"
        class="w-full bg-gray-900 text-white py-2 rounded text-sm font-semibold hover:bg-black transition disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {{ saving ? 'Saving...' : 'Save Changes' }}
      </button>
    </form>

    <div class="mt-6">
      <h2 class="text-lg font-bold text-gray-900 mb-1">Change Password</h2>
      <p class="text-sm text-gray-500 mb-4">Update your account password</p>

      <form @submit.prevent="handlePasswordChange" class="space-y-4">
        <div v-if="passwordError" class="bg-red-50 text-red-700 text-xs rounded p-2.5">
          {{ passwordError }}
        </div>
        <div v-if="passwordSuccess" class="bg-green-50 text-green-700 text-xs rounded p-2.5">
          Password updated successfully.
        </div>

        <div class="bg-white border border-gray-200 rounded p-4 space-y-3">
          <div>
            <label class="block text-xs font-medium text-gray-700 mb-1">New Password</label>
            <input
              v-model="passwordForm.newPassword"
              type="password"
              required
              minlength="6"
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
              placeholder="Enter new password"
            />
          </div>

          <div>
            <label class="block text-xs font-medium text-gray-700 mb-1">Confirm New Password</label>
            <input
              v-model="passwordForm.confirmPassword"
              type="password"
              required
              minlength="6"
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
              placeholder="Confirm new password"
            />
          </div>
        </div>

        <button
          type="submit"
          :disabled="passwordSaving"
          class="w-full bg-gray-900 text-white py-2 rounded text-sm font-semibold hover:bg-black transition disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ passwordSaving ? 'Updating...' : 'Update Password' }}
        </button>
      </form>
    </div>
  </div>
</template>
