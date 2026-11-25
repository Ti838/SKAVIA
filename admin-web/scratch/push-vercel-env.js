// Push Mailjet env vars to Vercel via API
// Usage: node push-vercel-env.js YOUR_VERCEL_PERSONAL_TOKEN
const token = process.argv[2];
if (!token) {
  console.log('Usage: node push-vercel-env.js YOUR_TOKEN');
  console.log('Get token: https://vercel.com/account/tokens -> Create Token');
  process.exit(1);
}

const PROJECT_ID = 'prj_0L7zwDASVxNgo7QG68fnOmdcajKP';

const vars = [
  { key: 'SMTP_HOST', value: 'in-v3.mailjet.com' },
  { key: 'SMTP_PORT', value: '587' },
  { key: 'SMTP_USER', value: '42ee62d8793626906b43dbadbd71afa0' },
  { key: 'SMTP_PASS', value: '4c10aad14925a6b1dd78a5e52f52d521' },
  { key: 'SMTP_FROM', value: 'SKAVIA Security <timonbiswas29@gmail.com>' },
];

async function run() {
  for (const v of vars) {
    // First try to delete existing (ignore errors)
    try {
      const listRes = await fetch(
        `https://api.vercel.com/v9/projects/${PROJECT_ID}/env?limit=100`,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      const list = await listRes.json();
      const existing = (list.envs || []).find(e => e.key === v.key);
      if (existing) {
        await fetch(`https://api.vercel.com/v9/projects/${PROJECT_ID}/env/${existing.id}`, {
          method: 'DELETE',
          headers: { Authorization: `Bearer ${token}` },
        });
        console.log(`  Removed old ${v.key}`);
      }
    } catch {}

    // Create
    const res = await fetch(`https://api.vercel.com/v10/projects/${PROJECT_ID}/env`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        key: v.key,
        value: v.value,
        type: 'encrypted',
        target: ['production', 'preview', 'development'],
      }),
    });
    const data = await res.json();
    if (data.key || data.id) {
      console.log(`✅ ${v.key} set`);
    } else {
      console.log(`❌ ${v.key} failed:`, JSON.stringify(data).slice(0, 120));
    }
  }
  console.log('\nDone! Now redeploy: https://vercel.com/dashboard');
}

run().catch(console.error);
