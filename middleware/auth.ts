export default defineNuxtRouteMiddleware(async (to) => {
  const client = useSupabaseClient()

  // Use getUser() directly instead of useSupabaseUser() ref which may not be synced
  const { data: { user } } = await client.auth.getUser()

  if (!user) {
    return navigateTo('/login')
  }

  const requiredRole = to.meta.requiredRole as string | undefined
  if (requiredRole) {
    const { data: profile } = await client
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (!profile || profile.role !== requiredRole) {
      return navigateTo('/dashboard')
    }
  }
})
