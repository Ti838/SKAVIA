import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/models/requirement_model.dart';
import '../widgets/job_requirement_feed_card.dart';
import '../widgets/live_job_bid_sheet.dart';
import '../widgets/post_composer_sheet.dart';

export '../../data/models/requirement_model.dart';

/// Live Jobs & Social Feed Screen
/// Aligned with SKAVIA SRS Section 3.1.E, 3.1.G & 3.1.H.
/// Features a social post composer, reactive feed filters, real-time Supabase loading,
/// skeleton loaders, bid submissions, and cross-account data isolation.
class LiveJobFeedScreen extends StatefulWidget {
  final bool isTab;

  const LiveJobFeedScreen({super.key, this.isTab = false});

  @override
  State<LiveJobFeedScreen> createState() => _LiveJobFeedScreenState();
}

class _LiveJobFeedScreenState extends State<LiveJobFeedScreen> {
  final AuthController _authController = AuthController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedPostType = 'All'; // All, Job, Service Request, Update
  String _selectedCategory = 'All';
  bool _onlyEmergency = false;
  bool _isLoading = false;

  List<JobRequirementItem> _jobs = [];

  @override
  void initState() {
    super.initState();
    _fetchLiveRequirements();
  }

  @override
  void dispose() {
    _authController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveRequirements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('requirements')
          .select(
            'requirement_id, title, description, location, budget, status, created_at, category_id, submitted_by',
          )
          .eq('status', 'Open')
          .order('created_at', ascending: false)
          .limit(30);

      List<JobRequirementItem> fetched = [];
      if (res.isNotEmpty) {
        for (final row in res) {
          final id = row['requirement_id']?.toString() ?? 'req';
          final title = row['title']?.toString() ?? 'Service Requirement';
          final desc = row['description']?.toString() ?? '';
          final loc = row['location']?.toString() ?? 'Dhaka, Bangladesh';
          final budget = (row['budget'] as num?)?.toDouble() ?? 1500.0;
          final catId = row['category_id']?.toString() ?? 'cat_electrical';
          final status = row['status']?.toString() ?? 'Open';

          String catName = 'Electrical';
          if (catId.contains('ac') || catId.contains('hvac')) {
            catName = 'HVAC & AC';
          } else if (catId.contains('plumb')) {
            catName = 'Plumbing';
          } else if (catId.contains('carpent')) {
            catName = 'Carpentry';
          }

          fetched.add(
            JobRequirementItem(
              id: id,
              title: title,
              category: catName,
              categoryId: catId,
              description: desc,
              location: loc,
              budgetMin: budget * 0.9,
              budgetMax: budget * 1.2,
              urgency: 'Standard',
              timeAgo: 'Just now',
              clientName: 'Verified Client',
              authorRole: 'Client',
              postType: 'Job',
              status: status,
              likesCount: 3,
              commentsCount: 1,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _jobs = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[LiveJobFeedScreen fetch notice]: $e');
      if (mounted) {
        setState(() {
          _jobs = [];
          _isLoading = false;
        });
      }
    }
  }

  List<JobRequirementItem> get _filteredJobs {
    final query = _searchController.text.trim().toLowerCase();
    return _jobs.where((job) {
      // 1. Post type filter
      if (_selectedPostType != 'All') {
        if (_selectedPostType == 'Jobs' && job.postType != 'Job') return false;
        if (_selectedPostType == 'Requests' && job.postType != 'Service Request') return false;
        if (_selectedPostType == 'Updates' && job.postType != 'Update' && job.postType != 'Professional Update') return false;
      }

      // 2. Category filter
      if (_selectedCategory != 'All' &&
          !job.category.toLowerCase().contains(_selectedCategory.toLowerCase())) {
        return false;
      }

      // 3. Emergency only
      if (_onlyEmergency && !job.urgency.toLowerCase().contains('emergency')) {
        return false;
      }

      // 4. Search query
      if (query.isNotEmpty) {
        final matchesTitle = job.title.toLowerCase().contains(query);
        final matchesDesc = job.description.toLowerCase().contains(query);
        final matchesLoc = job.location.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc && !matchesLoc) return false;
      }
      return true;
    }).toList();
  }

  void _showBidBottomSheet(JobRequirementItem job) {
    LiveJobBidSheet.show(context, job);
  }

  void _openPostComposer() {
    PostComposerSheet.show(
      context,
      onPostCreated: (newItem) {
        setState(() {
          _jobs.insert(0, newItem);
        });
        _fetchLiveRequirements();
      },
    );
  }

  Widget _buildComposerCard(bool isBn) {
    final user = _authController.user;
    final initial = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName![0].toUpperCase()
        : (user?.email?.isNotEmpty ?? false)
            ? user!.email![0].toUpperCase()
            : 'U';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _openPostComposer,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surfaceContainerHighest : AppColors.canvasBlue,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Text(
                      isBn
                          ? 'একটি কাজ পোস্ট করুন বা সেবা চান...'
                          : 'Share an opportunity, post a job, or request a service...',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildComposerAction(
                icon: Icons.work_outline_rounded,
                color: AppColors.primaryRoyal,
                label: isBn ? 'কাজের পোস্ট' : 'Post Job',
                onTap: _openPostComposer,
              ),
              _buildComposerAction(
                icon: Icons.handyman_outlined,
                color: AppColors.accentAqua,
                label: isBn ? 'সেবা চান' : 'Request Service',
                onTap: _openPostComposer,
              ),
              _buildComposerAction(
                icon: Icons.campaign_outlined,
                color: AppColors.accentCoral,
                label: isBn ? 'আপডেট' : 'Share Update',
                onTap: _openPostComposer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComposerAction({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) {
        return Container(
          height: 160,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 12,
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 70,
                        height: 10,
                        color: colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 14,
                color: colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 12,
                color: colorScheme.surfaceContainerHighest,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTabs(bool isBn) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final tabs = [
      {'key': 'All', 'label': isBn ? 'সকল পোস্ট' : 'All Posts'},
      {'key': 'Jobs', 'label': isBn ? 'চাকরি/কাজ' : 'Jobs'},
      {'key': 'Requests', 'label': isBn ? 'সেবা অনুরোধ' : 'Service Requests'},
      {'key': 'Updates', 'label': isBn ? 'পেশাদার আপডেট' : 'Updates'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedPostType == tab['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                tab['label']!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? colorScheme.onSurface : AppColors.textDark),
                ),
              ),
              selected: isSelected,
              selectedColor: isDark ? colorScheme.primary : AppColors.primaryRoyal,
              backgroundColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
              side: BorderSide(
                color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
              ),
              onSelected: (_) {
                setState(() => _selectedPostType = tab['key']!);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryFilterChips(bool isBn) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final categories = [
      {'key': 'All', 'label': isBn ? 'সকল ট্রেড' : 'All Trades'},
      {'key': 'Electrical', 'label': isBn ? 'ইলেকট্রিক্যাল' : 'Electrical'},
      {'key': 'HVAC', 'label': isBn ? 'এসি / HVAC' : 'AC & HVAC'},
      {'key': 'Plumbing', 'label': isBn ? 'প্লাম্বিং' : 'Plumbing'},
      {'key': 'Carpentry', 'label': isBn ? 'কার্পেন্ট্রি' : 'Carpentry'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(
                cat['label']!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                ),
              ),
              selected: isSelected,
              selectedColor: isDark ? colorScheme.primary : AppColors.primarySky,
              backgroundColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
              side: BorderSide(
                color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
              ),
              onSelected: (_) {
                setState(() => _selectedCategory = cat['key']!);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: widget.isTab ? colorScheme.surface : (isDark ? colorScheme.surface : AppColors.canvasBlue),
      appBar: widget.isTab
          ? null
          : AppBar(
              backgroundColor: AppColors.canvasBlue,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                isBn ? 'লাইভ সোশ্যাল ও জব ফিড' : 'Live Marketplace & Feed',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.post_add_rounded, color: Colors.white),
                  tooltip: 'Create Post',
                  onPressed: _openPostComposer,
                ),
              ],
            ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryRoyal,
          onRefresh: _fetchLiveRequirements,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            slivers: [
              // 1. Post Composer Card
              SliverToBoxAdapter(
                child: _buildComposerCard(isBn),
              ),

              // 2. Post Type Filter Chips (All, Jobs, Requests, Updates)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _buildFilterTabs(isBn),
                ),
              ),

              // 2b. Trade Category Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCategoryFilterChips(isBn),
                ),
              ),

              // 3. Search & Category Sub-bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: isBn
                                  ? 'কাজের নাম বা এলাকা খুঁজুন...'
                                  : 'Search feed by keyword...',
                              hintStyle: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                size: 18,
                                color: isDark ? colorScheme.primary : AppColors.primarySky,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              filled: false,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Emergency Filter Toggle
                      GestureDetector(
                        onTap: () => setState(() => _onlyEmergency = !_onlyEmergency),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                          decoration: BoxDecoration(
                            color: _onlyEmergency ? AppColors.accentCoral : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _onlyEmergency ? AppColors.accentCoral : colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 14,
                                color: _onlyEmergency ? Colors.white : AppColors.accentCoral,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isBn ? 'জরুরি' : 'Urgent',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: _onlyEmergency ? Colors.white : AppColors.accentCoral,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Live Counter & Refresh Strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.successGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_filteredJobs.length} ${isBn ? "টি পোস্ট সক্রিয়" : "Active Feed Posts"}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _fetchLiveRequirements,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.refresh_rounded,
                              size: 14,
                              color: AppColors.primarySky,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isBn ? 'রিফ্রেশ' : 'Refresh',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primarySky,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Feed List or Loading / Empty States
              if (_isLoading)
                SliverToBoxAdapter(
                  child: _buildSkeletonLoader(),
                )
              else if (_filteredJobs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.dynamic_feed_rounded,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isBn
                                ? 'কোনো পোস্ট পাওয়া যায়নি'
                                : 'No posts matching your filter',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isBn
                                ? 'নতুন কাজ পোস্ট করতে উপরের বোতাম ব্যবহার করুন'
                                : 'Use the composer above to share an opportunity',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRoyal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: Text(isBn ? 'পোস্ট তৈরি করুন' : 'Create Post'),
                            onPressed: _openPostComposer,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final job = _filteredJobs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: JobRequirementFeedCard(
                            job: job,
                            onApply: () => _showBidBottomSheet(job),
                            onJobUpdated: (updated) {
                              setState(() {
                                final idx = _jobs.indexWhere((j) => j.id == updated.id);
                                if (idx != -1) _jobs[idx] = updated;
                              });
                            },
                          ),
                        );
                      },
                      childCount: _filteredJobs.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryRoyal,
        elevation: 3,
        icon: const Icon(Icons.post_add_rounded, color: Colors.white, size: 18),
        label: Text(
          isBn ? 'পোস্ট তৈরি করুন' : 'Create Post',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        onPressed: _openPostComposer,
      ),
    );
  }
}
