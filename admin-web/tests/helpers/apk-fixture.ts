import { createHash } from 'node:crypto';
import { deflateRawSync } from 'node:zlib';

export const TEST_CERT_A_DER = Buffer.from(
  'MIIC/TCCAeWgAwIBAgIITMDFQOY6yIEwDQYJKoZIhvcNAQELBQAwLTEPMA0GA1UEChMGU0tBVklBMRowGAYDVQQDExFTS0FWSUEgVGVzdCBLZXkgQTAeFw0yNjExMTIxNjE5MzFaFw0zNjExMDkxNjE5MzFaMC0xDzANBgNVBAoTBlNLQVZJQTEaMBgGA1UEAxMRU0tBVklBIFRlc3QgS2V5IEEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCk8qcHZB6zLjmHXmJYhIFLuK0N3OjzVY3en4UUG9vT42/TnINlQjU1EhD7LW8z53HO9KehtuA+rssuytZuVdd6cqixu5EHIihCl+BLs+5/2Tl9bfyPLrKqJSC54wtj8iQAGfWofbTcOS3mD6kqxe+EFwg+UteuNxFgIGts8+Zv2qHNPhahdmqMOs0f0SYU3n7oY28Op2LN4Wq/dNREveUn92yyT3+l9MApSv63M5nQRcnLPjLwndOSDpYYB4FzBF/7VW25jW2Kpi4zIb2fnU19xK48h2NoO5G4Quw/4DuQLBnrdUccYRKq1eEvbZQWaaWcunEUObz2KN6c4Sve4RFRAgMBAAGjITAfMB0GA1UdDgQWBBT6XzwmtnidTdPy/jgc3ZAqUIGwgDANBgkqhkiG9w0BAQsFAAOCAQEAgHcPnZEoLudfTw9kq4fgNmRnwzhMUEfZmdpe0I5+xqWVMFZQ7T3zStdi6JkEBOTEIDpNdVe/uhxOxeUAY8rgX/8L7S6bl4QzCK7wqoWYeH6b7F6AyqmPwWKNUdTwHzfXovukFFf89J8oW9ZfgFRBcfHqRGb2/2hkber4VnxvROCOQf4VQGCWkMEae/tWXbMNcswJ2L5r/FhI+0RvM6qVFnHyKu94GaavH34BYnCeJwPFbvTMkW46KOqZVb94KB6R7rax36g8uMzrkYFI5wO8QxByPRNOLyxV6Gp7WdkzzpYsxgeIFrewHtsHeb4qc/CMTgpbXYW3LFqBZBXJ4IEomA==',
  'base64'
);

export const TEST_CERT_B_DER = Buffer.from(
  'MIIC7zCCAdegAwIBAgIIegIhvdLl/AcwDQYJKoZIhvcNAQELBQAwJjEOMAwGA1UEChMFT3RoZXIxFDASBgNVBAMTC1dyb25nIEtleSBCMB4XDTI2MTExMjE2MTkzMloXDTM2MTEwOTE2MTkzMlowJjEOMAwGA1UEChMFT3RoZXIxFDASBgNVBAMTC1dyb25nIEtleSBCMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApDrswz0lIJM+Nmio1BbPQAOZB2F1tmBZKT4g3XsyxDgwqD0A5uNZ1jNK8wO0VhCMuyA0Q4llzGwtcoB8lUjBYnY4tfhTectHxQIC9WVZ6MZIDADYUI2SMhYKveyeVCd8YeJZIwk3EPKXjpdFBREsTFyTp3Gw7I8KeEqEuG6A+y1SbxX/FSPX8aSgxKOBtUbGSrRyOUCqivuV+nuHkxFaXbruNXKbQtsg2gExu1Vb4HYCq82c7X/BgRVnnO9nQy1j9ojrpz7G7fKRy54ExcdexVvU1BsRjSie7MEJPNW+/M5db663fUWp5cHWuZyAzl6GYykjhnBHDz+RngLgLT8ZoQIDAQABoyEwHzAdBgNVHQ4EFgQUa5Ug5vjh98WQWicKrsS55X6PhUQwDQYJKoZIhvcNAQELBQADggEBAGkDAr4TGaLTcsOIvYl3nZOYkDrZR8drut+e5AbMvC6twfWYNE2D84jY5PnoNXFqNB58+U410GQWoddoZeUP2+XdLhFwcVzj255TFQz5v7x+AWSU8KzrcGSQorDH27HlFEapeLmFhPphNLhtaz3pC+j5aooIbPyFnjYoAJDllsmKVF4MehwSuk3sbHOBidjYJ38j5t3svUbBQXRyN1MHi/KuEBD7WR6JGUnv0MH3990kHcl8SSjGXXBEmsNssCXceLCNNRrezsPD9+2OZ4CSgoh+q2drWcJcnKBsPG1ODvFK1xINed27LWGxSIqKdkAMlTMOAudN15x23al7TLXXFO8=',
  'base64'
);

