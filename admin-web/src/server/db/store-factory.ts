import { getServerEnvConfig } from '../config/env';
import type { AdminRepository } from './repository';
import { SupabaseAdminRepository } from './supabase-store';

let overrideRepository: AdminRepository | null = null;

export function setTestAdminRepository(repo: AdminRepository | null): void {
  const { isTestHarness } = getServerEnvConfig();
  if (!isTestHarness) {
    throw new Error('Test repository override is forbidden outside test harness mode.');
  }
  overrideRepository = repo;
}

export function getAdminRepository(): AdminRepository {
  const cfg = getServerEnvConfig();
  if (cfg.isTestHarness && overrideRepository) {
    return overrideRepository;
  }
  return new SupabaseAdminRepository(cfg.supabaseUrl, cfg.supabaseServiceRoleKey);
}

