import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/empty_states/empty_data_view.dart';
import '../../../../shared/error_states/error_view.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
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

/// Live Jobs & Community Feed Screen.
/// Features a single clean composer (zero overlapping FABs), clear post-type &
/// trade filter hierarchy, pagination, pull-to-refresh, and distinct empty /
/// filtered-empty / error states.
class LiveJobFeedScreen extends StatefulWidget {
  final bool isTab;

  const LiveJobFeedScreen({super.key, this.isTab = false});

  @override
  State<LiveJobFeedScreen> createState() => _LiveJobFeedScreenState();
}

class _LiveJobFeedScreenState extends State<LiveJobFeedScreen> {
  static const int _pageSize = 20;

  final AuthController _authController = AuthController();
  final LiveJobFeedDataSource _dataSource = LiveJobFeedDataSource();
  final TextEditingController _searchController = TextEditingController();

  String _selectedPostType = 'All';
  String _selectedCategory = 'All';
  bool _onlyEmergency = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  bool _hasError = false;

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

  bool get _hasActiveFilter =>
      _selectedPostType != 'All' ||
      _selectedCategory != 'All' ||
      _onlyEmergency ||
      _searchController.text.trim().isNotEmpty;

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedPostType = 'All';
      _selectedCategory = 'All';
      _onlyEmergency = false;
    });
  }

  Future<void> _fetchLiveRequirements() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final fetched = await _dataSource.fetchOpenRequirements(
        limit: _pageSize,
        offset: 0,
      );
      if (mounted) {
        setState(() {
          _jobs = fetched;
          _hasMore = fetched.length == _pageSize;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final more = await _dataSource.fetchOpenRequirements(
        limit: _pageSize,
        offset: _jobs.length,
      );
      if (mounted) {
        setState(() {
          final existingIds = _jobs.map((j) => j.id).toSet();
          _jobs.addAll(more.where((item) => !existingIds.contains(item.id)));
          _hasMore = more.length == _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  List<JobRequirementItem> get _filteredJobs {
    final query = _searchController.text.trim().toLowerCase();
    return _jobs.where((job) {
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

      if (_selectedCategory != 'All' &&
          !job.category.toLowerCase().contains(
            _selectedCategory.toLowerCase(),
          )) {
        return false;
      }

      if (_onlyEmergency) {
        final urg = job.urgency.toLowerCase();
        if (!urg.contains('emergency') && !urg.contains('high')) {
          return false;
        }
      }

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

  void _openPostComposer({String initialPostType = 'Job'}) {
    PostComposerSheet.show(
      context,
      initialPostType: initialPostType,
      onPostCreated: (newItem) {
        setState(() {
          _jobs.insert(0, newItem);
          _hasError = false;
        });
        _fetchLiveRequirements();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isBn = context.isBengali;
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final user = _safeCurrentUser();
    final profile = ProfileController.shared.profile;
    final effectiveAvatar =
        (profile?.avatarUrl != null && profile!.avatarUrl!.trim().isNotEmpty)
        ? profile.avatarUrl
        : user?.photoURL;
    final effectiveName =
        (profile != null &&
            profile.fullName.trim().isNotEmpty &&
            profile.fullName.trim() != 'SKAVIA Member')
        ? profile.fullName.trim()
        : (user?.displayName?.trim().isNotEmpty == true
              ? user!.displayName!.trim()
              : (user?.email ?? ''));
    final userInitial = effectiveName.isNotEmpty
        ? effectiveName[0].toUpperCase()
        : 'U';

    final filtered = _filteredJobs;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.isTab
          ? null
          : AppAppBar(
              title: l10n.feedTitle,
            ),
      body: SafeArea(
        top: !widget.isTab,
        child: RefreshIndicator(
          color: colorScheme.primary,
          onRefresh: _fetchLiveRequirements,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            slivers: [
              // 1. Single Clean Post Composer Card
              SliverToBoxAdapter(
                child: FeedComposerPromptCard(
                  userInitial: userInitial,
                  userName: effectiveName,
                  userAvatarUrl: effectiveAvatar,
                  onOpenComposer: () => _openPostComposer(),
                  onOpenComposerWithType: (type) =>
                      _openPostComposer(initialPostType: type),
                  isBn: isBn,
                ),
              ),

              // 2. Primary Post Type Filter Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FeedFilterTabs(
                    selectedPostType: _selectedPostType,
                    onSelected: (key) =>
                        setState(() => _selectedPostType = key),
                    isBn: isBn,
                  ),
                ),
              ),

              // 3. Secondary Trade Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FeedCategoryChips(
                    selectedCategory: _selectedCategory,
                    onSelected: (key) =>
                        setState(() => _selectedCategory = key),
                    isBn: isBn,
                  ),
                ),
              ),

              // 4. Search & Urgent Filter Bar
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

              // 5. Status & Active Filter Strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: filtered.isNotEmpty
                              ? tokens.tealAccent
                              : tokens.mutedText,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.feedActivePostsCount(filtered.length),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (_hasActiveFilter)
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: _clearFilters,
                          child: Text(l10n.commonClearFilters),
                        ),
                    ],
                  ),
                ),
              ),

              // 6. Distinct Loading / Error / Empty / Filtered-Empty / Feed States
              if (_isLoading)
                const SliverToBoxAdapter(child: FeedSkeletonLoader())
              else if (_hasError)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ErrorView(
                      scrollable: false,
                      title: l10n.feedErrorTitle,
                      message: l10n.commonConnectionError,
                      retryText: l10n.commonRetry,
                      onRetry: _fetchLiveRequirements,
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: EmptyDataView(
                      scrollable: false,
                      isFiltered: _hasActiveFilter,
                      icon: Icons.dynamic_feed_outlined,
                      title: _hasActiveFilter
                          ? l10n.feedFilteredEmptyTitle
                          : l10n.feedEmptyTitle,
                      message: _hasActiveFilter
                          ? l10n.feedFilteredEmptyMessage
                          : l10n.feedEmptyMessage,
                      actionText: _hasActiveFilter
                          ? l10n.commonClearFilters
                          : l10n.feedCreatePost,
                      onAction: _hasActiveFilter
                          ? _clearFilters
                          : _openPostComposer,
                    ),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final job = filtered[index];
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
                    }, childCount: filtered.length),
                  ),
                ),
                if (_hasMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                      child: AppButton(
                        text: isBn ? 'আরো পোস্ট দেখুন' : 'Load More Posts',
                        variant: AppButtonVariant.outline,
                        isLoading: _isLoadingMore,
                        onPressed: _isLoadingMore ? null : _loadMore,
                        height: 44,
                      ),
                    ),
                  )
                else
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.space24),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