export const TEST_CERT_A_SHA256 = createHash('sha256')
  .update(TEST_CERT_A_DER)
  .digest('hex')
  .toLowerCase();

export const TEST_CERT_B_SHA256 = createHash('sha256')
  .update(TEST_CERT_B_DER)
  .digest('hex')
  .toLowerCase();

function buildAxmlUtf8Manifest(opts: {
  packageName: string;
  versionName: string;
  buildNumber: number;
  minSdkVersion: number;
  targetSdkVersion: number;
}): Buffer {
  // Resource map order matches first N string pool entries
  const poolStrings = [
    'versionCode', // 0
    'versionName', // 1
    'minSdkVersion', // 2
    'targetSdkVersion', // 3
    'package', // 4
    'manifest', // 5
    'uses-sdk', // 6
    opts.packageName, // 7
    opts.versionName, // 8
    'http://schemas.android.com/apk/res/android', // 9
  ];

  const encodedStrs = poolStrings.map((s) => {
    const utf8 = Buffer.from(s, 'utf8');
    const rec = Buffer.alloc(2 + utf8.length + 1);
    rec[0] = s.length;
    rec[1] = utf8.length;
    utf8.copy(rec, 2);
    rec[2 + utf8.length] = 0;
    return rec;
  });

  const offsets: number[] = [];
  let strCursor = 0;
  for (const r of encodedStrs) {
    offsets.push(strCursor);
    strCursor += r.length;
  }
  const strData = Buffer.concat(encodedStrs);
  const pad = (4 - (strData.length % 4)) % 4;
  const spHeaderSize = 28;
  const spOffsetsLen = poolStrings.length * 4;
  const stringsStart = spHeaderSize + spOffsetsLen;
  const spSize = stringsStart + strData.length + pad;
  const spChunk = Buffer.alloc(spSize);
  spChunk.writeUInt16LE(0x0001, 0);
  spChunk.writeUInt16LE(spHeaderSize, 2);
  spChunk.writeUInt32LE(spSize, 4);
  spChunk.writeUInt32LE(poolStrings.length, 8);
  spChunk.writeUInt32LE(0, 12);
  spChunk.writeUInt32LE(0x0100, 16); // UTF-8
  spChunk.writeUInt32LE(stringsStart, 20);
  spChunk.writeUInt32LE(0, 24);
  for (let i = 0; i < offsets.length; i++) {
    spChunk.writeUInt32LE(offsets[i] ?? 0, spHeaderSize + i * 4);
  }
  strData.copy(spChunk, stringsStart);

  // Resource map chunk for attribute IDs
  const resIds = [0x0101021b, 0x0101021c, 0x0101020c, 0x01010270];
  const rmChunk = Buffer.alloc(8 + resIds.length * 4);
  rmChunk.writeUInt16LE(0x0180, 0);
  rmChunk.writeUInt16LE(8, 2);
  rmChunk.writeUInt32LE(rmChunk.length, 4);
  resIds.forEach((id, idx) => rmChunk.writeUInt32LE(id, 8 + idx * 4));

  const buildStartElement = (
    tagIdx: number,
    attrs: Array<{ nsIdx: number; nameIdx: number; rawValIdx: number; dataType: number; data: number }>
  ): Buffer => {
    const size = 16 + 20 + attrs.length * 20;
    const b = Buffer.alloc(size);
    b.writeUInt16LE(0x0102, 0);
    b.writeUInt16LE(16, 2);
    b.writeUInt32LE(size, 4);
    b.writeUInt32LE(1, 8);
    b.writeInt32LE(-1, 12);
    b.writeInt32LE(-1, 16);
    b.writeInt32LE(tagIdx, 20);
    b.writeUInt16LE(20, 24);
    b.writeUInt16LE(20, 26);
    b.writeUInt16LE(attrs.length, 28);
    attrs.forEach((a, idx) => {
      const p = 36 + idx * 20;
      b.writeInt32LE(a.nsIdx, p);
      b.writeInt32LE(a.nameIdx, p + 4);
      b.writeInt32LE(a.rawValIdx, p + 8);
      b.writeUInt16LE(8, p + 12);
      b.writeUInt8(0, p + 14);
      b.writeUInt8(a.dataType, p + 15);
      b.writeUInt32LE(a.data >>> 0, p + 16);
    });
    return b;
  };

  const manifestElem = buildStartElement(5, [
    { nsIdx: -1, nameIdx: 4, rawValIdx: 7, dataType: 0x03, data: 7 },
    { nsIdx: 9, nameIdx: 0, rawValIdx: -1, dataType: 0x10, data: opts.buildNumber },
    { nsIdx: 9, nameIdx: 1, rawValIdx: 8, dataType: 0x03, data: 8 },
  ]);

  const usesSdkElem = buildStartElement(6, [
    { nsIdx: 9, nameIdx: 2, rawValIdx: -1, dataType: 0x10, data: opts.minSdkVersion },
    { nsIdx: 9, nameIdx: 3, rawValIdx: -1, dataType: 0x10, data: opts.targetSdkVersion },
  ]);

  const body = Buffer.concat([spChunk, rmChunk, manifestElem, usesSdkElem]);
  const rootHeader = Buffer.alloc(8);
  rootHeader.writeUInt16LE(0x0003, 0);
  rootHeader.writeUInt16LE(8, 2);
  rootHeader.writeUInt32LE(8 + body.length, 4);
  return Buffer.concat([rootHeader, body]);
}

