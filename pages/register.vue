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

onMounted(async () => {
  const {
    data: { user },
  } = await client.auth.getUser();
  if (user) navigateTo("/dashboard");
});

async function handleRegister() {
  error.value = "";

  if (form.password !== form.confirmPassword) {
    error.value = "Passwords do not match";
    return;
  }

  if (form.password.length < 6) {
    error.value = "Password must be at least 6 characters";
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
              placeholder="Min 6 characters"
            />
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
