'use client';

import { useCallback, useEffect, useState } from 'react';
import { CheckCircle2, ExternalLink, FileCheck2, ShieldCheck, XCircle } from 'lucide-react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatDateTime } from '@/lib/formatters';
import type { VerificationQueueDto } from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { EmptyPanel, ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';

export default function VerificationsPage() {
  const { selectedBranchId } = useAdminSession();
  const [items, setItems] = useState<VerificationQueueDto[]>([]);
  const [statusFilter, setStatusFilter] = useState('Pending');
  const [active, setActive] = useState<VerificationQueueDto | null>(null);
  const [signedUrl, setSignedUrl] = useState<string | null>(null);
  const [nidMatched, setNidMatched] = useState(false);
  const [documentLegible, setDocumentLegible] = useState(false);
  const [policeClearanceChecked, setPoliceClearanceChecked] = useState(false);
  const [reviewNotes, setReviewNotes] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadQueue = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const qs = new URLSearchParams();
      if (selectedBranchId) qs.set('branchId', selectedBranchId);
      if (statusFilter) qs.set('status', statusFilter);
      const res = await apiFetch<{ verifications: VerificationQueueDto[] }>(
        `/api/admin/verifications?${qs.toString()}`
      );
      setItems(res.verifications);
      setActive((prev) => {
        if (prev && res.verifications.some((v) => v.verification_id === prev.verification_id)) {
          return res.verifications.find((v) => v.verification_id === prev.verification_id) || null;
        }
        return res.verifications[0] || null;
      });
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed loading KYC queue.');
    } finally {
      setLoading(false);
    }
  }, [selectedBranchId, statusFilter]);

  useEffect(() => {
    void loadQueue();
  }, [loadQueue]);

  async function handleRequestDocument() {
    if (!active) return;
    setError(null);
    try {
      const res = await apiFetch<{ signedUrl: string; expiresInSeconds: number }>(
        `/api/admin/verifications/${active.verification_id}/document`
      );
      setSignedUrl(res.signedUrl);
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed issuing signed URL.');
    }
  }

  async function handleDecision(decision: 'Approved' | 'Rejected') {
    if (!active) return;
    setSubmitting(true);
    setError(null);
    try {
      await apiFetch(`/api/admin/verifications/${active.verification_id}/decision`, {
        method: 'POST',
        body: JSON.stringify({
          decision,
          reviewNotes: reviewNotes.trim(),
          checklist: {
            nidMatched,
            documentLegible,
            policeClearanceChecked,
          },
        }),
      });
      setReviewNotes('');
      setSignedUrl(null);
      setNidMatched(false);
      setDocumentLegible(false);
      await loadQueue();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Decision submission failed.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">KYC & Specialist Verification</h1>
          <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
            Split-pane compliance inspection with 60-second signed document access & mandatory review notes.
          </p>
        </div>

        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="rounded-lg border px-3 py-2 text-sm outline-none"
          style={{
            backgroundColor: 'var(--bg-surface)',
            borderColor: 'var(--border-subtle)',
          }}
        >
          <option value="Pending">Pending Review</option>
          <option value="Approved">Approved</option>
          <option value="Rejected">Rejected</option>
          <option value="">All Verifications</option>
        </select>
      </div>

      {error && <ErrorPanel message={error} onRetry={() => void loadQueue()} />}

      {loading ? (
        <LoadingPanel />
      ) : items.length === 0 ? (
        <EmptyPanel
          title="Verification queue is clear"
          description="No specialist KYC submissions match the selected branch and status filter."
        />
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-5">
          <div
            className="lg:col-span-5 rounded-xl border divide-y overflow-hidden"
            style={{
              backgroundColor: 'var(--bg-surface)',
              borderColor: 'var(--border-subtle)',
            }}
          >
            {items.map((v) => {
              const isSelected = active?.verification_id === v.verification_id;
              return (
                <button
                  key={v.verification_id}
                  type="button"
                  onClick={() => {
                    setActive(v);
                    setSignedUrl(null);
                  }}
                  className={`w-full text-left p-4 transition ${
                    isSelected ? 'bg-blue-50/70 dark:bg-slate-800/70' : ''
                  }`}
                >
                  <div className="flex items-start justify-between gap-2">
                    <div>
                      <p className="text-sm font-semibold">{v.worker_name}</p>
                      <p className="text-xs mt-0.5" style={{ color: 'var(--text-muted)' }}>
                        {v.document_type} &middot; {v.branch_name || 'No branch'}
                      </p>
                    </div>
                    <StatusBadge status={v.status} />
                  </div>
                  <p className="mt-2 text-xs font-mono-code" style={{ color: 'var(--text-secondary)' }}>
                    Doc #{v.document_number}
                  </p>
                </button>
              );
            })}
          </div>

          <div
            className="lg:col-span-7 rounded-xl border p-6 space-y-5"
            style={{
              backgroundColor: 'var(--bg-surface)',
              borderColor: 'var(--border-subtle)',
            }}
          >
            {active ? (
              <>
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <h2 className="text-lg font-semibold">{active.worker_name}</h2>
                    <p className="text-xs mt-0.5" style={{ color: 'var(--text-muted)' }}>
                      Submitted {formatDateTime(active.created_at)} &middot; Branch:{' '}
                      {active.branch_name || 'Unassigned'}
                    </p>
                  </div>
                  <StatusBadge status={active.status} />
                </div>

                <div
                  className="rounded-xl border p-4 space-y-3"
                  style={{
                    backgroundColor: 'var(--bg-canvas)',
                    borderColor: 'var(--border-subtle)',
                  }}
                >
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <div className="flex items-center gap-2 text-sm font-medium">
                      <FileCheck2 className="h-4 w-4 text-blue-600" />
                      <span>
                        {active.document_type} ({active.document_number})
                      </span>
                    </div>
                    <button
                      type="button"
                      onClick={() => void handleRequestDocument()}
                      className="inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-xs font-semibold text-white"
                      style={{ backgroundColor: '#003399' }}
                    >
                      <ShieldCheck className="h-3.5 w-3.5" />
                      Load Private Signed Document (60s)
                    </button>
                  </div>

                  {signedUrl && (
                    <div className="rounded-lg border border-blue-200 dark:border-blue-800/70 bg-blue-50/70 dark:bg-blue-950/40 p-3 text-xs space-y-2">
                      <p className="font-semibold text-blue-900 dark:text-blue-100">
                        Short-lived signed access granted & logged to audit_logs (60s TTL).
                      </p>
                      <a
                        href={signedUrl}
                        target="_blank"
                        rel="noreferrer"
                        className="inline-flex items-center gap-1 text-blue-700 dark:text-sky-400 underline font-medium"
                      >
                        Open Encrypted KYC Document <ExternalLink className="h-3.5 w-3.5" />
                      </a>
                    </div>
                  )}
                </div>

                {active.status === 'Pending' ? (
                  <>
                    <div className="space-y-2">
                      <p className="text-xs font-semibold uppercase tracking-wider" style={{ color: 'var(--text-muted)' }}>
                        Mandatory Verification Checklist
                      </p>
                      <label className="flex items-center gap-2 text-sm">
                        <input
                          type="checkbox"
                          checked={nidMatched}
                          onChange={(e) => setNidMatched(e.target.checked)}
                        />
                        Document ID number matches submitted KYC metadata
                      </label>
                      <label className="flex items-center gap-2 text-sm">
                        <input
                          type="checkbox"
                          checked={documentLegible}
                          onChange={(e) => setDocumentLegible(e.target.checked)}
                        />
                        Photo and security markings are clear and unedited
                      </label>
                      <label className="flex items-center gap-2 text-sm">
                        <input
                          type="checkbox"
                          checked={policeClearanceChecked}
                          onChange={(e) => setPoliceClearanceChecked(e.target.checked)}
                        />
                        Background / Police clearance checked (if applicable)
                      </label>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold uppercase tracking-wider mb-1.5">
                        Compliance Review Notes (min 5 characters)
                      </label>
                      <textarea
                        rows={3}
                        value={reviewNotes}
                        onChange={(e) => setReviewNotes(e.target.value)}
                        placeholder="Record clear evidence notes for approval or specific rejection reason..."
                        className="w-full rounded-lg border p-3 text-sm outline-none focus:ring-2 focus:ring-blue-500"
                        style={{
                          backgroundColor: 'var(--bg-canvas)',
                          borderColor: 'var(--border-subtle)',
                        }}
                      />
                    </div>

                    <div className="flex flex-wrap justify-end gap-3">
                      <button
                        type="button"
                        disabled={submitting || reviewNotes.trim().length < 5}
                        onClick={() => void handleDecision('Rejected')}
                        className="inline-flex items-center gap-1.5 rounded-lg bg-red-600 px-4 py-2 text-xs font-semibold text-white disabled:opacity-50"
                      >
                        <XCircle className="h-4 w-4" />
                        Reject KYC
                      </button>
                      <button
                        type="button"
                        disabled={
                          submitting ||
                          reviewNotes.trim().length < 5 ||
                          !nidMatched ||
                          !documentLegible
                        }
                        onClick={() => void handleDecision('Approved')}
                        className="inline-flex items-center gap-1.5 rounded-lg bg-emerald-600 px-4 py-2 text-xs font-semibold text-white disabled:opacity-50"
                      >
                        <CheckCircle2 className="h-4 w-4" />
                        Approve Specialist
                      </button>
                    </div>
                  </>
                ) : (
                  <div className="text-sm space-y-1">
                    <p className="text-xs uppercase" style={{ color: 'var(--text-muted)' }}>
                      Recorded Decision Notes
                    </p>
                    <p>{active.review_notes || 'No review notes stored.'}</p>
                  </div>
                )}
              </>
            ) : null}
          </div>
        </div>
      )}
    </div>
  );
}

