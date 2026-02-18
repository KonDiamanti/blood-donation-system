<script setup lang="ts">
definePageMeta({ layout: "default" });

const client = useSupabaseClient();

const form = reactive({
  firstName: "",
  lastName: "",
  email: "",
  password: "",
  confirmPassword: "",
});

const error = ref("");
const loading = ref(false);

const passwordRules = computed(() => ({
  length:  form.password.length >= 8,
  upper:   /[A-Z]/.test(form.password),
  number:  /[0-9]/.test(form.password),
  symbol:  /[^A-Za-z0-9]/.test(form.password),
}))

const allPasswordMet = computed(() => Object.values(passwordRules.value).every(Boolean))

onMounted(async () => {
  const {
    data: { user },
  } = await client.auth.getUser();
  if (user) navigateTo("/dashboard");
});

async function handleRegister() {
  error.value = "";

  if (!allPasswordMet.value) {
    error.value = "Please meet all password requirements";
    return;
  }

  if (form.password !== form.confirmPassword) {
    error.value = "Passwords do not match";
    return;
  }

  loading.value = true;

  const { data, error: authError } = await client.auth.signUp({
    email: form.email,
    password: form.password,
    options: {
      data: {
        first_name: form.firstName,
        last_name: form.lastName,
        role: "citizen",
      },
    },
  });

  if (authError) {
    error.value = authError.message;
    loading.value = false;
    return;
  }

  navigateTo("/dashboard");
}
</script>

<template>
  <div class="min-h-[70vh] flex items-center justify-center px-4 py-8">
    <div class="w-full max-w-md">
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h1 class="text-xl font-bold text-gray-900 mb-1">Create an account</h1>
        <p class="text-sm text-gray-500 mb-5">Register as a blood donor</p>

        <div
          v-if="error"
          class="bg-red-50 text-red-700 text-xs rounded p-2.5 mb-4"
        >
          {{ error }}
        </div>

        <form @submit.prevent="handleRegister" class="space-y-4">
          <div class="grid grid-cols-2 gap-3">
            <div>
              <label
                for="firstName"
                class="block text-xs font-medium text-gray-700 mb-1"
                >First name</label
              >
              <input
                id="firstName"
                v-model="form.firstName"
                type="text"
                required
                class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
                placeholder="John"
              />
            </div>
            <div>
              <label
                for="lastName"
                class="block text-xs font-medium text-gray-700 mb-1"
                >Last name</label
              >
              <input
                id="lastName"
                v-model="form.lastName"
                type="text"
                required
                class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
                placeholder="Doe"
              />
            </div>
          </div>

          <div>
            <label
              for="email"
              class="block text-xs font-medium text-gray-700 mb-1"
              >Email</label
            >
            <input
              id="email"
              v-model="form.email"
              type="email"
              required
              autocomplete="email"
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
              placeholder="you@example.com"
            />
          </div>

          <div>
            <label
              for="password"
              class="block text-xs font-medium text-gray-700 mb-1"
              >Password</label
            >
            <input
              id="password"
              v-model="form.password"
              type="password"
              required
              autocomplete="new-password"
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
              placeholder="Create a strong password"
            />

            <!-- Strength bars -->
            <div v-if="form.password.length > 0" class="mt-2 flex gap-1">
              <div
                v-for="i in 4"
                :key="i"
                class="h-1 flex-1 rounded-full transition-colors duration-300"
                :class="Object.values(passwordRules).filter(Boolean).length >= i ? 'bg-green-500' : 'bg-gray-200'"
              />
            </div>

            <!-- Requirements checklist -->
            <ul v-if="form.password.length > 0" class="mt-2 space-y-1">
              <li
                v-for="{ key, label } in [
                  { key: 'length', label: 'At least 8 characters' },
                  { key: 'upper',  label: 'One uppercase letter' },
                  { key: 'number', label: 'One number' },
                  { key: 'symbol', label: 'One special character' },
                ]"
                :key="key"
                class="flex items-center gap-1.5 text-xs transition-colors duration-200"
                :class="passwordRules[key as keyof typeof passwordRules] ? 'text-green-600' : 'text-gray-400'"
              >
                <svg v-if="passwordRules[key as keyof typeof passwordRules]" class="w-3.5 h-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
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
            <label
              for="confirmPassword"
              class="block text-xs font-medium text-gray-700 mb-1"
              >Confirm password</label
            >
            <input
              id="confirmPassword"
              v-model="form.confirmPassword"
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
            {{ loading ? "Creating account..." : "Create account" }}
          </button>
        </form>

        <p class="mt-4 text-center text-xs text-gray-500">
          Already have an account?
          <NuxtLink
            to="/login"
            class="text-primary-600 hover:text-primary-700 font-medium"
            >Sign in</NuxtLink
          >
        </p>
      </div>
    </div>
  </div>
</template>
