import { sendAppointmentConfirmationEmail } from '~/server/utils/mailer'

export default defineEventHandler(async (event) => {
  const { email, firstName, clinicName, clinicAddress, appointmentDate } = await readBody(event)

  if (!email || !firstName || !clinicName || !clinicAddress || !appointmentDate) {
    throw createError({ statusCode: 400, message: 'Missing required fields' })
  }

  try {
    await sendAppointmentConfirmationEmail({ to: email, firstName, clinicName, clinicAddress, appointmentDate })
    return { success: true }
  } catch (err) {
    console.error('Failed to send appointment confirmation email:', err)
    return { success: false }
  }
})
