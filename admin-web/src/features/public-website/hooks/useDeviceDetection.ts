'use client';

import { useEffect, useState } from 'react';

export type DeviceCategory = 'Mobile' | 'Tablet' | 'Desktop' | 'Unknown';
export type ApkRecommendation = 'arm64' | 'armv7' | 'none';
export type CompatibilityStatus =
  | 'fully_compatible'
  | 'legacy_compatible'
  | 'incompatible_ios'
  | 'desktop_transfer';

export interface DeviceTelemetry {
  isLoaded: boolean;
  os: 'Android' | 'iOS' | 'Windows' | 'macOS' | 'Linux' | 'Unknown';
  osVersion: string | null;
  isAndroid: boolean;
  isIOS: boolean;
  isDesktop: boolean;
  browser: string;
  browserVersion: string;
  deviceCategory: DeviceCategory;
  screen: {
    width: number;
    height: number;
    availWidth: number;
    availHeight: number;
    dpr: number;
    colorDepth: number;
  };
  hardware: {
    cpuCores: number | null;
    deviceMemoryGb: number | null;
    maxTouchPoints: number;
  };
  network: {
    online: boolean;
    effectiveType: '4g' | '3g' | '2g' | 'slow-2g' | 'Unknown';
    downlinkMbps: number | null;
    rttMs: number | null;
    saveData: boolean | null;
  };
  pwaFeatures: {
    serviceWorker: boolean;
    webAuthn: boolean;
    notifications: boolean;
    storageEstimate: boolean;
  };
  recommendedApk: ApkRecommendation;
  compatibilityStatus: CompatibilityStatus;
  estimatedAndroidVersion: number | null;
  isAndroidVersionSupported: boolean | null; // minSdk is 24 (Android 7.0+)
}

const INITIAL_TELEMETRY: DeviceTelemetry = {
  isLoaded: false,
  os: 'Unknown',
  osVersion: null,
  isAndroid: false,
  isIOS: false,
  isDesktop: false,
  browser: 'Unknown',
  browserVersion: '',
  deviceCategory: 'Unknown',
  screen: {
    width: 0,
    height: 0,
    availWidth: 0,
    availHeight: 0,
    dpr: 1,
    colorDepth: 24,
  },
  hardware: {
    cpuCores: null,
    deviceMemoryGb: null,
    maxTouchPoints: 0,
  },
  network: {
    online: true,
    effectiveType: 'Unknown',
    downlinkMbps: null,
    rttMs: null,
    saveData: null,
  },
  pwaFeatures: {
    serviceWorker: false,
    webAuthn: false,
    notifications: false,
    storageEstimate: false,
  },
  recommendedApk: 'arm64',
  compatibilityStatus: 'fully_compatible',
  estimatedAndroidVersion: null,
  isAndroidVersionSupported: null,
};

