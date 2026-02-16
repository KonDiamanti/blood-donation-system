<script setup lang="ts">
definePageMeta({ layout: 'default' })

const user = useSupabaseUser()

watch(user, (u) => {
  if (u) navigateTo('/dashboard')
}, { immediate: true })
</script>

<template>
  <div class="min-h-[80vh] flex items-center justify-center">
    <div class="text-center">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto mb-4"></div>
      <p class="text-gray-600">Confirming your account...</p>
    </div>
  </div>
</template>
