import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/empty_states/empty_data_view.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_card.dart';

class SupportFaqScreen extends StatefulWidget {
  const SupportFaqScreen({super.key});

  @override
  State<SupportFaqScreen> createState() => _SupportFaqScreenState();
}

class _SupportFaqScreenState extends State<SupportFaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Booking',
    'Payments',
    'Teams',
    'Safety',
  ];

  static const List<Map<String, String>> _faqs = [
    {
      'category': 'Booking',
      'q': 'How does the 4-digit Job OTP verification work?',
      'a': 'When you book a service, a secret 4-digit OTP is generated for your service request. Share this code with your SKAVIA specialist only after inspecting the completed job so payout escrow can be released safely.',
    },
    {
      'category': 'Payments',
      'q': 'What is the SKAVIA transparent 15% fee?',
      'a': 'Booking on SKAVIA carries zero hidden surcharges for clients. A 15% transparent platform management fee covers escrow protection, NID verification, quality coordination, and dispute mediation.',
    },
    {
      'category': 'Teams',
      'q': 'How do multi-skill Turnkey Business Projects work?',
      'a': 'Organizations and Business Clients can post complex requirements spanning multiple trades. SKAVIA assigns verified specialists, coordinates a dedicated Team Leader, and tracks tasks and milestones centrally.',
    },
    {
      'category': 'Safety',
      'q': 'Are SKAVIA specialists verified before dispatch?',
      'a': 'Yes. Specialists submit National ID (NID) and trade certificates into SKAVIA restricted storage before receiving verified badges and live dispatch eligibility.',
    },
    {
      'category': 'Payments',
      'q': 'Where can I download my VAT invoices?',
      'a': 'Open Profile -> Transaction History & Invoices (or Settings -> Transaction History) to inspect completed transactions and itemized escrow invoices.',
    },
    {
      'category': 'Safety',
      'q': 'What happens if I request account deletion?',
      'a': 'Account deletion initiates a 30-day grace period with audit logging before personal data and addresses are anonymized in accordance with local data retention laws.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchContact(Uri uri, String fallbackText) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    } catch (_) {}
    if (mounted) {
      UiFeedbackHelper.showInfo(context, fallbackText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _faqs.where((item) {
      final matchesCat =
          _selectedCategory == 'All' || item['category'] == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          item['q']!.toLowerCase().contains(query) ||
          item['a']!.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: const AppAppBar(title: 'Help Center & FAQ'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search FAQs, OTP, escrow, verification...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _categories.map((cat) {
                final selected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            if (filtered.isEmpty)
              const EmptyDataView(
                icon: Icons.help_outline_rounded,
                title: 'No Matching Questions',
                message: 'Try clearing your search filter or contact support directly.',
              )
            else
              ...filtered.map(
                (faq) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 6),
                      childrenPadding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                      shape: const Border(),
                      title: Text(
                        faq['q']!,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        faq['category']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tokens.brandAccent,
                        ),
                      ),
                      children: [
                        Text(
                          faq['a']!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),
            Text(
              'Need Direct Assistance?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _launchContact(
                    Uri(scheme: 'tel', path: '16524'),
                    'SKAVIA 24/7 Helpline: 16524',
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                  label: const Text('Call 16524'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _launchContact(
                    Uri(
                      scheme: 'mailto',
                      path: 'support@skavia.com',
                      queryParameters: {'subject': 'SKAVIA Support Request'},
                    ),
                    'Email support: support@skavia.com',
                  ),
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: const Text('Email Support'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.submitComplaint),
                  icon: const Icon(Icons.report_problem_outlined, size: 18),
                  label: const Text('File a Complaint'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

