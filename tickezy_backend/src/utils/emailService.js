const nodemailer = require('nodemailer');

const port = Number(process.env.SMTP_PORT) || 587;
const secure = (process.env.SMTP_SECURE === 'true') || port === 465;

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port,
  secure, // false for STARTTLS
  auth: {
    user: process.env.SMTP_EMAIL,
    pass: process.env.SMTP_PASSWORD,
  },
  tls: {
    rejectUnauthorized: false, 
  },
});

transporter.verify((err, success) => {
  if (err) console.error('SMTP verification failed:', err);
  else console.log('SMTP ready to send emails');
});

exports.sendEmail = async (to, subject, html) => {
  if (!process.env.SMTP_EMAIL || !process.env.SMTP_PASSWORD) {
    throw new Error('SMTP_EMAIL or SMTP_PASSWORD not set');
  }

  try {
    return await transporter.sendMail({
      from: `"Tickezy" <${process.env.SMTP_EMAIL}>`,
      to,
      subject,
      html,
    });
  } catch (err) {
    throw new Error(`Failed to send email: ${err.message}`);
  }
};
