async function loadTemplate(name: string, vars: Record<string, string>): Promise<string> {
  const storage = useStorage('assets:email-templates')
  const keys = await storage.getKeys()
  console.log('[Template] Available keys:', JSON.stringify(keys))
  const raw = await storage.getItemRaw(`${name}.html`)
  console.log('[Template] Raw type:', typeof raw, '| has value:', !!raw)
  let html = ''
  if (typeof raw === 'string') {
    html = raw
  } else if (raw) {
    html = new TextDecoder().decode(raw as Uint8Array)
  }
  for (const [key, value] of Object.entries(vars)) {
    html = html.replaceAll(`{{${key}}}`, value)
  }
  return html
}

async function sendEmail(opts: { to: string; subject: string; html: string }) {
  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: 'Blood Donation System <onboarding@resend.dev>',
      to: opts.to,
      subject: opts.subject,
      html: opts.html,
    }),
  })
  if (!res.ok) {
    const body = await res.text()
    throw new Error(`Resend error ${res.status}: ${body}`)
  }
}

export async function sendApplicationStatusEmail(opts: {
  to: string
  firstName: string
  status: 'approved' | 'rejected'
  rejectionReason?: string
}) {
  if (opts.status === 'approved') {
    const html = await loadTemplate('application-approved', {
      firstName: opts.firstName,
      appUrl: process.env.APP_URL ?? 'https://blood-donation-system-neon.vercel.app',
    })
    await sendEmail({
      to: opts.to,
      subject: 'Your blood donation application has been approved',
      html,
    })
  } else {
    const rejectionReasonBlock = opts.rejectionReason
      ? `<p style="background:#fef2f2;border-left:4px solid #EE3545;padding:10px 14px;color:#374151;"><strong>Reason:</strong> ${opts.rejectionReason}</p>`
      : ''
    const html = await loadTemplate('application-rejected', {
      firstName: opts.firstName,
      rejectionReasonBlock,
    })
    await sendEmail({
      to: opts.to,
      subject: 'Update on your blood donation application',
      html,
    })
  }
}

export async function sendAppointmentConfirmationEmail(opts: {
  to: string
  firstName: string
  clinicName: string
  clinicAddress: string
  appointmentDate: string
}) {
  const formattedDate = new Date(opts.appointmentDate).toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })

  const html = await loadTemplate('appointment-confirmation', {
    firstName: opts.firstName,
    clinicName: opts.clinicName,
    clinicAddress: opts.clinicAddress,
    appointmentDate: formattedDate,
  })

  await sendEmail({
    to: opts.to,
    subject: 'Your donation appointment is confirmed',
    html,
  })
}
