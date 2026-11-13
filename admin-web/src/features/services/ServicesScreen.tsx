'use client';

import { useCallback, useEffect, useState } from 'react';
import { Plus } from 'lucide-react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatBdt } from '@/lib/formatters';
import type { ServiceTaxonomyDto } from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';

export default function ServicesPage() {
  const { session, availableBranches, selectedBranchId } = useAdminSession();
  const [taxonomy, setTaxonomy] = useState<ServiceTaxonomyDto | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [createMode, setCreateMode] = useState<'service' | 'category' | 'skill'>('service');
  const [serviceName, setServiceName] = useState('');
  const [categoryId, setCategoryId] = useState('');
  const [newCategoryName, setNewCategoryName] = useState('');
  const [newCategoryBranchId, setNewCategoryBranchId] = useState('');
  const [skillName, setSkillName] = useState('');
  const [basePrice, setBasePrice] = useState('1500');
  const [submitting, setSubmitting] = useState(false);

  const canManageServices = session.effectivePermissions.includes('service.manage');
  const canToggleBranchCategory =
    canManageServices || session.effectivePermissions.includes('service.branch.manage');

  const loadTaxonomy = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const qs = selectedBranchId ? `?branchId=${encodeURIComponent(selectedBranchId)}` : '';
      const res = await apiFetch<{ taxonomy: ServiceTaxonomyDto }>(`/api/admin/services${qs}`);
      setTaxonomy(res.taxonomy);
      setCategoryId((prev) => prev || res.taxonomy.categories[0]?.category_id || '');
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed loading service taxonomy.');
    } finally {
      setLoading(false);
    }
  }, [selectedBranchId]);

  useEffect(() => {
    void loadTaxonomy();
  }, [loadTaxonomy]);

  async function handleCreateEntry(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      if (createMode === 'service') {
        if (!categoryId) return;
        await apiFetch('/api/admin/services', {
          method: 'POST',
          body: JSON.stringify({
            type: 'service',
            action: 'create',
            categoryId,
            name: serviceName.trim(),
            basePrice: Number(basePrice),
          }),
        });
        setServiceName('');
      } else if (createMode === 'category') {
        const cleanName = newCategoryName.trim();
        const slug = cleanName
          .toLowerCase()
          .replace(/[^a-z0-9]+/g, '-')
          .replace(/^-|-$/g, '');
        await apiFetch('/api/admin/services', {
          method: 'POST',
          body: JSON.stringify({
            type: 'category',
            action: 'create',
            name: cleanName,
            slug: slug || `cat-${Date.now()}`,
            branchId: newCategoryBranchId || undefined,
          }),
        });
        setNewCategoryName('');
      } else {
        if (!categoryId) return;
        await apiFetch('/api/admin/services', {
          method: 'POST',
          body: JSON.stringify({
            type: 'skill',
            action: 'create',
            categoryId,
            name: skillName.trim(),
          }),
        });
        setSkillName('');
      }
      await loadTaxonomy();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed updating service catalog.');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleToggleCategory(cat: ServiceTaxonomyDto['categories'][number]) {
    setSubmitting(true);
    setError(null);
    try {
      await apiFetch('/api/admin/services', {
        method: 'POST',
        body: JSON.stringify({
          type: 'category',
          action: 'toggle',
          id: cat.category_id,
          branchId: cat.branch_id ?? undefined,
          isActive: !cat.is_active,
        }),
      });
      await loadTaxonomy();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed toggling category.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Services, Categories & Skills</h1>
        <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
          Catalog structure powering customer booking flows and worker skill matching in the Flutter app.
        </p>
      </div>

      {canManageServices && taxonomy && (
        <form
          onSubmit={handleCreateEntry}
          className="rounded-xl border p-4 space-y-3"
          style={{
            backgroundColor: 'var(--bg-surface)',
            borderColor: 'var(--border-subtle)',
          }}
        >
          <div className="flex flex-wrap gap-1.5">
            {(
              [
                ['service', 'Add Service'],
                ['category', 'Add Category'],
                ['skill', 'Add Skill Tag'],
              ] as const
            ).map(([mode, label]) => (
              <button
                key={mode}
                type="button"
                onClick={() => setCreateMode(mode)}
                className={`rounded-lg border px-3 py-1 text-xs font-semibold transition ${
                  createMode === mode ? 'bg-blue-700 text-white border-blue-700' : ''
                }`}
                style={createMode !== mode ? { borderColor: 'var(--border-subtle)' } : undefined}
              >
                {label}
              </button>
            ))}
          </div>

          <div className="flex flex-wrap items-end gap-3">
            {createMode === 'category' ? (
              <>
                <div className="flex-1 min-w-[200px]">
                  <label className="block text-xs font-semibold uppercase mb-1">
                    Branch Unit
                  </label>
                  <select
                    value={newCategoryBranchId}
                    onChange={(e) => setNewCategoryBranchId(e.target.value)}
                    className="w-full rounded-lg border px-3 py-2 text-sm"
                    style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                  >
                    <option value="">Global / Multi-Branch</option>
                    {availableBranches.map((b) => (
                      <option key={b.branch_id} value={b.branch_id}>
                        {b.name} ({b.code})
                      </option>
                    ))}
                  </select>
                </div>
                <div className="flex-1 min-w-[220px]">
                  <label className="block text-xs font-semibold uppercase mb-1">
                    Category Name
                  </label>
                  <input
                    type="text"
                    required
                    minLength={2}
                    value={newCategoryName}
                    onChange={(e) => setNewCategoryName(e.target.value)}
                    placeholder="e.g. Solar & Backup Power"
                    className="w-full rounded-lg border px-3 py-2 text-sm"
                    style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                  />
                </div>
              </>
            ) : (
              <>
                <div className="flex-1 min-w-[200px]">
                  <label className="block text-xs font-semibold uppercase mb-1">Category</label>
                  <select
                    value={categoryId}
                    onChange={(e) => setCategoryId(e.target.value)}
                    className="w-full rounded-lg border px-3 py-2 text-sm"
                    style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                  >
                    {taxonomy.categories.map((c) => (
                      <option key={c.category_id} value={c.category_id}>
                        {c.name}
                      </option>
                    ))}
                  </select>
                </div>
                {createMode === 'service' ? (
                  <>
                    <div className="flex-1 min-w-[220px]">
                      <label className="block text-xs font-semibold uppercase mb-1">
                        Service Name
                      </label>
                      <input
                        type="text"
                        required
                        minLength={2}
                        value={serviceName}
                        onChange={(e) => setServiceName(e.target.value)}
                        placeholder="e.g. Industrial Chiller Servicing"
                        className="w-full rounded-lg border px-3 py-2 text-sm"
                        style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                      />
                    </div>
                    <div className="w-36">
                      <label className="block text-xs font-semibold uppercase mb-1">
                        Base Price (BDT)
                      </label>
                      <input
                        type="number"
                        min="0"
                        required
                        value={basePrice}
                        onChange={(e) => setBasePrice(e.target.value)}
                        className="w-full rounded-lg border px-3 py-2 text-sm tabular-nums"
                        style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                      />
                    </div>
                  </>
                ) : (
                  <div className="flex-1 min-w-[220px]">
                    <label className="block text-xs font-semibold uppercase mb-1">Skill Name</label>
                    <input
                      type="text"
                      required
                      minLength={2}
                      value={skillName}
                      onChange={(e) => setSkillName(e.target.value)}
                      placeholder="e.g. Variable Refrigerant Flow Testing"
                      className="w-full rounded-lg border px-3 py-2 text-sm"
                      style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                    />
                  </div>
                )}
              </>
            )}

            <button
              type="submit"
              disabled={submitting}
              className="inline-flex items-center gap-1.5 rounded-lg px-4 py-2 text-xs font-semibold text-white"
              style={{ backgroundColor: '#003399' }}
            >
              <Plus className="h-4 w-4" />
              {createMode === 'service'
                ? 'Add Service'
                : createMode === 'category'
                  ? 'Add Category'
                  : 'Add Skill'}
            </button>
          </div>
        </form>
      )}

      {error && <ErrorPanel message={error} onRetry={() => void loadTaxonomy()} />}

      {loading || !taxonomy ? (
        <LoadingPanel />
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          {taxonomy.categories.map((cat) => {
            const catServices = taxonomy.services.filter((s) => s.category_id === cat.category_id);
            const catSkills = taxonomy.skills.filter((sk) => sk.category_id === cat.category_id);
            return (
              <div
                key={cat.category_id}
                className="rounded-xl border p-5 space-y-3"
                style={{
                  backgroundColor: 'var(--bg-surface)',
                  borderColor: 'var(--border-subtle)',
                }}
              >
                <div className="flex items-center justify-between gap-2">
                  <div>
                    <h2 className="text-base font-semibold">{cat.name}</h2>
                    <p className="text-xs font-mono-code" style={{ color: 'var(--text-muted)' }}>
                      {cat.branch_name || 'Global'} &middot; {cat.slug}
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    <StatusBadge status={cat.is_active ? 'Active' : 'Suspended'} />
                    {canToggleBranchCategory && (
                      <button
                        type="button"
                        disabled={submitting}
                        onClick={() => void handleToggleCategory(cat)}
                        className="text-xs font-semibold text-blue-700 dark:text-sky-400 hover:underline disabled:opacity-50"
                      >
                        {cat.is_active ? 'Disable' : 'Enable'}
                      </button>
                    )}
                  </div>
                </div>

                <div className="space-y-1.5">
                  <p className="text-xs font-semibold uppercase" style={{ color: 'var(--text-muted)' }}>
                    Services ({catServices.length})
                  </p>
                  {catServices.length === 0 ? (
                    <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                      No services registered in this category.
                    </p>
                  ) : (
                    <ul className="divide-y text-sm" style={{ borderColor: 'var(--border-subtle)' }}>
                      {catServices.map((srv) => (
                        <li key={srv.service_id} className="py-1.5 flex items-center justify-between">
                          <span>{srv.name}</span>
                          <span className="font-semibold tabular-nums">
                            {formatBdt(srv.base_price)}
                          </span>
                        </li>
                      ))}
                    </ul>
                  )}
                </div>

                <div className="pt-2 flex flex-wrap gap-1.5">
                  {catSkills.map((sk) => (
                    <StatusBadge key={sk.skill_id} status={sk.name} variant="neutral" />
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

