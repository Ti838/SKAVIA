import { createHash, X509Certificate } from 'node:crypto';
import { inflateRawSync } from 'node:zlib';

export class ApkInspectionError extends Error {
  public readonly statusCode: number;
  public readonly code: string;

  constructor(code: string, message: string, statusCode = 400) {
    super(message);
    this.name = 'ApkInspectionError';
    this.code = code;
    this.statusCode = statusCode;
  }
}

export interface InspectedApkMetadata {
  packageName: string;
  versionName: string;
  buildNumber: number;
  minSdkVersion: number | null;
  targetSdkVersion: number | null;
  fileSizeBytes: number;
  sha256Checksum: string;
  signingCertSha256: string | null;
  signingCertSubject: string | null;
  signingSchemes: string[];
  hasAndroidManifest: boolean;
  hasDex: boolean;
}

interface ZipCentralEntry {
  fileName: string;
  compressionMethod: number;
  compressedSize: number;
  uncompressedSize: number;
  localHeaderOffset: number;
}

const ZIP_EOCD_SIG = 0x06054b50;
const ZIP_CD_SIG = 0x02014b50;
const ZIP_LFH_SIG = 0x04034b50;

const APK_SIG_BLOCK_MAGIC = 'APK Sig Block 42';
const APK_SIG_V2_ID = 0x7109871a;
const APK_SIG_V3_ID = 0xf05368c0;
const APK_SIG_V31_ID = 0x1b93ad61;

const RES_STRING_POOL_TYPE = 0x0001;
const RES_XML_TYPE = 0x0003;
const RES_XML_START_ELEMENT_TYPE = 0x0102;
const RES_XML_RESOURCE_MAP_TYPE = 0x0180;

const ATTR_ID_MIN_SDK = 0x0101020c;
const ATTR_ID_VERSION_CODE = 0x0101021b;
const ATTR_ID_VERSION_NAME = 0x0101021c;
const ATTR_ID_TARGET_SDK = 0x01010270;
const ATTR_ID_VERSION_CODE_MAJOR = 0x01010576;

function findZipEndOfCentralDirectory(buf: Buffer): {
  eocdOffset: number;
  cdEntryCount: number;
  cdOffset: number;
  cdSize: number;
} {
  if (buf.length < 22) {
    throw new ApkInspectionError('INVALID_APK_ZIP', 'File is too small to be a valid Android APK archive.');
  }

  const minOffset = Math.max(0, buf.length - 65557);
  for (let offset = buf.length - 22; offset >= minOffset; offset--) {
    if (buf.readUInt32LE(offset) === ZIP_EOCD_SIG) {
      const commentLen = buf.readUInt16LE(offset + 20);
      if (offset + 22 + commentLen === buf.length) {
        const cdEntryCount = buf.readUInt16LE(offset + 10);
        const cdSize = buf.readUInt32LE(offset + 12);
        const cdOffset = buf.readUInt32LE(offset + 16);
        if (cdOffset + cdSize > offset) {
          throw new ApkInspectionError(
            'INVALID_APK_ZIP',
            'Corrupted APK Central Directory bounds detected.'
          );
        }
        return { eocdOffset: offset, cdEntryCount, cdOffset, cdSize };
      }
    }
  }

  throw new ApkInspectionError(
    'INVALID_APK_ZIP',
    'Uploaded file does not contain a valid ZIP/APK End of Central Directory record.'
  );
}

