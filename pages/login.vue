<script setup lang="ts">
definePageMeta({ layout: "default" });

const client = useSupabaseClient();

const email = ref("");
const password = ref("");
const error = ref("");
const loading = ref(false);
const showForgotPassword = ref(false);
const resetSuccess = ref(false);

onMounted(async () => {
  const {
    data: { user },
  } = await client.auth.getUser();
  if (user) navigateTo("/dashboard");
});

async function handleLogin() {
  error.value = "";
  loading.value = true;

  const { data, error: authError } = await client.auth.signInWithPassword({
    email: email.value,
    password: password.value,
  });

  if (authError) {
    error.value = authError.message;
    loading.value = false;
    return;
  }

  if (!data.session) {
    error.value =
      "Login succeeded but no session was returned. Your email may not be confirmed yet.";
    loading.value = false;
    return;
  }

  navigateTo("/dashboard");
}

async function handleForgotPassword() {
  error.value = "";
  resetSuccess.value = false;
  loading.value = true;

  const { error: resetError } = await client.auth.resetPasswordForEmail(email.value, {
    redirectTo: `${window.location.origin}/reset-password`,
  });

  if (resetError) {
    error.value = resetError.message;
    loading.value = false;
    return;
  }

  resetSuccess.value = true;
  loading.value = false;
}
</script>

<template>
  <div class="min-h-[70vh] flex items-center justify-center px-4">
    <div class="w-full max-w-md">
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h1 class="text-xl font-bold text-gray-900 mb-1">
          {{ showForgotPassword ? 'Reset Password' : 'Welcome back' }}
        </h1>
        <p class="text-sm text-gray-500 mb-5">
          {{ showForgotPassword ? 'Enter your email to receive reset instructions' : 'Sign in to your account' }}
        </p>

        <div
          v-if="error"
          class="bg-red-50 text-red-700 text-xs rounded p-2.5 mb-4 border border-red-200"
        >
          {{ error }}
        </div>

        <div
          v-if="resetSuccess"
          class="bg-green-50 text-green-700 text-xs rounded p-2.5 mb-4 border border-green-200"
        >
          Password reset email sent! Check your inbox.
        </div>

        <form v-if="!showForgotPassword" @submit.prevent="handleLogin" class="space-y-4">
          <div>
            <label
              for="email"
              class="block text-xs font-medium text-gray-700 mb-1"
              >Email</label
            >
            <input
              id="email"
              v-model="email"
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
              v-model="password"
              type="password"
              required
              autocomplete="current-password"
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
              placeholder="Your password"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full bg-gray-900 text-white py-2 text-sm rounded font-semibold hover:bg-black transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ loading ? "Signing in..." : "Sign in" }}
          </button>
        </form>

        <form v-else @submit.prevent="handleForgotPassword" class="space-y-4">
          <div>
            <label
              for="reset-email"
              class="block text-xs font-medium text-gray-700 mb-1"
              >Email</label
            >
            <input
              id="reset-email"
              v-model="email"
              type="email"
              required
              autocomplete="email"
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
              placeholder="you@example.com"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full bg-gray-900 text-white py-2 text-sm rounded font-semibold hover:bg-black transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ loading ? "Sending..." : "Send Reset Link" }}
          </button>
        </form>

        <div class="mt-4 text-center">
          <button
            @click="showForgotPassword = !showForgotPassword; error = ''; resetSuccess = false"
            class="text-xs text-primary-600 hover:text-primary-700 font-medium"
          >
            {{ showForgotPassword ? 'Back to login' : 'Forgot password?' }}
          </button>
        </div>

        <p v-if="!showForgotPassword" class="mt-2 text-center text-xs text-gray-500">
          Don't have an account?
          <NuxtLink
            to="/register"
            class="text-primary-600 hover:text-primary-700 font-medium"
            >Register</NuxtLink
          >
        </p>
      </div>
    </div>
  </div>
</template>
