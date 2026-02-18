export default defineNuxtConfig({
  compatibilityDate: '2025-01-01',
  devtools: { enabled: true },

  modules: [
    '@nuxtjs/supabase',
    '@nuxtjs/tailwindcss',
  ],

  supabase: {
    redirect: false,
  },

  typescript: {
    strict: true,
  },

  vite: {
    optimizeDeps: {
      include: ['cookie'],
    },
  },

  nitro: {
    serverAssets: [{
      baseName: 'email-templates',
      dir: './server/email-templates',
    }],
    externals: {
      inline: ['nodemailer'],
    },
  },
})