function readCentralDirectory(
  buf: Buffer,
  cdOffset: number,
  cdSize: number,
  cdEntryCount: number
): Map<string, ZipCentralEntry> {
  const entries = new Map<string, ZipCentralEntry>();
  let pos = cdOffset;
  const cdEnd = cdOffset + cdSize;

  for (let i = 0; i < cdEntryCount && pos + 46 <= cdEnd; i++) {
    const sig = buf.readUInt32LE(pos);
    if (sig !== ZIP_CD_SIG) {
      throw new ApkInspectionError(
        'INVALID_APK_ZIP',
        `Invalid ZIP Central Directory header at offset ${pos}.`
      );
    }

    const compressionMethod = buf.readUInt16LE(pos + 10);
    const compressedSize = buf.readUInt32LE(pos + 20);
    const uncompressedSize = buf.readUInt32LE(pos + 24);
    const fileNameLen = buf.readUInt16LE(pos + 28);
    const extraLen = buf.readUInt16LE(pos + 30);
    const commentLen = buf.readUInt16LE(pos + 32);
    const localHeaderOffset = buf.readUInt32LE(pos + 42);

    const nameStart = pos + 46;
    const nameEnd = nameStart + fileNameLen;
    if (nameEnd > cdEnd) {
      throw new ApkInspectionError('INVALID_APK_ZIP', 'Truncated ZIP Central Directory entry.');
    }

    const fileName = buf.toString('utf8', nameStart, nameEnd);
    entries.set(fileName, {
      fileName,
      compressionMethod,
      compressedSize,
      uncompressedSize,
      localHeaderOffset,
    });

    pos = nameEnd + extraLen + commentLen;
  }

  return entries;
}

function extractZipEntry(buf: Buffer, entry: ZipCentralEntry): Buffer {
  const off = entry.localHeaderOffset;
  if (off + 30 > buf.length || buf.readUInt32LE(off) !== ZIP_LFH_SIG) {
    throw new ApkInspectionError(
      'INVALID_APK_ZIP',
      `Invalid Local File Header for ${entry.fileName}.`
    );
  }

  const nameLen = buf.readUInt16LE(off + 26);
  const extraLen = buf.readUInt16LE(off + 28);
  const dataStart = off + 30 + nameLen + extraLen;
  const dataEnd = dataStart + entry.compressedSize;
  if (dataEnd > buf.length) {
    throw new ApkInspectionError(
      'INVALID_APK_ZIP',
      `Entry ${entry.fileName} extends past EOF.`
    );
  }

  const payload = buf.subarray(dataStart, dataEnd);
  if (entry.compressionMethod === 0) {
    return payload;
  }
  if (entry.compressionMethod === 8) {
    try {
      return inflateRawSync(payload);
    } catch {
      throw new ApkInspectionError(
        'INVALID_APK_ZIP',
        `Failed decompressing ${entry.fileName} inside APK.`
      );
    }
  }
  throw new ApkInspectionError(
    'UNSUPPORTED_APK_COMPRESSION',
    `Unsupported compression method ${entry.compressionMethod} for ${entry.fileName}.`
  );
}

function decodeAxmlStringPool(buf: Buffer, chunkOffset: number, headerSize: number): string[] {
  const stringCount = buf.readUInt32LE(chunkOffset + 8);
  const flags = buf.readUInt32LE(chunkOffset + 16);
  const stringsStart = buf.readUInt32LE(chunkOffset + 20);
  const isUtf8 = (flags & 0x0100) !== 0;

  const dataBase = chunkOffset + stringsStart;
  const offsetsBase = chunkOffset + headerSize;
  const strings: string[] = [];

  for (let i = 0; i < stringCount; i++) {
    const relOff = buf.readUInt32LE(offsetsBase + i * 4);
    let ptr = dataBase + relOff;

    if (ptr >= buf.length) {
      strings.push('');
      continue;
    }

    if (isUtf8) {
      // Skip UTF-16 character length varint (1 or 2 bytes)
      const u16First = buf[ptr++] ?? 0;
      if ((u16First & 0x80) !== 0) {
        ptr++;
      }
      // Read UTF-8 byte length varint (1 or 2 bytes)
      const b0 = buf[ptr++] ?? 0;
      const byteLen =
        (b0 & 0x80) !== 0 ? ((b0 & 0x7f) << 8) | (buf[ptr++] ?? 0) : b0;
      const safeEnd = Math.min(buf.length, ptr + byteLen);
      strings.push(buf.toString('utf8', ptr, safeEnd));
    } else {
      const u0 = buf.readUInt16LE(ptr);
      ptr += 2;
      let charLen = u0;
      if ((u0 & 0x8000) !== 0) {
        const u1 = buf.readUInt16LE(ptr);
        ptr += 2;
        charLen = ((u0 & 0x7fff) << 16) | u1;
      }
      const safeEnd = Math.min(buf.length, ptr + charLen * 2);
      strings.push(buf.toString('utf16le', ptr, safeEnd));
    }
  }

  return strings;
}

