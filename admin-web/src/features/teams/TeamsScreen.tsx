'use client';

import { useCallback, useEffect, useState } from 'react';
import { Briefcase, Users } from 'lucide-react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatBdt } from '@/lib/formatters';
import type { ProjectSummaryDto, WorkerDirectoryDto } from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { EmptyPanel, ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';

export default function TeamsPage() {
  const { selectedBranchId } = useAdminSession();
  const [projects, setProjects] = useState<ProjectSummaryDto[]>([]);
  const [workers, setWorkers] = useState<WorkerDirectoryDto[]>([]);
  const [selectedProjectId, setSelectedProjectId] = useState('');
  const [teamName, setTeamName] = useState('');
  const [selectedWorkers, setSelectedWorkers] = useState<string[]>([]);
  const [leaderId, setLeaderId] = useState('');
  const [taskTitle, setTaskTitle] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const qs = selectedBranchId ? `?branchId=${encodeURIComponent(selectedBranchId)}` : '';
      const [pRes, wRes] = await Promise.all([
        apiFetch<{ projects: ProjectSummaryDto[] }>(`/api/admin/teams${qs}`),
        apiFetch<{ workers: WorkerDirectoryDto[] }>(`/api/admin/workers${qs}`),
      ]);
      setProjects(pRes.projects);
      setWorkers(wRes.workers);
      setSelectedProjectId((prev) => prev || pRes.projects[0]?.project_id || '');
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed loading turnkey projects.');
    } finally {
      setLoading(false);
    }
  }, [selectedBranchId]);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  function toggleWorker(workerProfileId: string) {
    setSelectedWorkers((prev) => {
      const next = prev.includes(workerProfileId)
        ? prev.filter((id) => id !== workerProfileId)
        : [...prev, workerProfileId];
      if (!next.includes(leaderId)) {
        setLeaderId(next[0] || '');
      }
      return next;
    });
  }

  async function handleAssembleTeam(e: React.FormEvent) {
    e.preventDefault();
    if (!selectedProjectId || selectedWorkers.length === 0) return;
    setSubmitting(true);
    setError(null);
    try {
      await apiFetch('/api/admin/teams', {
        method: 'POST',
        body: JSON.stringify({
          projectId: selectedProjectId,
          teamName: teamName.trim(),
          members: selectedWorkers.map((wid) => ({
            workerProfileId: wid,
            roleInTeam: wid === leaderId ? 'Team Lead' : 'Specialist',
            isTeamLeader: wid === leaderId,
          })),
          initialTasks: taskTitle.trim()
            ? [
                {
                  title: taskTitle.trim(),
                  priority: 'High',
                  assignedWorkerProfileId: leaderId || selectedWorkers[0],
                },
              ]
            : [],
        }),
      });
      setTeamName('');
      setSelectedWorkers([]);
      setTaskTitle('');
      await loadData();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed assembling project team.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Turnkey Projects & Team Assembly</h1>
        <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
          Assemble multi-specialist delivery squads and assign initial milestones on corporate & complex projects.
        </p>
      </div>

      {error && <ErrorPanel message={error} onRetry={() => void loadData()} />}

      {loading ? (
        <LoadingPanel />
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-7 space-y-4">
            {projects.length === 0 ? (
              <EmptyPanel
                title="No turnkey projects found"
                description="Turnkey projects submitted in the Flutter platform appear here for squad assembly."
              />
            ) : (
              projects.map((p) => (
                <div
                  key={p.project_id}
                  className="rounded-xl border p-5 space-y-3"
                  style={{
                    backgroundColor: 'var(--bg-surface)',
                    borderColor: 'var(--border-subtle)',
                  }}
                >
                  <div className="flex items-start justify-between gap-2">
                    <div>
                      <h2 className="text-base font-semibold flex items-center gap-2">
                        <Briefcase className="h-4 w-4 text-blue-600" />
                        {p.title}
                      </h2>
                      <p className="text-xs mt-0.5" style={{ color: 'var(--text-muted)' }}>
                        Client: {p.client_name} &middot; {p.branch_name || 'Global'} &middot; Budget:{' '}
                        {formatBdt(p.total_budget)}
                      </p>
                    </div>
                    <StatusBadge status={p.status} />
                  </div>

                  {p.teams.map((t) => (
                    <div
                      key={t.team_id}
                      className="rounded-lg border p-3 text-xs space-y-1.5"
                      style={{
                        backgroundColor: 'var(--bg-canvas)',
                        borderColor: 'var(--border-subtle)',
                      }}
                    >
                      <div className="flex items-center justify-between font-semibold">
                        <span className="flex items-center gap-1.5">
                          <Users className="h-3.5 w-3.5 text-blue-600" />
                          Squad: {t.name}
                        </span>
                        <StatusBadge status={t.status} variant="info" />
                      </div>
                      <div className="flex flex-wrap gap-1.5">
                        {t.members.map((m) => (
                          <span
                            key={m.team_member_id}
                            className="rounded-md bg-white/80 dark:bg-slate-900 border px-2 py-0.5"
                            style={{ borderColor: 'var(--border-subtle)' }}
                          >
                            {m.worker_name} ({m.is_team_leader ? 'Lead' : m.role_in_team})
                          </span>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              ))
            )}
          </div>

          <form
            onSubmit={handleAssembleTeam}
            className="lg:col-span-5 rounded-xl border p-5 space-y-4 h-fit"
            style={{
              backgroundColor: 'var(--bg-surface)',
              borderColor: 'var(--border-subtle)',
            }}
          >
            <h2 className="text-base font-semibold">Assemble Delivery Squad</h2>

            <div>
              <label className="block text-xs font-semibold uppercase mb-1">Target Project</label>
              <select
                required
                value={selectedProjectId}
                onChange={(e) => setSelectedProjectId(e.target.value)}
                className="w-full rounded-lg border px-3 py-2 text-sm"
                style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
              >
                <option value="">Select project...</option>
                {projects.map((p) => (
                  <option key={p.project_id} value={p.project_id}>
                    {p.title}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold uppercase mb-1">Team Name</label>
              <input
                type="text"
                required
                minLength={3}
                value={teamName}
                onChange={(e) => setTeamName(e.target.value)}
                placeholder="e.g. Dhaka HVAC Rapid Squad"
                className="w-full rounded-lg border px-3 py-2 text-sm"
                style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
              />
            </div>

            <div>
              <label className="block text-xs font-semibold uppercase mb-1.5">
                Select Specialists ({selectedWorkers.length} selected)
              </label>
              <div
                className="max-h-44 overflow-y-auto rounded-lg border divide-y"
                style={{ borderColor: 'var(--border-subtle)' }}
              >
                {workers.map((w) => {
                  const checked = selectedWorkers.includes(w.worker_profile_id);
                  return (
                    <label
                      key={w.worker_profile_id}
                      className="flex items-center justify-between gap-2 px-3 py-2 text-xs cursor-pointer"
                    >
                      <span className="flex items-center gap-2">
                        <input
                          type="checkbox"
                          checked={checked}
                          onChange={() => toggleWorker(w.worker_profile_id)}
                        />
                        {w.full_name} ({w.title})
                      </span>
                      {checked && (
                        <input
                          type="radio"
                          name="teamLeader"
                          checked={leaderId === w.worker_profile_id}
                          onChange={() => setLeaderId(w.worker_profile_id)}
                          title="Set as Team Leader"
                        />
                      )}
                    </label>
                  );
                })}
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold uppercase mb-1">
                Initial Milestone Task (Optional)
              </label>
              <input
                type="text"
                value={taskTitle}
                onChange={(e) => setTaskTitle(e.target.value)}
                placeholder="e.g. Site safety inspection & BOM signoff"
                className="w-full rounded-lg border px-3 py-2 text-sm"
                style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
              />
            </div>

            <button
              type="submit"
              disabled={submitting || !selectedProjectId || selectedWorkers.length === 0}
              className="w-full rounded-lg px-4 py-2.5 text-xs font-semibold text-white disabled:opacity-50"
              style={{ backgroundColor: '#003399' }}
            >
              {submitting ? 'Persisting Squad...' : 'Confirm & Assemble Team'}
            </button>
          </form>
        </div>
      )}
    </div>
  );
}

