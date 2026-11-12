'use client';

import { getApps, initializeApp, type FirebaseApp } from 'firebase/app';
import {
  GoogleAuthProvider,
  TotpMultiFactorGenerator,
  createUserWithEmailAndPassword,
  getAuth,
  getMultiFactorResolver,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut,
  updateProfile,
  type MultiFactorResolver,
  type UserCredential,
} from 'firebase/auth';

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY || '',
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN || '',
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || 'skavia-113a3',
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID || '',
};

export function isFirebaseWebConfigured(): boolean {
  return Boolean(
    firebaseConfig.apiKey &&
      firebaseConfig.authDomain &&
      firebaseConfig.projectId &&
      firebaseConfig.appId
  );
}

function getFirebaseApp(): FirebaseApp {
  if (!isFirebaseWebConfigured()) {
    throw new Error(
      'Firebase Web SDK environment variables (NEXT_PUBLIC_FIREBASE_API_KEY, NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN, NEXT_PUBLIC_FIREBASE_APP_ID) are not configured.'
    );
  }
  const existing = getApps();
  const firstApp = existing[0];
  if (firstApp) return firstApp;
  return initializeApp(firebaseConfig);
}

export interface FirebaseLoginResult {
  status: 'authenticated' | 'mfa_required';
  idToken?: string;
  mfaResolver?: MultiFactorResolver;
  hintLabel?: string;
}

async function executeWithMfaSupport(
  runSignIn: () => Promise<UserCredential>
): Promise<FirebaseLoginResult> {
  const auth = getAuth(getFirebaseApp());

  try {
    const credential = await runSignIn();
    const idToken = await credential.user.getIdToken(true);
    return { status: 'authenticated', idToken };
  } catch (err: unknown) {
    const firebaseError = err as { code?: string };
    if (firebaseError?.code === 'auth/multi-factor-auth-required') {
      const resolver = getMultiFactorResolver(auth, err as never);
      const hint = resolver.hints[0];
      return {
        status: 'mfa_required',
        mfaResolver: resolver,
        hintLabel: hint?.displayName || hint?.factorId || 'Authenticator TOTP',
      };
    }
    throw err;
  }
}

export async function signInAdminWithEmail(
  email: string,
  password: string
): Promise<FirebaseLoginResult> {
  const auth = getAuth(getFirebaseApp());
  return executeWithMfaSupport(() =>
    signInWithEmailAndPassword(auth, email, password)
  );
}

export async function signInAdminWithGoogle(
  loginHintEmail?: string
): Promise<FirebaseLoginResult> {
  const auth = getAuth(getFirebaseApp());
  const provider = new GoogleAuthProvider();
  provider.setCustomParameters({
    prompt: 'select_account',
    ...(loginHintEmail ? { login_hint: loginHintEmail } : {}),
  });
  return executeWithMfaSupport(() => signInWithPopup(auth, provider));
}

export async function completeTotpMfaChallenge(
  resolver: MultiFactorResolver,
  totpCode: string
): Promise<string> {
  const hint = resolver.hints[0];
  if (!hint) {
    throw new Error('No MFA factor enrolled on this account.');
  }
  const assertion = TotpMultiFactorGenerator.assertionForSignIn(
    hint.uid,
    totpCode.trim()
  );
  const credential = await resolver.resolveSignIn(assertion);
  return credential.user.getIdToken(true);
}

export async function createInvitedAdminFirebaseAccount(params: {
  email: string;
  password: string;
  fullName: string;
}): Promise<string> {
  const auth = getAuth(getFirebaseApp());
  const credential = await createUserWithEmailAndPassword(
    auth,
    params.email,
    params.password
  );
  if (params.fullName.trim()) {
    await updateProfile(credential.user, {
      displayName: params.fullName.trim(),
    }).catch(() => undefined);
  }
  return credential.user.getIdToken(true);
}

export async function signOutFirebaseClient(): Promise<void> {
  if (!isFirebaseWebConfigured()) return;
  const auth = getAuth(getFirebaseApp());
  await signOut(auth).catch(() => {});
}
