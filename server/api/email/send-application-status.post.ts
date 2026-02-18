import { sendApplicationStatusEmail } from '~/server/utils/mailer'

export default defineEventHandler(async (event) => {
  const { email, firstName, status, rejectionReason } = await readBody(event)

  if (!email || !firstName || !status) {
    throw createError({ statusCode: 400, message: 'Missing required fields' })
  }

  try {
    await sendApplicationStatusEmail({ to: email, firstName, status, rejectionReason })
    console.log('[Email] Sent successfully to:', email)
    return { success: true }
  } catch (err: any) {
    console.error('[Email] Failed:', err?.message ?? err)
    throw createError({ statusCode: 500, message: err?.message ?? 'Failed to send email' })
  }
})