function buildApkSigningBlock(certDer: Buffer): Buffer {
  const certLenBuf = Buffer.alloc(4);
  certLenBuf.writeUInt32LE(certDer.length, 0);
  const certsSeq = Buffer.concat([certLenBuf, certDer]);
  const certsLenBuf = Buffer.alloc(4);
  certsLenBuf.writeUInt32LE(certsSeq.length, 0);
  const digestsLenBuf = Buffer.alloc(4);
  digestsLenBuf.writeUInt32LE(0, 0);
  const signedData = Buffer.concat([digestsLenBuf, certsLenBuf, certsSeq]);

  const signedDataLenBuf = Buffer.alloc(4);
  signedDataLenBuf.writeUInt32LE(signedData.length, 0);
  const signer = Buffer.concat([signedDataLenBuf, signedData]);
  const signerLenBuf = Buffer.alloc(4);
  signerLenBuf.writeUInt32LE(signer.length, 0);
  const signersSeq = Buffer.concat([signerLenBuf, signer]);
  const signersLenBuf = Buffer.alloc(4);
  signersLenBuf.writeUInt32LE(signersSeq.length, 0);
  const v2Payload = Buffer.concat([signersLenBuf, signersSeq]);

  const pairLenBuf = Buffer.alloc(8);
  pairLenBuf.writeBigUInt64LE(BigInt(4 + v2Payload.length), 0);
  const pairIdBuf = Buffer.alloc(4);
  pairIdBuf.writeUInt32LE(0x7109871a, 0);
  const pairs = Buffer.concat([pairLenBuf, pairIdBuf, v2Payload]);

  const sizeOfBlock = BigInt(pairs.length + 24);
  const leadSize = Buffer.alloc(8);
  leadSize.writeBigUInt64LE(sizeOfBlock, 0);
  const trailSize = Buffer.alloc(8);
  trailSize.writeBigUInt64LE(sizeOfBlock, 0);
  const magic = Buffer.from('APK Sig Block 42', 'ascii');
  return Buffer.concat([leadSize, pairs, trailSize, magic]);
}

