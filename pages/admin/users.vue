<script setup lang="ts">
definePageMeta({
  middleware: 'auth',
  requiredRole: 'admin',
})

const client = useSupabaseClient()

const users = ref<any[]>([])
const loading = ref(true)
const search = ref('')
const sortBy = ref<'name' | 'email' | 'role' | 'created_at' | 'blood_type'>('created_at')
const sortOrder = ref<'asc' | 'desc'>('desc')
const editingUser = ref<any>(null)
const editForm = reactive({
  first_name: '',
  last_name: '',
  role: 'citizen' as string,
  phone_number: '',
  area: '',
  blood_type: '',
  age: null as number | null,
})
const saving = ref(false)

async function loadUsers() {
  loading.value = true
  const { data } = await client
    .from('profiles')
    .select('*')
    .order('created_at', { ascending: false })

  users.value = data || []
  loading.value = false
}

onMounted(loadUsers)

const filteredUsers = computed(() => {
  let filtered = users.value

  if (search.value) {
    const q = search.value.toLowerCase()
    filtered = filtered.filter(u =>
      u.first_name?.toLowerCase().includes(q) ||
      u.last_name?.toLowerCase().includes(q) ||
      u.email?.toLowerCase().includes(q) ||
      u.role?.toLowerCase().includes(q)
    )
  }

  const sorted = [...filtered].sort((a, b) => {
    let aVal: any
    let bVal: any

    switch (sortBy.value) {
      case 'name':
        aVal = `${a.first_name || ''} ${a.last_name || ''}`.toLowerCase()
        bVal = `${b.first_name || ''} ${b.last_name || ''}`.toLowerCase()
        break
      case 'email':
        aVal = a.email?.toLowerCase() || ''
        bVal = b.email?.toLowerCase() || ''
        break
      case 'role':
        aVal = a.role || ''
        bVal = b.role || ''
        break
      case 'blood_type':
        aVal = a.blood_type || ''
        bVal = b.blood_type || ''
        break
      case 'created_at':
        aVal = new Date(a.created_at || 0).getTime()
        bVal = new Date(b.created_at || 0).getTime()
        break
    }

    if (aVal < bVal) return sortOrder.value === 'asc' ? -1 : 1
    if (aVal > bVal) return sortOrder.value === 'asc' ? 1 : -1
    return 0
  })

  return sorted
})

function toggleSort(column: 'name' | 'email' | 'role' | 'created_at' | 'blood_type') {
  if (sortBy.value === column) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortBy.value = column
    sortOrder.value = 'asc'
  }
}

function editUser(user: any) {
  editingUser.value = user
  editForm.first_name = user.first_name || ''
  editForm.last_name = user.last_name || ''
  editForm.role = user.role || 'citizen'
  editForm.phone_number = user.phone_number || ''
  editForm.area = user.area || ''
  editForm.blood_type = user.blood_type || ''
  editForm.age = user.age
}

async function saveUser() {
  if (!editingUser.value) return
  saving.value = true

  const { error } = await client
    .from('profiles')
    .update({
      first_name: editForm.first_name,
      last_name: editForm.last_name,
      role: editForm.role,
      phone_number: editForm.phone_number || null,
      area: editForm.area || null,
      blood_type: editForm.blood_type || null,
      age: editForm.age,
    })
    .eq('id', editingUser.value.id)

  if (!error) {
    editingUser.value = null
    await loadUsers()
  }

  saving.value = false
}

async function deleteUser(userId: string) {
  if (!confirm('Are you sure you want to delete this user?')) return

  const { error } = await client
    .from('profiles')
    .delete()
    .eq('id', userId)

  if (!error) {
    await loadUsers()
  }
}

const roleColor = (role: string) => {
  switch (role) {
    case 'admin': return 'bg-purple-100 text-purple-800'
    case 'secretary': return 'bg-blue-100 text-blue-800'
    default: return 'bg-gray-100 text-gray-800'
  }
}

const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
</script>

