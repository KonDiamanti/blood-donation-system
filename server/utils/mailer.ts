import nodemailer from 'nodemailer'

function createTransport() {
  return nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 587,
    secure: false,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  })
}

async function loadTemplate(name: string, vars: Record<string, string>): Promise<string> {
  const storage = useStorage('assets:email-templates')
  let html = (await storage.getItem<string>(`${name}.html`)) ?? ''
  for (const [key, value] of Object.entries(vars)) {
    html = html.replaceAll(`{{${key}}}`, value)
  }
  return html
}

export async function sendApplicationStatusEmail(opts: {
  to: string
  firstName: string
  status: 'approved' | 'rejected'
  rejectionReason?: string
}) {
  const transporter = createTransport()

  if (opts.status === 'approved') {
    const html = await loadTemplate('application-approved', {
      firstName: opts.firstName,
      appUrl: process.env.APP_URL ?? 'https://blood-donation-system-neon.vercel.app',
    })
    await transporter.sendMail({
      from: `Blood Donation System <${process.env.SMTP_USER}>`,
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
    await transporter.sendMail({
      from: `Blood Donation System <${process.env.SMTP_USER}>`,
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
  const transporter = createTransport()

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

  await transporter.sendMail({
    from: `Blood Donation System <${process.env.SMTP_USER}>`,
    to: opts.to,
    subject: 'Your donation appointment is confirmed',
    html,
  })
}
