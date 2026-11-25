export interface PublicServiceDetail {
  slug: string;
  nameEn: string;
  nameBn: string;
  branchCode: 'HOME' | 'TECH' | 'AGRI' | 'LOGI' | 'DIGI' | 'BIZ' | 'CONS' | 'EVNT';
  branchNameEn: string;
  branchNameBn: string;
  categoryNameEn: string;
  categoryNameBn: string;
  priceRangeEn: string;
  priceRangeBn: string;
  basePriceBdt: number;
  slaEn: string;
  slaBn: string;
  summaryEn: string;
  summaryBn: string;
  featuresEn: string[];
  featuresBn: string[];
  toolsEn: string[];
  toolsBn: string[];
  processStepsEn: Array<{ title: string; desc: string }>;
  processStepsBn: Array<{ title: string; desc: string }>;
  safetyGuaranteeEn: string;
  safetyGuaranteeBn: string;
}

// Public services catalog definition. Kept clean and empty on fresh environments.
// Services and rate packages will be populated dynamically from database or verified publications.
export const PUBLIC_SERVICES: PublicServiceDetail[] = [];
