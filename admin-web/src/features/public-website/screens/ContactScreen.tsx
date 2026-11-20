'use client';

import { useState } from 'react';
import Link from 'next/link';
import {
  CheckCircle2,
  Mail,
  MapPin,
  Phone,
  Send,
  Smartphone,
} from 'lucide-react';
import { useSakugaToast } from '@/components/sakuga';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';

export function ContactScreen() {
  const { showToast } = useSakugaToast();

  const [form, setForm] = useState({
    name: '',
    contact: '',
    inquiryType: 'general',
    branch: 'HOME',
    message: '',
  });
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.name || !form.contact || !form.message) {
      showToast('Please fill in all required fields.', 'error');
      return;
    }

    setSubmitting(true);
    setTimeout(() => {
      setSubmitting(false);
      setSubmitted(true);
      showToast(
        'SKAVIA Operations Desk will respond to your inquiry shortly.',
        'success'
      );
    }, 600);
  };

  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-16 pt-4 pb-16 sm:pt-6 sm:pb-24">
          {/* Header */}
          <section className="relative px-4 sm:px-6 lg:px-8 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="subpage" />

            <div className="max-w-4xl mx-auto text-center space-y-4 relative z-10">
              <h1 className="font-heading font-extrabold text-3xl sm:text-5xl lg:text-6xl tracking-tight text-neutral-900 dark:text-white">
                Direct Escalation &amp; Operations Contact
              </h1>

              <p className="mt-4 text-base sm:text-lg leading-relaxed max-w-2xl mx-auto text-neutral-600 dark:text-neutral-400">
                Reach the SKAVIA Operations Command Center for commercial facility SLAs, emergency dispatches, and customer care.
              </p>
            </div>
          </section>

          {/* Contact Details & Inquiry Form Grid */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
              {/* Left Column: Verified HQ & Hotlines (5 cols) */}
              <div className="lg:col-span-5 space-y-6">
                <div className={`rounded-3xl border p-6 sm:p-8 space-y-6 ${t.railBorder} ${t.cardBg} shadow-xl`}>
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-mono-code uppercase tracking-wider text-[#15E7CA] font-bold">
                      Verified Headquarters
                    </span>
                    <span className="flex items-center gap-1.5 text-[11px] font-mono-code px-2.5 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                      <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                      <span>SLA &lt; 15m</span>
                    </span>
                  </div>

                  <div className="space-y-4 pt-1 text-xs sm:text-sm">
                    {/* Address */}
                    <div className={`flex items-start gap-3.5 rounded-2xl border p-4 ${t.railBorder} ${t.surfaceBg}`}>
                      <div className="p-2 rounded-xl bg-amber-500/10 text-amber-400 shrink-0 mt-0.5">
                        <MapPin className="h-5 w-5" />
                      </div>
                      <div>
                        <p className={`font-bold ${t.textPrimary}`}>
                          Dhaka Headquarters &amp; Dispatch Center
                        </p>
                        <p className={`text-xs mt-1 leading-relaxed ${t.textSecondary}`}>
                          Gulshan-2, Dhaka-1212, Bangladesh
                        </p>
                      </div>
                    </div>

                    {/* Phone */}
                    <div className={`flex items-start gap-3.5 rounded-2xl border p-4 ${t.railBorder} ${t.surfaceBg}`}>
                      <div className="p-2 rounded-xl bg-teal-500/10 text-teal-400 shrink-0 mt-0.5">
                        <Phone className="h-5 w-5" />
                      </div>
                      <div>
                        <p className={`font-bold ${t.textPrimary}`}>
                          Emergency Operations Hotline
                        </p>
                        <p className="text-xs font-mono-code text-[#3898EC] mt-1 font-semibold">
                          +880 9612-SKAVIA
                        </p>
                        <p className="text-[11px] text-slate-400 mt-0.5">
                          09:00 – 21:00 BST Daily
                        </p>
                      </div>
                    </div>

                    {/* Email */}
                    <div className={`flex items-start gap-3.5 rounded-2xl border p-4 ${t.railBorder} ${t.surfaceBg}`}>
                      <div className="p-2 rounded-xl bg-blue-500/10 text-[#3898EC] shrink-0 mt-0.5">
                        <Mail className="h-5 w-5" />
                      </div>
                      <div>
                        <p className={`font-bold ${t.textPrimary}`}>
                          Official Operations Inquiries
                        </p>
                        <p className="text-xs font-mono-code text-slate-400 mt-1">
                          operations@skavia.com &middot; support@skavia.com
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* App CTA */}
                  <div className="pt-2">
                    <Link
                      href="/download"
                      className="w-full inline-flex items-center justify-center gap-2 px-5 py-3 rounded-2xl bg-[#003399] hover:bg-[#002266] text-white text-xs sm:text-sm font-semibold shadow-md transition"
                    >
                      <Smartphone className="h-4 w-4" />
                      <span>Instant Booking in Mobile App</span>
                    </Link>
                  </div>
                </div>
              </div>

              {/* Right Column: Interactive Inquiry Form (7 cols) */}
              <div className="lg:col-span-7">
                <div className={`rounded-3xl border p-6 sm:p-10 space-y-6 ${t.railBorder} ${t.cardBg} shadow-xl`}>
                  <div className="space-y-2">
                    <h2 className={`text-2xl font-bold ${t.textPrimary}`}>
                      Submit an Operational Inquiry
                    </h2>
                    <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                      Our central dispatch coordination team reviews every inquiry and follows up promptly.
                    </p>
                  </div>

                  {submitted ? (
                    <div
                      className={`p-8 rounded-2xl border text-center space-y-4 ${
                        t.dark ? 'border-emerald-800 bg-emerald-950/20' : 'border-emerald-200 bg-emerald-50'
                      }`}
                    >
                      <CheckCircle2 className="h-10 w-10 text-emerald-500 mx-auto" />
                      <h3 className={`text-lg font-bold ${t.textPrimary}`}>
                        Inquiry Received
                      </h3>
                      <p className={`text-xs max-w-md mx-auto leading-relaxed ${t.textSecondary}`}>
                        A designated SKAVIA operations supervisor has logged your inquiry and will reach out shortly.
                      </p>
                      <button
                        type="button"
                        onClick={() => {
                          setSubmitted(false);
                          setForm({ name: '', contact: '', inquiryType: 'general', branch: 'HOME', message: '' });
                        }}
                        className="text-xs font-semibold text-[#003399] dark:text-[#3898EC] underline"
                      >
                        Submit Another Message
                      </button>
                    </div>
                  ) : (
                    <form onSubmit={handleSubmit} className="space-y-4">
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div className="space-y-1.5">
                          <label className={`block text-xs font-semibold ${t.textPrimary}`}>
                            Full Name *
                          </label>
                          <input
                            type="text"
                            required
                            value={form.name}
                            onChange={(e) => setForm({ ...form, name: e.target.value })}
                            placeholder="e.g. Asif Rahman"
                            className={`w-full px-4 py-2.5 rounded-xl border text-xs sm:text-sm outline-none transition ${
                              t.dark
                                ? 'bg-slate-900 border-slate-800 text-white focus:border-[#15E7CA]'
                                : 'bg-white border-slate-200 text-slate-900 focus:border-[#003399]'
                            }`}
                          />
                        </div>

                        <div className="space-y-1.5">
                          <label className={`block text-xs font-semibold ${t.textPrimary}`}>
                            Phone / Email *
                          </label>
                          <input
                            type="text"
                            required
                            value={form.contact}
                            onChange={(e) => setForm({ ...form, contact: e.target.value })}
                            placeholder="+880 17... / name@company.com"
                            className={`w-full px-4 py-2.5 rounded-xl border text-xs sm:text-sm outline-none transition ${
                              t.dark
                                ? 'bg-slate-900 border-slate-800 text-white focus:border-[#15E7CA]'
                                : 'bg-white border-slate-200 text-slate-900 focus:border-[#003399]'
                            }`}
                          />
                        </div>
                      </div>

                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div className="space-y-1.5">
                          <label className={`block text-xs font-semibold ${t.textPrimary}`}>
                            Inquiry Type
                          </label>
                          <select
                            value={form.inquiryType}
                            onChange={(e) => setForm({ ...form, inquiryType: e.target.value })}
                            className={`w-full px-4 py-2.5 rounded-xl border text-xs sm:text-sm outline-none transition ${
                              t.dark
                                ? 'bg-slate-900 border-slate-800 text-white focus:border-[#15E7CA]'
                                : 'bg-white border-slate-200 text-slate-900 focus:border-[#003399]'
                            }`}
                          >
                            <option value="general">General Service Inquiry</option>
                            <option value="corporate">Corporate / Facility Contract</option>
                            <option value="specialist">Specialist Application</option>
                            <option value="escalation">Priority Support / Feedback</option>
                          </select>
                        </div>

                        <div className="space-y-1.5">
                          <label className={`block text-xs font-semibold ${t.textPrimary}`}>
                            Related Branch
                          </label>
                          <select
                            value={form.branch}
                            onChange={(e) => setForm({ ...form, branch: e.target.value })}
                            className={`w-full px-4 py-2.5 rounded-xl border text-xs sm:text-sm outline-none transition ${
                              t.dark
                                ? 'bg-slate-900 border-slate-800 text-white focus:border-[#15E7CA]'
                                : 'bg-white border-slate-200 text-slate-900 focus:border-[#003399]'
                            }`}
                          >
                            <option value="HOME">SKAVIA Home (Sanitary, Plumbing, Carpentry)</option>
                            <option value="TECH">SKAVIA Technical (HVAC, Electrical, CCTV)</option>
                            <option value="BIZ">SKAVIA Business (Commercial Workspaces)</option>
                            <option value="CONS">SKAVIA Construction (Civil Renovation)</option>
                            <option value="DIGI">SKAVIA Digital (IT, POS, Networking)</option>
                            <option value="AGRI">SKAVIA Agriculture (Irrigation, Agri-Tech)</option>
                            <option value="LOGI">SKAVIA Logistics (Dispatch &amp; Supply)</option>
                            <option value="EVNT">SKAVIA Events (AV Grids &amp; Staging)</option>
                          </select>
                        </div>
                      </div>

                      <div className="space-y-1.5">
                        <label className={`block text-xs font-semibold ${t.textPrimary}`}>
                          Detailed Message *
                        </label>
                        <textarea
                          required
                          rows={4}
                          value={form.message}
                          onChange={(e) => setForm({ ...form, message: e.target.value })}
                          placeholder="Describe your requirement, site address, or specific technical questions..."
                          className={`w-full p-4 rounded-xl border text-xs sm:text-sm outline-none transition resize-none ${
                            t.dark
                              ? 'bg-slate-900 border-slate-800 text-white focus:border-[#15E7CA]'
                              : 'bg-white border-slate-200 text-slate-900 focus:border-[#003399]'
                          }`}
                        />
                      </div>

                      <button
                        type="submit"
                        disabled={submitting}
                        className="w-full inline-flex items-center justify-center gap-2 px-6 py-3 rounded-2xl bg-[#003399] hover:bg-[#002266] text-white text-xs sm:text-sm font-semibold shadow-lg shadow-blue-900/25 transition disabled:opacity-50"
                      >
                        <Send className="h-4 w-4" />
                        <span>{submitting ? 'Transmitting...' : 'Send Message to Operations Desk'}</span>
                      </button>
                    </form>
                  )}
                </div>
              </div>
            </div>
          </section>
        </div>
      )}
    </PublicPageShell>
  );
}