function parseBinaryAndroidManifest(axml: Buffer): {
  packageName: string;
  versionName: string;
  buildNumber: number;
  minSdkVersion: number | null;
  targetSdkVersion: number | null;
} {
  if (axml.length < 8 || axml.readUInt16LE(0) !== RES_XML_TYPE) {
    throw new ApkInspectionError(
      'INVALID_ANDROID_MANIFEST',
      'AndroidManifest.xml is not a valid compiled binary AXML resource.'
    );
  }

  const rootHeaderSize = axml.readUInt16LE(2);
  let strings: string[] = [];
  let resourceIds: number[] = [];

  let packageName = '';
  let versionName = '';
  let versionCode = 0;
  let versionCodeMajor = 0;
  let minSdkVersion: number | null = null;
  let targetSdkVersion: number | null = null;

  let pos = rootHeaderSize;
  while (pos + 8 <= axml.length) {
    const chunkType = axml.readUInt16LE(pos);
    const chunkHeaderSize = axml.readUInt16LE(pos + 2);
    const chunkSize = axml.readUInt32LE(pos + 4);
    if (chunkSize < 8 || pos + chunkSize > axml.length) break;

    if (chunkType === RES_STRING_POOL_TYPE) {
      strings = decodeAxmlStringPool(axml, pos, chunkHeaderSize);
    } else if (chunkType === RES_XML_RESOURCE_MAP_TYPE) {
      const count = Math.floor((chunkSize - chunkHeaderSize) / 4);
      resourceIds = [];
      for (let i = 0; i < count; i++) {
        resourceIds.push(axml.readUInt32LE(pos + chunkHeaderSize + i * 4));
      }
    } else if (chunkType === RES_XML_START_ELEMENT_TYPE) {
      const attrExtBase = pos + chunkHeaderSize;
      if (attrExtBase + 20 <= pos + chunkSize) {
        const tagIdx = axml.readInt32LE(attrExtBase + 4);
        const tagName =
          tagIdx >= 0 && tagIdx < strings.length ? (strings[tagIdx] ?? '') : '';
        const attrStart = axml.readUInt16LE(attrExtBase + 8);
        const attrSize = axml.readUInt16LE(attrExtBase + 10);
        const attrCount = axml.readUInt16LE(attrExtBase + 12);

        const attrsBase = attrExtBase + attrStart;
        for (let i = 0; i < attrCount; i++) {
          const entryPos = attrsBase + i * attrSize;
          if (entryPos + 20 > pos + chunkSize) break;

          const nameIdx = axml.readInt32LE(entryPos + 4);
          const rawValIdx = axml.readInt32LE(entryPos + 8);
          const dataType = axml[entryPos + 15] ?? 0;
          const data = axml.readUInt32LE(entryPos + 16);

          const attrName =
            nameIdx >= 0 && nameIdx < strings.length ? (strings[nameIdx] ?? '') : '';
          const resId =
            nameIdx >= 0 && nameIdx < resourceIds.length ? (resourceIds[nameIdx] ?? 0) : 0;

          const asString = (): string => {
            if (dataType === 0x03 && data < strings.length) return strings[data] ?? '';
            if (rawValIdx >= 0 && rawValIdx < strings.length) return strings[rawValIdx] ?? '';
            return '';
          };
          const asInt = (): number => {
            if (dataType === 0x10 || dataType === 0x11) {
              return axml.readInt32LE(entryPos + 16);
            }
            const parsed = Number(asString());
            return Number.isFinite(parsed) ? parsed : 0;
          };

          if (tagName === 'manifest') {
            if (attrName === 'package' && !packageName) {
              packageName = asString().trim();
            } else if (resId === ATTR_ID_VERSION_CODE || attrName === 'versionCode') {
              versionCode = asInt();
            } else if (resId === ATTR_ID_VERSION_CODE_MAJOR || attrName === 'versionCodeMajor') {
              versionCodeMajor = asInt();
            } else if (resId === ATTR_ID_VERSION_NAME || attrName === 'versionName') {
              versionName = asString().trim();
            }
          } else if (tagName === 'uses-sdk') {
            if (resId === ATTR_ID_MIN_SDK || attrName === 'minSdkVersion') {
              const v = asInt();
              if (v > 0) minSdkVersion = v;
            } else if (resId === ATTR_ID_TARGET_SDK || attrName === 'targetSdkVersion') {
              const v = asInt();
              if (v > 0) targetSdkVersion = v;
            }
          }
        }
      }
    }

    pos += chunkSize;
  }

  const combinedBuild =
    versionCodeMajor > 0 ? versionCodeMajor * 2 ** 32 + (versionCode >>> 0) : versionCode;

  if (!packageName || combinedBuild <= 0 || !versionName) {
    throw new ApkInspectionError(
      'INVALID_ANDROID_MANIFEST',
      'AndroidManifest.xml is missing required packageName, versionCode, or versionName attributes.'
    );
  }

  return {
    packageName,
    versionName,
    buildNumber: combinedBuild,
    minSdkVersion,
    targetSdkVersion,
  };
}

