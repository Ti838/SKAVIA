const nodemailer = require('nodemailer');

async function test() {
  const transporter = nodemailer.createTransport({
    host: 'in-v3.mailjet.com',
    port: 587,
    secure: false,
    auth: {
      user: '42ee62d8793626906b43dbadbd71afa0',
      pass: '4c10aad14925a6b1dd78a5e52f52d521',
    },
  });

  try {
    const info = await transporter.sendMail({
      from: 'SKAVIA Security <timonbiswas29@gmail.com>',
      to: 'timonbiswas33@gmail.com',
      subject: 'SKAVIA OTP Test — 847291',
      text: 'Your SKAVIA verification code is: 847291 (expires in 5 minutes)',
      html: '<div style="font-family:sans-serif;max-width:480px"><h2 style="color:#003399">SKAVIA Verification</h2><p>Your 6-digit code:</p><div style="font-size:32px;font-weight:800;letter-spacing:8px;color:#003399;padding:16px;background:#f0f4ff;border-radius:8px;text-align:center">847291</div><p style="color:#666;font-size:13px">Expires in 5 minutes. Never share this code.</p></div>',
    });
    console.log('SUCCESS - MessageId:', info.messageId);
    console.log('Response:', info.response);
  } catch (e) {
    console.error('FAILED:', e.message);
  }
}

test();
