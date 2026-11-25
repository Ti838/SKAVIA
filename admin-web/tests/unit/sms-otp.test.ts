import { describe, expect, it } from 'vitest';
import {
  derivePhoneBridgeCredentials,
  dispatchOtpSms,
  hashOtp,
  isValidBdPhone,
  normalizeBdPhone,
  verifyOtpHash,
} from '@/server/services/sms-otp';

describe('SMS OTP Service', () => {
  it('normalizes and validates Bangladesh mobile numbers', () => {
    expect(normalizeBdPhone('01704872142')).toBe('+8801704872142');
    expect(normalizeBdPhone('8801704872142')).toBe('+8801704872142');
    expect(normalizeBdPhone('008801704872142')).toBe('+8801704872142');
    expect(normalizeBdPhone('+880 1704-872142')).toBe('+8801704872142');

    expect(isValidBdPhone('+8801704872142')).toBe(true);
    expect(isValidBdPhone('+8801204872142')).toBe(false);
    expect(isValidBdPhone('+880170487214')).toBe(false);
  });

  it('hashes and verifies OTP codes using keyed HMAC-SHA256', () => {
    const secret = 'test-secret-key-minimum-32-characters-long';
    const vid = 'vid_12345';
    const stored = hashOtp('482910', vid, secret);

    expect(stored.startsWith('sha256:')).toBe(true);
    expect(
      verifyOtpHash({
        otp: '482910',
        verificationId: vid,
        storedValue: stored,
        secret,
      })
    ).toBe(true);

    expect(
      verifyOtpHash({
        otp: '000000',
        verificationId: vid,
        storedValue: stored,
        secret,
      })
    ).toBe(false);
  });

  it('derives deterministic non-guessable bridge credentials per phone and secret', () => {
    const credsA = derivePhoneBridgeCredentials('+8801704872142', 'secret-a');
    const credsB = derivePhoneBridgeCredentials('+8801704872142', 'secret-b');

    expect(credsA.bridgeEmail).toBe('phone_8801704872142@skavia.internal');
    expect(credsA.bridgePassword).not.toBe(credsB.bridgePassword);
    expect(credsA.bridgePassword.length).toBeGreaterThanOrEqual(20);
  });

  it('defaults to in_app_demo when no SMS_PROVIDER env is configured', async () => {
    const prev = process.env.SMS_PROVIDER;
    delete process.env.SMS_PROVIDER;
    const res = await dispatchOtpSms({
      phoneNumber: '+8801704872142',
      otp: '482910',
    });
    expect(res.channel).toBe('in_app_demo');
    expect(res.provider).toBe('none');
    if (prev !== undefined) process.env.SMS_PROVIDER = prev;
  });
});