export function useDeviceDetection(): DeviceTelemetry {
  const [telemetry, setTelemetry] = useState<DeviceTelemetry>(INITIAL_TELEMETRY);

  useEffect(() => {
    if (typeof window === 'undefined' || typeof navigator === 'undefined') {
      return;
    }

    const ua = navigator.userAgent || '';
    const uaLower = ua.toLowerCase();

    // 1. Operating System Detection
    let os: DeviceTelemetry['os'] = 'Unknown';
    let osVersion: string | null = null;
    let estimatedAndroidVersion: number | null = null;

    if (/android/i.test(ua)) {
      os = 'Android';
      const match = ua.match(/android\s+([0-9\.]+)/i);
      if (match && match[1]) {
        osVersion = match[1];
        const majorStr = match[1].split('.')[0] || '0';
        const major = parseInt(majorStr, 10);
        if (!isNaN(major)) {
          estimatedAndroidVersion = major;
        }
      }
    } else if (/iphone|ipad|ipod/i.test(ua) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1)) {
      os = 'iOS';
      const match = ua.match(/os\s+([0-9_]+)/i);
      if (match && match[1]) {
        osVersion = match[1].replace(/_/g, '.');
      }
    } else if (/windows/i.test(ua)) {
      os = 'Windows';
      if (/windows nt 10\.0/i.test(ua)) osVersion = '10/11';
      else if (/windows nt 6\.3/i.test(ua)) osVersion = '8.1';
      else if (/windows nt 6\.1/i.test(ua)) osVersion = '7';
    } else if (/macintosh|mac os x/i.test(ua)) {
      os = 'macOS';
      const match = ua.match(/mac os x\s+([0-9_\.]+)/i);
      if (match && match[1]) osVersion = match[1].replace(/_/g, '.');
    } else if (/linux/i.test(ua)) {
      os = 'Linux';
    }

    const isAndroid = os === 'Android';
    const isIOS = os === 'iOS';
    const isDesktop = os === 'Windows' || os === 'macOS' || os === 'Linux';

    // Check minSdk compatibility: Android 7.0+ (API 24+)
    const isAndroidVersionSupported =
      isAndroid && estimatedAndroidVersion !== null
        ? estimatedAndroidVersion >= 7
        : isAndroid ? true : null;

    // 2. Browser & Browser Version Detection
    let browser = 'Unknown';
    let browserVersion = '';

    if (/edg\//i.test(ua)) {
      browser = 'Microsoft Edge';
      browserVersion = ua.match(/edg\/([0-9\.]+)/i)?.[1] || '';
    } else if (/samsungbrowser/i.test(ua)) {
      browser = 'Samsung Internet';
      browserVersion = ua.match(/samsungbrowser\/([0-9\.]+)/i)?.[1] || '';
    } else if (/chrome|crios/i.test(ua)) {
      browser = 'Google Chrome';
      browserVersion = ua.match(/(?:chrome|crios)\/([0-9\.]+)/i)?.[1] || '';
    } else if (/firefox|fxios/i.test(ua)) {
      browser = 'Mozilla Firefox';
      browserVersion = ua.match(/(?:firefox|fxios)\/([0-9\.]+)/i)?.[1] || '';
    } else if (/safari/i.test(ua) && !/chrome/i.test(ua)) {
      browser = 'Apple Safari';
      browserVersion = ua.match(/version\/([0-9\.]+)/i)?.[1] || '';
    } else if (/opera|opr/i.test(ua)) {
      browser = 'Opera';
      browserVersion = ua.match(/(?:opera|opr)\/([0-9\.]+)/i)?.[1] || '';
    }

    // 3. Device Category
    let deviceCategory: DeviceCategory = 'Desktop';
    const touchPoints = navigator.maxTouchPoints || 0;
    const isMobileWidth = window.innerWidth <= 768;

    if (isAndroid || isIOS) {
      if (window.innerWidth >= 768 && window.innerHeight >= 900) {
        deviceCategory = 'Tablet';
      } else {
        deviceCategory = 'Mobile';
      }
    } else if (touchPoints > 0 && isMobileWidth) {
      deviceCategory = 'Mobile';
    } else if (touchPoints > 0 && window.innerWidth >= 768 && window.innerWidth <= 1024) {
      deviceCategory = 'Tablet';
    } else {
      deviceCategory = 'Desktop';
    }

    // 4. Screen Telemetry
    const screenInfo = {
      width: window.screen?.width || window.innerWidth,
      height: window.screen?.height || window.innerHeight,
      availWidth: window.screen?.availWidth || window.innerWidth,
      availHeight: window.screen?.availHeight || window.innerHeight,
      dpr: window.devicePixelRatio || 1,
      colorDepth: window.screen?.colorDepth || 24,
    };

    // 5. Hardware Info (where supported)
    const cpuCores = navigator.hardwareConcurrency || null;
    // deviceMemory is a Chromium-only specification (returns RAM in GB: 0.25, 0.5, 1, 2, 4, 8)
    const navAny = navigator as unknown as { deviceMemory?: number };
    const deviceMemoryGb = typeof navAny.deviceMemory === 'number' ? navAny.deviceMemory : null;

    // 6. Network Connectivity (Network Information API)
    const connAny = (navigator as unknown as {
      connection?: {
        effectiveType?: string;
        downlink?: number;
        rtt?: number;
        saveData?: boolean;
      };
    }).connection;

    let effectiveType: DeviceTelemetry['network']['effectiveType'] = 'Unknown';
    if (connAny?.effectiveType) {
      if (['4g', '3g', '2g', 'slow-2g'].includes(connAny.effectiveType)) {
        effectiveType = connAny.effectiveType as DeviceTelemetry['network']['effectiveType'];
      }
    }

    const networkInfo = {
      online: navigator.onLine,
      effectiveType,
      downlinkMbps: typeof connAny?.downlink === 'number' ? connAny.downlink : null,
      rttMs: typeof connAny?.rtt === 'number' ? connAny.rtt : null,
      saveData: typeof connAny?.saveData === 'boolean' ? connAny.saveData : null,
    };

    // 7. PWA and Web Standards
    const pwaFeatures = {
      serviceWorker: 'serviceWorker' in navigator,
      webAuthn: 'credentials' in navigator && typeof PublicKeyCredential !== 'undefined',
      notifications: 'Notification' in window,
      storageEstimate: 'storage' in navigator && typeof navigator.storage?.estimate === 'function',
    };

    // 8. Architecture & APK Recommendation
    let recommendedApk: ApkRecommendation = 'arm64';
    let compatibilityStatus: CompatibilityStatus = 'fully_compatible';

    if (isIOS) {
      recommendedApk = 'none';
      compatibilityStatus = 'incompatible_ios';
    } else if (isAndroid) {
      // Check for explicit 32-bit architecture hints
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

    setTelemetry({
      isLoaded: true,
      os,
      osVersion,
      isAndroid,
      isIOS,
      isDesktop,
      browser,
      browserVersion,
      deviceCategory,
      screen: screenInfo,
      hardware: {
        cpuCores,
        deviceMemoryGb,
        maxTouchPoints: touchPoints,
      },
      network: networkInfo,
      pwaFeatures,
      recommendedApk,
      compatibilityStatus,
      estimatedAndroidVersion,
      isAndroidVersionSupported,
    });
  }, []);

  return telemetry;
}