<template>
  <div class="max-w-6xl mx-auto px-4 py-12">
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">User Management</h1>
        <p class="text-gray-500 mt-1">Manage all registered users</p>
      </div>
    </div>

    <!-- Search -->
    <div class="mb-6">
      <input
        v-model="search"
        type="text"
        placeholder="Search by name, email, or role..."
        class="w-full max-w-md px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition"
      />
    </div>

    <div v-if="loading" class="flex justify-center py-20">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
    </div>

    <!-- Users table -->
    <div v-else class="bg-white border border-gray-200 rounded-xl overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th
              @click="toggleSort('name')"
              class="text-left px-6 py-3 text-xs font-semibold uppercase tracking-wide cursor-pointer hover:bg-gray-100 transition select-none group"
              :class="sortBy === 'name' ? 'text-gray-700' : 'text-gray-500'"
            >
              <div class="flex items-center gap-1.5">
                <span>Name</span>
                <svg class="w-3.5 h-3.5 transition-all" :class="[sortBy === 'name' ? (sortOrder === 'asc' ? 'rotate-180 text-gray-700' : 'text-gray-700') : 'text-gray-400 group-hover:text-gray-500']" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </div>
            </th>
            <th
              @click="toggleSort('email')"
              class="text-left px-6 py-3 text-xs font-semibold uppercase tracking-wide cursor-pointer hover:bg-gray-100 transition select-none group"
              :class="sortBy === 'email' ? 'text-gray-700' : 'text-gray-500'"
            >
              <div class="flex items-center gap-1.5">
                <span>Email</span>
                <svg class="w-3.5 h-3.5 transition-all" :class="[sortBy === 'email' ? (sortOrder === 'asc' ? 'rotate-180 text-gray-700' : 'text-gray-700') : 'text-gray-400 group-hover:text-gray-500']" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </div>
            </th>
            <th
              @click="toggleSort('role')"
              class="text-left px-6 py-3 text-xs font-semibold uppercase tracking-wide cursor-pointer hover:bg-gray-100 transition select-none group"
              :class="sortBy === 'role' ? 'text-gray-700' : 'text-gray-500'"
            >
              <div class="flex items-center gap-1.5">
                <span>Role</span>
                <svg class="w-3.5 h-3.5 transition-all" :class="[sortBy === 'role' ? (sortOrder === 'asc' ? 'rotate-180 text-gray-700' : 'text-gray-700') : 'text-gray-400 group-hover:text-gray-500']" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </div>
            </th>
            <th
              @click="toggleSort('blood_type')"
              class="text-left px-6 py-3 text-xs font-semibold uppercase tracking-wide cursor-pointer hover:bg-gray-100 transition select-none group"
              :class="sortBy === 'blood_type' ? 'text-gray-700' : 'text-gray-500'"
            >
              <div class="flex items-center gap-1.5">
                <span>Blood Type</span>
                <svg class="w-3.5 h-3.5 transition-all" :class="[sortBy === 'blood_type' ? (sortOrder === 'asc' ? 'rotate-180 text-gray-700' : 'text-gray-700') : 'text-gray-400 group-hover:text-gray-500']" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </div>
            </th>
            <th
              @click="toggleSort('created_at')"
              class="text-left px-6 py-3 text-xs font-semibold uppercase tracking-wide cursor-pointer hover:bg-gray-100 transition select-none group"
              :class="sortBy === 'created_at' ? 'text-gray-700' : 'text-gray-500'"
            >
              <div class="flex items-center gap-1.5">
                <span>Joined</span>
                <svg class="w-3.5 h-3.5 transition-all" :class="[sortBy === 'created_at' ? (sortOrder === 'asc' ? 'rotate-180 text-gray-700' : 'text-gray-700') : 'text-gray-400 group-hover:text-gray-500']" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </div>
            </th>
            <th class="text-right px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wide">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100">
          <tr v-for="u in filteredUsers" :key="u.id" class="hover:bg-gray-50">
            <td class="px-6 py-4 text-sm text-gray-900 font-medium">
              {{ u.first_name }} {{ u.last_name }}
            </td>
            <td class="px-6 py-4 text-sm text-gray-500">{{ u.email }}</td>
            <td class="px-6 py-4">
              <span :class="roleColor(u.role)" class="text-xs font-medium px-2.5 py-1 rounded-full capitalize">
                {{ u.role }}
              </span>
            </td>
            <td class="px-6 py-4 text-sm text-gray-600">{{ u.blood_type || '-' }}</td>
            <td class="px-6 py-4 text-sm text-gray-500">
              {{ new Date(u.created_at).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' }) }}
            </td>
            <td class="px-6 py-4 text-right">
              <button
                @click="editUser(u)"
                class="text-sm text-primary-600 hover:text-primary-800 font-medium mr-3"
              >
                Edit
              </button>
              <button
                @click="deleteUser(u.id)"
                class="text-sm text-red-700 hover:text-red-800 font-medium"
              >
                Delete
              </button>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="filteredUsers.length === 0" class="px-6 py-12 text-center text-gray-500">
        No users found.
      </div>
    </div>

    <!-- Edit user modal -->
    <Teleport to="body">
      <div
        v-if="editingUser"
        class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
        @click.self="editingUser = null"
      >
        <div class="bg-white rounded-2xl max-w-lg w-full p-8">
          <div class="flex items-start justify-between mb-6">
            <h2 class="text-xl font-bold text-gray-900">Edit User</h2>
            <button @click="editingUser = null" class="text-gray-400 hover:text-gray-600">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <form @submit.prevent="saveUser" class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">First name</label>
                <input v-model="editForm.first_name" type="text" required class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Last name</label>
                <input v-model="editForm.last_name" type="text" required class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition" />
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
              <select v-model="editForm.role" class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition">
                <option value="citizen">Citizen</option>
                <option value="secretary">Secretary</option>
                <option value="admin">Admin</option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Phone number</label>
              <input v-model="editForm.phone_number" type="tel" class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition" />
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Blood type</label>
                <select v-model="editForm.blood_type" class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition">
                  <option value="">None</option>
                  <option v-for="bt in bloodTypes" :key="bt" :value="bt">{{ bt }}</option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Age</label>
                <input v-model.number="editForm.age" type="number" min="18" max="100" class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition" />
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Area</label>
              <input v-model="editForm.area" type="text" class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition" />
            </div>

            <button
              type="submit"
              :disabled="saving"
              class="w-full bg-gray-900 text-white py-2.5 rounded-lg font-semibold hover:bg-black transition disabled:opacity-50 disabled:cursor-not-allowed mt-4"
            >
              {{ saving ? 'Saving...' : 'Save Changes' }}
            </button>
          </form>
        </div>
      </div>
    </Teleport>
  </div>
</template>