export function buildTestApkBuffer(opts?: {
  packageName?: string;
  versionName?: string;
  buildNumber?: number;
  minSdkVersion?: number;
  targetSdkVersion?: number;
  certDer?: Buffer | null;
  includeDex?: boolean;
}): Buffer {
  const manifest = buildAxmlUtf8Manifest({
    packageName: opts?.packageName ?? 'com.example.skavia',
    versionName: opts?.versionName ?? '1.0.0',
    buildNumber: opts?.buildNumber ?? 1,
    minSdkVersion: opts?.minSdkVersion ?? 23,
    targetSdkVersion: opts?.targetSdkVersion ?? 35,
  });

  const files: Array<{ name: string; raw: Buffer; compressed: Buffer; method: number }> = [
    {
      name: 'AndroidManifest.xml',
      raw: manifest,
      compressed: deflateRawSync(manifest),
      method: 8,
    },
  ];

  if (opts?.includeDex !== false) {
    const dex = Buffer.from('dex\n035\0test-payload', 'utf8');
    files.push({
      name: 'classes.dex',
      raw: dex,
      compressed: dex,
      method: 0,
    });
  }

  const localParts: Buffer[] = [];
  const cdEntries: Buffer[] = [];
  let cursor = 0;

  for (const f of files) {
    const nameBuf = Buffer.from(f.name, 'utf8');
    const lfh = Buffer.alloc(30);
    lfh.writeUInt32LE(0x04034b50, 0);
    lfh.writeUInt16LE(20, 4);
    lfh.writeUInt16LE(f.method, 8);
    lfh.writeUInt32LE(f.compressed.length, 18);
    lfh.writeUInt32LE(f.raw.length, 22);
    lfh.writeUInt16LE(nameBuf.length, 26);

    const cdh = Buffer.alloc(46);
    cdh.writeUInt32LE(0x02014b50, 0);
    cdh.writeUInt16LE(20, 4);
    cdh.writeUInt16LE(20, 6);
    cdh.writeUInt16LE(f.method, 10);
    cdh.writeUInt32LE(f.compressed.length, 20);
    cdh.writeUInt32LE(f.raw.length, 24);
    cdh.writeUInt16LE(nameBuf.length, 28);
    cdh.writeUInt32LE(cursor, 42);
    cdEntries.push(Buffer.concat([cdh, nameBuf]));

    localParts.push(lfh, nameBuf, f.compressed);
    cursor += lfh.length + nameBuf.length + f.compressed.length;
  }

  const preCd = Buffer.concat(localParts);
  const sigBlock =
    opts?.certDer === null
      ? Buffer.alloc(0)
      : buildApkSigningBlock(opts?.certDer ?? TEST_CERT_A_DER);

  const cdOffset = preCd.length + sigBlock.length;
  const cdBuf = Buffer.concat(cdEntries);

  const eocd = Buffer.alloc(22);
  eocd.writeUInt32LE(0x06054b50, 0);
  eocd.writeUInt16LE(files.length, 8);
  eocd.writeUInt16LE(files.length, 10);
  eocd.writeUInt32LE(cdBuf.length, 12);
  eocd.writeUInt32LE(cdOffset, 16);

  return Buffer.concat([preCd, sigBlock, cdBuf, eocd]);
}