function parseApkSigningBlock(
  buf: Buffer,
  cdOffset: number
): {
  signingCertSha256: string | null;
  signingCertSubject: string | null;
  schemes: string[];
} {
  const schemes: string[] = [];
  if (cdOffset < 32) {
    return { signingCertSha256: null, signingCertSubject: null, schemes };
  }

  const magicSlice = buf.subarray(cdOffset - 16, cdOffset);
  if (magicSlice.toString('ascii') !== APK_SIG_BLOCK_MAGIC) {
    return { signingCertSha256: null, signingCertSubject: null, schemes };
  }

  const footerSize = Number(buf.readBigUInt64LE(cdOffset - 24));
  const blockStart = cdOffset - footerSize - 8;
  if (blockStart < 0 || blockStart + 24 >= cdOffset) {
    throw new ApkInspectionError(
      'INVALID_APK_SIGNATURE_BLOCK',
      'APK Signing Block length header is corrupted.'
    );
  }

  const headerSize = Number(buf.readBigUInt64LE(blockStart));
  if (headerSize !== footerSize) {
    throw new ApkInspectionError(
      'INVALID_APK_SIGNATURE_BLOCK',
      'APK Signing Block header/footer sizes do not match.'
    );
  }

  let certSha256: string | null = null;
  let certSubject: string | null = null;

  let ptr = blockStart + 8;
  const pairsEnd = cdOffset - 24;
  while (ptr + 12 <= pairsEnd) {
    const pairLen = Number(buf.readBigUInt64LE(ptr));
    ptr += 8;
    if (pairLen < 4 || ptr + pairLen > pairsEnd) break;

    const pairId = buf.readUInt32LE(ptr);
    const val = buf.subarray(ptr + 4, ptr + pairLen);
    ptr += pairLen;

    const schemeName =
      pairId === APK_SIG_V2_ID
        ? 'v2'
        : pairId === APK_SIG_V3_ID
          ? 'v3'
          : pairId === APK_SIG_V31_ID
            ? 'v3.1'
            : null;

    if (!schemeName) continue;
    schemes.push(schemeName);

    // Extract first signer primary X.509 certificate
    if (!certSha256 && val.length >= 24) {
      try {
        const signersLen = val.readUInt32LE(0);
        if (signersLen + 4 <= val.length) {
          const signerLen = val.readUInt32LE(4);
          if (signerLen + 8 <= val.length) {
            const signedDataLen = val.readUInt32LE(8);
            const signedData = val.subarray(12, 12 + signedDataLen);
            if (signedData.length >= 12) {
              const digestsLen = signedData.readUInt32LE(0);
              const certsLenPos = 4 + digestsLen;
              if (certsLenPos + 8 <= signedData.length) {
                const certsLen = signedData.readUInt32LE(certsLenPos);
                const firstCertLen = signedData.readUInt32LE(certsLenPos + 4);
                const certStart = certsLenPos + 8;
                const certEnd = certStart + firstCertLen;
                if (certsLen >= firstCertLen + 4 && certEnd <= signedData.length) {
                  const certDer = signedData.subarray(certStart, certEnd);
                  const parsed = new X509Certificate(certDer);
                  certSha256 = createHash('sha256').update(certDer).digest('hex').toLowerCase();
                  certSubject = parsed.subject.replace(/\n+/g, ', ').trim() || null;
                }
              }
            }
          }
        }
      } catch (err) {
        throw new ApkInspectionError(
          'INVALID_APK_CERTIFICATE',
          `APK Signing Block (${schemeName}) contains an invalid X.509 signing certificate: ${
            err instanceof Error ? err.message : 'parse failure'
          }`
        );
      }
    }
  }

  return {
    signingCertSha256: certSha256,
    signingCertSubject: certSubject,
    schemes,
  };
}

