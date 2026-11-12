'use client';

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from 'react';
import type { AdminSessionContext, BranchSummary } from '@/lib/types';
import { apiFetch, subscribeStepUpRequired } from '@/lib/api-client';
import { StepUpModal } from './StepUpModal';

interface SessionContextValue {
  session: AdminSessionContext;
  availableBranches: BranchSummary[];
  selectedBranchId: string;
  setSelectedBranchId: (branchId: string) => void;
  stepUpOpen: boolean;
  openStepUp: () => void;
  closeStepUp: () => void;
  updateStepUpExpiry: (iso: string) => void;
}

const SessionCtx = createContext<SessionContextValue | null>(null);

export function SessionProvider({
  initialSession,
  children,
}: {
  initialSession: AdminSessionContext;
  children: ReactNode;
}) {
  const [session, setSession] = useState<AdminSessionContext>(initialSession);
  const [availableBranches, setAvailableBranches] = useState<BranchSummary[]>(
    initialSession.assignedBranches
  );
  const [selectedBranchId, setSelectedBranchId] = useState<string>(() => {
    if (
      initialSession.branchScoped &&
      initialSession.assignedBranches.length === 1
    ) {
      return initialSession.assignedBranches[0]?.branch_id ?? '';
    }
    return '';
  });
  const [stepUpOpen, setStepUpOpen] = useState(false);

  useEffect(() => {
    if (
      initialSession.branchScoped ||
      !initialSession.effectivePermissions.includes('branch.view')
    ) {
      return;
    }
    let cancelled = false;
    apiFetch<{ branches: BranchSummary[] }>('/api/admin/branches')
      .then((res) => {
        if (!cancelled && Array.isArray(res.branches)) {
          setAvailableBranches(res.branches);
        }
      })
      .catch(() => undefined);

    return () => {
      cancelled = true;
    };
  }, [initialSession.branchScoped, initialSession.effectivePermissions]);

  useEffect(() => {
    return subscribeStepUpRequired(() => {
      setStepUpOpen(true);
    });
  }, []);

  const openStepUp = useCallback(() => setStepUpOpen(true), []);
  const closeStepUp = useCallback(() => setStepUpOpen(false), []);
  const updateStepUpExpiry = useCallback((iso: string) => {
    setSession((prev) => ({ ...prev, stepUpExpiresAt: iso }));
    setStepUpOpen(false);
  }, []);

  return (
    <SessionCtx.Provider
      value={{
        session,
        availableBranches,
        selectedBranchId,
        setSelectedBranchId,
        stepUpOpen,
        openStepUp,
        closeStepUp,
        updateStepUpExpiry,
      }}
    >
      {children}
      <StepUpModal
        open={stepUpOpen}
        email={session.email}
        onClose={closeStepUp}
        onVerified={updateStepUpExpiry}
      />
    </SessionCtx.Provider>
  );
}

export function useAdminSession(): SessionContextValue {
  const ctx = useContext(SessionCtx);
  if (!ctx) {
    throw new Error('useAdminSession must be used inside SessionProvider');
  }
  return ctx;
}
