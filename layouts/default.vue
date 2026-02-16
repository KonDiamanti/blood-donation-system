<script setup lang="ts">
const user = useSupabaseUser()
const client = useSupabaseClient()
const route = useRoute()

const profile = ref<{ role: string; first_name: string } | null>(null)
const isAuthenticated = ref(false)

async function checkAuth() {
  const { data: { user: currentUser } } = await client.auth.getUser()

  if (currentUser?.id) {
    isAuthenticated.value = true
    const { data } = await client
      .from('profiles')
      .select('role, first_name')
      .eq('id', currentUser.id)
      .single()
    profile.value = data
  } else {
    isAuthenticated.value = false
    profile.value = null
  }
}

// Check on mount and route changes
onMounted(checkAuth)
watch(() => route.path, checkAuth)

// Also watch the reactive user ref for signout
watch(user, (u) => {
  if (!u) {
    isAuthenticated.value = false
    profile.value = null
  }
})

async function logout() {
  await client.auth.signOut()
  navigateTo('/login')
}
</script>

<template>
  <div class="min-h-screen flex flex-col bg-gray-50">
    <!-- Top info bar -->
    <div class="bg-primary-700 text-white py-2">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between text-xs">
          <div class="flex items-center gap-6">
            <span>📧 support@blooddonate.gr</span>
            <span>🕒 Mon-Fri: 08:00 - 17:00</span>
          </div>
          <div v-if="isAuthenticated && profile" class="text-white/90">
            Welcome, {{ profile.first_name }}
          </div>
        </div>
      </div>
    </div>

    <!-- Main header -->
    <header class="bg-white shadow-sm sticky top-0 z-50">
      <nav class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-20">
          <!-- Logo -->
          <NuxtLink to="/" class="flex items-center gap-3">
            <div class="bg-primary-600 p-2 rounded-lg">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-white" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
              </svg>
            </div>
            <div>
              <div class="text-xl font-bold text-gray-900">Blood Donors</div>
              <div class="text-xs text-gray-500">Save Lives Together</div>
            </div>
          </NuxtLink>

          <!-- Navigation -->
          <div class="flex items-center gap-8">
            <template v-if="isAuthenticated && profile">
              <NuxtLink
                v-if="profile.role === 'citizen'"
                to="/dashboard"
                class="text-sm font-medium text-gray-700 hover:text-primary-600 transition"
              >
                Dashboard
              </NuxtLink>
              <NuxtLink
                v-if="profile.role === 'citizen'"
                to="/apply"
                class="text-sm font-medium text-gray-700 hover:text-primary-600 transition"
              >
                Apply to Donate
              </NuxtLink>
              <NuxtLink
                v-if="profile.role === 'secretary'"
                to="/secretary/applications"
                class="text-sm font-medium text-gray-700 hover:text-primary-600 transition"
              >
                Applications
              </NuxtLink>
              <NuxtLink
                v-if="profile.role === 'admin'"
                to="/admin/users"
                class="text-sm font-medium text-gray-700 hover:text-primary-600 transition"
              >
                User Management
              </NuxtLink>
              <NuxtLink
                to="/profile"
                class="text-sm font-medium text-gray-700 hover:text-primary-600 transition"
              >
                Profile
              </NuxtLink>
              <button
                @click="logout"
                class="text-sm font-medium text-gray-700 hover:text-primary-600 transition"
              >
                Logout
              </button>
            </template>
            <template v-else>
              <NuxtLink
                to="/"
                class="text-sm font-medium text-gray-700 hover:text-primary-600 transition"
              >
                Home
              </NuxtLink>
              <NuxtLink
                to="/login"
                class="text-sm font-medium text-gray-700 hover:text-primary-600 transition"
              >
                Login
              </NuxtLink>
              <NuxtLink
                to="/register"
                class="bg-primary-600 text-white px-6 py-2.5 rounded-md text-sm font-semibold hover:bg-primary-700 transition shadow-sm"
              >
                Become a Donor
              </NuxtLink>
            </template>
          </div>
        </div>
      </nav>
    </header>

    <main class="flex-1">
      <slot />
    </main>

    <!-- Footer -->
    <footer class="bg-gray-900 text-gray-300">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <!-- About -->
          <div>
            <h3 class="text-white font-bold text-lg mb-4">Blood Donation System</h3>
            <p class="text-sm text-gray-400 leading-relaxed">
              Connecting donors with those in need. Every donation saves lives.
            </p>
          </div>

          <!-- Contact -->
          <div>
            <h3 class="text-white font-bold text-lg mb-4">Contact Us</h3>
            <div class="space-y-2 text-sm">
              <p>📧 support@blooddonate.gr</p>
              <p>📞 +30 210 1234567</p>
              <p>🕒 Mon-Fri: 08:00 - 17:00</p>
            </div>
          </div>

          <!-- Links -->
          <div>
            <h3 class="text-white font-bold text-lg mb-4">Quick Links</h3>
            <div class="space-y-2 text-sm">
              <NuxtLink to="/register" class="block hover:text-white transition">Become a Donor</NuxtLink>
              <NuxtLink to="/login" class="block hover:text-white transition">Login</NuxtLink>
            </div>
          </div>
        </div>

        <div class="border-t border-gray-800 mt-8 pt-8 text-center text-sm text-gray-500">
          &copy; 2026 Blood Donation System. All rights reserved.
        </div>
      </div>
    </footer>
  </div>
</template>
