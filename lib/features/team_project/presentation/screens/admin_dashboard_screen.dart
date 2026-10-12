import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';

/// Screen 17: Admin Dashboard from the SKAVIA reference design board.
/// Features high-level overview metrics, navigation drawer/side bar, and real-time activity stream.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedNavIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard_rounded},
    {'title': 'Users', 'icon': Icons.people_outline_rounded},
    {'title': 'Teams', 'icon': Icons.groups_outlined},
    {'title': 'Projects', 'icon': Icons.folder_open_rounded},
    {'title': 'Messages', 'icon': Icons.chat_bubble_outline_rounded},
    {'title': 'Reports', 'icon': Icons.bar_chart_rounded},
    {'title': 'Audit Log', 'icon': Icons.history_rounded},
    {'title': 'Settings', 'icon': Icons.settings_outlined},
  ];

  final List<Map<String, dynamic>> _overviewStats = [
    {'title': 'Total Users', 'value': '1,248', 'color': Color(0xFF1E293B)},
    {'title': 'Active Teams', 'value': '342', 'color': Color(0xFF10B981)},
    {'title': 'Total Projects', 'value': '567', 'color': Color(0xFF2563EB)},
    {'title': 'Reports', 'value': '23', 'color': Color(0xFFEF4444)},
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'title': 'New user registered',
      'time': '2 min ago',
      'icon': Icons.person_add_alt_1_rounded,
      'color': Color(0xFF2563EB),
    },
    {
      'title': 'Project reported',
      'time': '12 min ago',
      'icon': Icons.report_problem_outlined,
      'color': Color(0xFFEF4444),
    },
    {
      'title': 'Team Milestone verified',
      'time': '1 hour ago',
      'icon': Icons.verified_outlined,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'Escrow payout dispatched',
      'time': '3 hours ago',
      'icon': Icons.payments_outlined,
      'color': Color(0xFFF59E0B),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          children: [
            Image.asset(
              AppAssets.logo,
              height: 22,
              fit: BoxFit.contain,
              errorBuilder: (_, error, stack) => const Text(
                'SKAVIA',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Admin',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textDark,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Side navigation (for desktop/wide screen or drawer style)
            if (isWide)
              Container(
                width: 220,
                color: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    ..._navItems.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final isSelected = _selectedNavIndex == idx;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: const Color(0xFF1E293B),
                        leading: Icon(
                          item['icon'] as IconData,
                          color: isSelected
                              ? const Color(0xFF60A5FA)
                              : Colors.white70,
                          size: 20,
                        ),
                        title: Text(
                          item['title'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        onTap: () => setState(() => _selectedNavIndex = idx),
                      );
                    }),
                    const Spacer(),
                    ListTile(
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      onTap: () => Navigator.maybePop(context),
                    ),
                  ],
                ),
              ),

            // Main Dashboard Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4 Overview Cards Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.45,
                          ),
                      itemCount: _overviewStats.length,
                      itemBuilder: (context, index) {
                        final stat = _overviewStats[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                stat['title'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                stat['value'] as String,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: stat['color'] as Color,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // Recent Activity Section
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: _recentActivities.map((act) {
                          final color = act['color'] as Color;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    act['icon'] as IconData,
                                    color: color,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        act['title'] as String,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        act['time'] as String,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
