import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://mfsrvtvgjrwrwapkmlxg.supabase.co';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1mc3J2dHZnanJ3cndhcGttbHhnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MDQxMjQ4MCwiZXhwIjoyMTA1OTg4NDgwfQ.8PBwWXW8sRokpqb1rG2fl0UFx5y9ZbzOWg-ci-sSNBc';

function getAdminClient() {
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
    auth: { persistSession: false },
  });
}

/**
 * GET /api/public/user/nid-verification?userId=...
 * Returns the current NID verification status of a user
 */
export async function GET(req: Request) {
  const url = new URL(req.url);
  const userId = url.searchParams.get('userId');

  if (!userId) {
    return NextResponse.json({ error: 'userId is required' }, { status: 400 });
  }

  try {
    const supabase = getAdminClient();
    
    // 1. Fetch user record
    const { data: user, error: userErr } = await supabase
      .from('users')
      .select('user_id, full_name, verification_status, privacy_settings')
      .eq('user_id', userId)
      .maybeSingle();

    if (userErr) {
      return NextResponse.json({ error: userErr.message }, { status: 500 });
    }

    const verificationStatus = user?.verification_status || 'unverified';
    const privacy = (user?.privacy_settings as Record<string, unknown>) || {};

    // 2. Also check if there is an active review note from verifications table
    let reviewNotes: string | null = null;
    let submittedAt = privacy.nid_submitted_at as string | null;
    let nidNumber = privacy.nid_number as string | null;

    const { data: verifRow } = await supabase
      .from('verifications')
      .select('status, review_notes, created_at, document_number')
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (verifRow) {
      reviewNotes = verifRow.review_notes;
      if (!submittedAt) submittedAt = verifRow.created_at;
      if (!nidNumber) nidNumber = verifRow.document_number;
    }

    return NextResponse.json({
      success: true,
      status: verificationStatus,
      nidNumber: nidNumber || null,
      submittedAt: submittedAt || null,
      reviewNotes: reviewNotes || null,
      fullName: user?.full_name || null,
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : 'Internal Server Error';
    return NextResponse.json({ error: msg }, { status: 500 });
  }
}

/**
 * POST /api/public/user/nid-verification
 * Submits user NID document for compliance inspection
 */
export async function POST(req: Request) {
  try {
    const body = await req.json();
    const {
      userId,
      nidNumber,
      fullName,
      dateOfBirth,
      frontImageUrl,
      backImageUrl,
      documentType = 'National ID (NID)',
    } = body;

    if (!userId || !nidNumber) {
      return NextResponse.json(
        { error: 'userId and nidNumber are required' },
        { status: 400 }
      );
    }

    // Validate NID length (Bangladesh Smart NID: 10 digits, Old NID: 13 or 17 digits)
    const cleanNid = String(nidNumber).replace(/\D/g, '');
    if (cleanNid.length !== 10 && cleanNid.length !== 13 && cleanNid.length !== 17) {
      return NextResponse.json(
        { error: 'Bangladesh National ID must be 10 digits (Smart NID) or 17 digits (Classic NID).' },
        { status: 400 }
      );
    }

    const supabase = getAdminClient();

    // 1. Ensure user row exists and update its verification status to 'pending'
    const nowIso = new Date().toISOString();

    const { data: existingUser } = await supabase
      .from('users')
      .select('privacy_settings')
      .eq('user_id', userId)
      .maybeSingle();

    const existingPrivacy = (existingUser?.privacy_settings as Record<string, unknown>) || {};
    const updatedPrivacy = {
      ...existingPrivacy,
      nid_number: cleanNid,
      nid_dob: dateOfBirth || null,
      nid_full_name: fullName || null,
      nid_front_url: frontImageUrl || null,
      nid_back_url: backImageUrl || null,
      nid_submitted_at: nowIso,
    };

    await supabase
      .from('users')
      .update({
        verification_status: 'pending',
        privacy_settings: updatedPrivacy,
        updated_at: nowIso,
      })
      .eq('user_id', userId);

    // 2. Ensure user has a worker_profiles entry so it integrates seamlessly into the KYC review queue
    let workerProfileId: string | null = null;
    const { data: existingWp } = await supabase
      .from('worker_profiles')
      .select('worker_profile_id')
      .eq('user_id', userId)
      .maybeSingle();

    if (existingWp?.worker_profile_id) {
      workerProfileId = existingWp.worker_profile_id;
      await supabase
        .from('worker_profiles')
        .update({ verification_status: 'Pending' })
        .eq('worker_profile_id', workerProfileId);
    } else {
      // Find a default branch (e.g. Dhaka Central)
      const { data: branch } = await supabase
        .from('branches')
        .select('branch_id')
        .limit(1)
        .maybeSingle();

      const { data: newWp } = await supabase
        .from('worker_profiles')
        .insert({
          user_id: userId,
          branch_id: branch?.branch_id || null,
          title: 'Citizen Member',
          verification_status: 'Pending',
          location: 'Dhaka, Bangladesh',
          working_area: 'All Dhaka City',
        })
        .select('worker_profile_id')
        .single();

      if (newWp?.worker_profile_id) {
        workerProfileId = newWp.worker_profile_id;
      }
    }

    // 3. Insert KYC verification queue record
    if (workerProfileId) {
      await supabase.from('verifications').insert({
        worker_profile_id: workerProfileId,
        document_type: documentType,
        document_number: cleanNid,
        document_file_url: frontImageUrl || 'https://skavia-bd.vercel.app/images/nid-placeholder.png',
        status: 'Pending',
        review_notes: `NID: ${cleanNid} | Name: ${fullName || 'Citizen'} | DOB: ${dateOfBirth || 'N/A'}`,
      });
    }

    return NextResponse.json({
      success: true,
      status: 'pending',
      message: 'NID submitted successfully. Our compliance team will review your verification.',
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : 'Internal Server Error';
    return NextResponse.json({ error: msg }, { status: 500 });
  }
}
