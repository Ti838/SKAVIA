import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/datasources/live_job_feed_datasource.dart';
import '../../data/models/requirement_model.dart';
import '../widgets/feed_category_chips.dart';
import '../widgets/feed_composer_prompt_card.dart';
import '../widgets/feed_filter_tabs.dart';
import '../widgets/feed_search_urgent_bar.dart';
import '../widgets/feed_skeleton_loader.dart';
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
  final LiveJobFeedDataSource _dataSource = LiveJobFeedDataSource();
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

  User? _safeCurrentUser() {
    try {
      return _authController.user;
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchLiveRequirements() async {
    setState(() => _isLoading = true);
    final fetched = await _dataSource.fetchOpenRequirements();
    if (mounted) {
      setState(() {
        _jobs = fetched;
        _isLoading = false;
      });
    }
  }

  List<JobRequirementItem> get _filteredJobs {
    final query = _searchController.text.trim().toLowerCase();
    return _jobs.where((job) {
      // 1. Post type filter
      if (_selectedPostType != 'All') {
        if (_selectedPostType == 'Jobs' && job.postType != 'Job') {
          return false;
        }
        if (_selectedPostType == 'Requests' &&
            job.postType != 'Service Request') {
          return false;
        }
        if (_selectedPostType == 'Updates' &&
            job.postType != 'Update' &&
            job.postType != 'Professional Update') {
          return false;
        }
      }

      // 2. Category filter
      if (_selectedCategory != 'All' &&
          !job.category.toLowerCase().contains(
            _selectedCategory.toLowerCase(),
          )) {
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

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final user = _safeCurrentUser();
    final userInitial = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName![0].toUpperCase()
        : (user?.email?.isNotEmpty ?? false)
            ? user!.email![0].toUpperCase()
            : 'U';

    return Scaffold(
      backgroundColor: widget.isTab ? colorScheme.surface : tokens.canvasBg,
      appBar: widget.isTab
          ? null
          : AppBar(
              backgroundColor: tokens.canvasBg,
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
        top: !widget.isTab,
        child: RefreshIndicator(
          color: tokens.brandAccent,
          onRefresh: _fetchLiveRequirements,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            slivers: [
              // 1. Post Composer Card
              SliverToBoxAdapter(
                child: FeedComposerPromptCard(
                  userInitial: userInitial,
                  onOpenComposer: _openPostComposer,
                  isBn: isBn,
                ),
              ),

              // 2. Post Type Filter Chips (All, Jobs, Requests, Updates)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: FeedFilterTabs(
                    selectedPostType: _selectedPostType,
                    onSelected: (key) =>
                        setState(() => _selectedPostType = key),
                    isBn: isBn,
                  ),
                ),
              ),

              // 2b. Trade Category Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FeedCategoryChips(
                    selectedCategory: _selectedCategory,
                    onSelected: (key) =>
                        setState(() => _selectedCategory = key),
                    isBn: isBn,
                  ),
                ),
              ),

              // 3. Search & Category Sub-bar
              SliverToBoxAdapter(
                child: FeedSearchUrgentBar(
                  searchController: _searchController,
                  onSearchChanged: (_) => setState(() {}),
                  onlyEmergency: _onlyEmergency,
                  onToggleEmergency: () =>
                      setState(() => _onlyEmergency = !_onlyEmergency),
                  isBn: isBn,
                ),
              ),

              // 4. Live Counter & Refresh Strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
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
                            Flexible(
                              child: Text(
                                '${_filteredJobs.length} ${isBn ? "টি পোস্ট সক্রিয়" : "Active Feed Posts"}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _fetchLiveRequirements,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 14,
                                color: tokens.brandAccent,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isBn ? 'রিফ্রেশ' : 'Refresh',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.brandAccent,
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

              // 5. Feed List or Loading / Empty States
              if (_isLoading)
                const SliverToBoxAdapter(child: FeedSkeletonLoader())
              else if (_filteredJobs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dynamic_feed_rounded,
                            size: 48,
                            color: tokens.mutedText,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isBn
                                ? 'কোনো পোস্ট পাওয়া যায়নি'
                                : 'No posts matching your filter',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isBn
                                ? 'নতুন কাজ পোস্ট করতে উপরের বোতাম ব্যবহার করুন'
                                : 'Use the composer above to share an opportunity',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tokens.brandAccent,
                              foregroundColor: tokens.onBrandAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: Text(
                              isBn ? 'পোস্ট তৈরি করুন' : 'Create Post',
                            ),
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
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final job = _filteredJobs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: JobRequirementFeedCard(
                          job: job,
                          onApply: () => _showBidBottomSheet(job),
                          onJobUpdated: (updated) {
                            setState(() {
                              final idx = _jobs.indexWhere(
                                (j) => j.id == updated.id,
                              );
                              if (idx != -1) _jobs[idx] = updated;
                            });
                          },
                        ),
                      );
                    }, childCount: _filteredJobs.length),
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