/**
 * Cryptographically inspects a raw Android APK buffer without trusting client metadata.
 * Extracts:
 *  - Exact byte size & full-file SHA-256 digest
 *  - Binary AndroidManifest.xml packageName, versionCode, versionName, minSdkVersion, targetSdkVersion
 *  - APK Signature Scheme v2/v3 X.509 certificate SHA-256 fingerprint & v1 JAR signatures
 */
export function inspectApkBuffer(buf: Buffer): InspectedApkMetadata {
  if (!Buffer.isBuffer(buf) || buf.length === 0) {
    throw new ApkInspectionError('EMPTY_APK', 'Uploaded APK buffer is empty.');
  }

  const sha256Checksum = createHash('sha256').update(buf).digest('hex').toLowerCase();
  const { cdEntryCount, cdOffset, cdSize } = findZipEndOfCentralDirectory(buf);
  const entries = readCentralDirectory(buf, cdOffset, cdSize, cdEntryCount);

  const manifestEntry = entries.get('AndroidManifest.xml');
  if (!manifestEntry) {
    throw new ApkInspectionError(
      'MISSING_ANDROID_MANIFEST',
      'Uploaded APK archive does not contain AndroidManifest.xml.'
    );
  }

  const hasDex =
    entries.has('classes.dex') ||
    Array.from(entries.keys()).some((k) => /^classes\d*\.dex$/.test(k));

  const manifestRaw = extractZipEntry(buf, manifestEntry);
  const manifest = parseBinaryAndroidManifest(manifestRaw);

  const sigBlock = parseApkSigningBlock(buf, cdOffset);
  const hasV1JarSig = Array.from(entries.keys()).some((k) =>
    /^META-INF\/.+\.(RSA|DSA|EC)$/i.test(k)
  );
  const signingSchemes = Array.from(
    new Set([...(hasV1JarSig ? ['v1'] : []), ...sigBlock.schemes])
  );

  return {
    packageName: manifest.packageName,
    versionName: manifest.versionName,
    buildNumber: manifest.buildNumber,
    minSdkVersion: manifest.minSdkVersion,
    targetSdkVersion: manifest.targetSdkVersion,
    fileSizeBytes: buf.length,
    sha256Checksum,
    signingCertSha256: sigBlock.signingCertSha256,
    signingCertSubject: sigBlock.signingCertSubject,
    signingSchemes,
    hasAndroidManifest: true,
    hasDex,
  };
}
