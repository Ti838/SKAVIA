import { describe, expect, it } from 'vitest';

describe('SKAVIA Website Device Detection & APK Recommendation Logic', () => {
  function evaluateDeviceUa(ua: string) {
    const uaLower = ua.toLowerCase();
    let os: 'Android' | 'iOS' | 'Windows' | 'macOS' | 'Linux' | 'Unknown' = 'Unknown';
    let estimatedAndroidVersion: number | null = null;

    if (/android/i.test(ua)) {
      os = 'Android';
      const match = ua.match(/android\s+([0-9\.]+)/i);
      if (match && match[1]) {
        const majorStr = match[1].split('.')[0] || '0';
        const major = parseInt(majorStr, 10);
        if (!isNaN(major)) estimatedAndroidVersion = major;
      }
    } else if (/iphone|ipad|ipod/i.test(ua)) {
      os = 'iOS';
    } else if (/windows/i.test(ua)) {
      os = 'Windows';
    } else if (/macintosh|mac os x/i.test(ua)) {
      os = 'macOS';
    } else if (/linux/i.test(ua)) {
      os = 'Linux';
    }

    const isAndroid = os === 'Android';
    const isIOS = os === 'iOS';
    const isDesktop = os === 'Windows' || os === 'macOS' || os === 'Linux';

    let recommendedApk: 'arm64' | 'armv7' | 'none' = 'arm64';
    let compatibilityStatus:
      | 'fully_compatible'
      | 'legacy_compatible'
      | 'incompatible_ios'
      | 'desktop_transfer' = 'fully_compatible';

    if (isIOS) {
      recommendedApk = 'none';
      compatibilityStatus = 'incompatible_ios';
    } else if (isAndroid) {
      const is32Bit = /armv7l|armeabi/i.test(uaLower) && !/arm64|aarch64|x86_64/i.test(uaLower);
      if (is32Bit) {
        recommendedApk = 'armv7';
        compatibilityStatus = 'legacy_compatible';
      } else {
        recommendedApk = 'arm64';
        compatibilityStatus = 'fully_compatible';
      }
    } else if (isDesktop) {
      recommendedApk = 'arm64';
      compatibilityStatus = 'desktop_transfer';
    }

    const isAndroidVersionSupported =
      isAndroid && estimatedAndroidVersion !== null
        ? estimatedAndroidVersion >= 7
        : isAndroid
        ? true
        : null;

    return {
      os,
      estimatedAndroidVersion,
      isAndroidVersionSupported,
      recommendedApk,
      compatibilityStatus,
    };
  }

  it('accurately identifies modern 64-bit Android smartphones and recommends ARM64', () => {
    const pixel7Ua =
      'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36';
    const res = evaluateDeviceUa(pixel7Ua);

    expect(res.os).toBe('Android');
    expect(res.estimatedAndroidVersion).toBe(14);
    expect(res.isAndroidVersionSupported).toBe(true);
    expect(res.recommendedApk).toBe('arm64');
    expect(res.compatibilityStatus).toBe('fully_compatible');
  });

  it('accurately identifies legacy 32-bit Android phones and recommends ARMv7', () => {
    const legacy32Ua =
      'Mozilla/5.0 (Linux; U; Android 8.1.0; armv7l; SM-J260G) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Mobile Safari/537.36';
    const res = evaluateDeviceUa(legacy32Ua);

    expect(res.os).toBe('Android');
    expect(res.estimatedAndroidVersion).toBe(8);
    expect(res.isAndroidVersionSupported).toBe(true);
    expect(res.recommendedApk).toBe('armv7');
    expect(res.compatibilityStatus).toBe('legacy_compatible');
  });

  it('accurately detects Apple iPhones, flags APK incompatibility, and recommends none', () => {
    const iphoneUa =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Mobile/15E148 Safari/604.1';
    const res = evaluateDeviceUa(iphoneUa);

    expect(res.os).toBe('iOS');
    expect(res.recommendedApk).toBe('none');
    expect(res.compatibilityStatus).toBe('incompatible_ios');
  });

  it('accurately detects Desktop platforms and enables desktop transfer mode', () => {
    const winUa =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';
    const res = evaluateDeviceUa(winUa);

    expect(res.os).toBe('Windows');
    expect(res.recommendedApk).toBe('arm64');
    expect(res.compatibilityStatus).toBe('desktop_transfer');
  });

  it('flags legacy Android versions below Android 7.0 (API 24) as unsupported', () => {
    const oldAndroidUa =
      'Mozilla/5.0 (Linux; U; Android 5.1.1; Nexus 4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.133 Mobile Safari/537.36';
    const res = evaluateDeviceUa(oldAndroidUa);

    expect(res.os).toBe('Android');
    expect(res.estimatedAndroidVersion).toBe(5);
    expect(res.isAndroidVersionSupported).toBe(false);
  });
});
