import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/datasources/job_feed_seed_data.dart';
import '../../data/models/requirement_model.dart';
import '../widgets/job_requirement_feed_card.dart';
import '../widgets/live_job_bid_sheet.dart';
import '../widgets/live_job_feed_filter_bar.dart';

export '../../data/models/requirement_model.dart';

/// Live Jobs & Requirements Feed Screen
/// Aligned with SKAVIA SRS Section 3.1.E, 3.1.G & 3.1.H.
/// Allows workers to browse live client requirements, filter by trade/city,
/// and submit direct bids; allows clients to explore active marketplace posts.
class LiveJobFeedScreen extends StatefulWidget {
  final bool isTab;

  const LiveJobFeedScreen({super.key, this.isTab = false});

  @override
  State<LiveJobFeedScreen> createState() => _LiveJobFeedScreenState();
}

class _LiveJobFeedScreenState extends State<LiveJobFeedScreen> {
  final AuthController _authController = AuthController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategoryFilter = 'All';
  bool _onlyEmergency = false;
  bool _isLoading = false;

  List<JobRequirementItem> _jobs = [];
  List<JobRequirementItem> get _seedJobs => JobFeedSeedData.seedJobs;

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
    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('requirements')
          .select(
            'requirement_id, title, description, location, budget, status, created_at, category_id',
          )
          .eq('status', 'Open')
          .order('created_at', ascending: false)
          .limit(20);

      List<JobRequirementItem> fetched = [];
      if (res.isNotEmpty) {
        for (final row in res) {
          final id = row['requirement_id']?.toString() ?? 'req';
          final title = row['title']?.toString() ?? 'Service Requirement';
          final desc = row['description']?.toString() ?? '';
          final loc = row['location']?.toString() ?? 'Dhaka, Bangladesh';
          final budget = (row['budget'] as num?)?.toDouble() ?? 1500.0;
          final catId = row['category_id']?.toString() ?? 'cat_electrical';

          String catName = 'Electrical';
          if (catId.contains('ac') || catId.contains('hvac')) {
            catName = 'HVAC & AC';
          }
          if (catId.contains('plumb')) catName = 'Plumbing';
          if (catId.contains('carpent')) catName = 'Carpentry';

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
            ),
          );
        }
      }

      setState(() {
        _jobs = [...fetched, ..._seedJobs];
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _jobs = List.from(_seedJobs);
        _isLoading = false;
      });
    }
  }

  List<JobRequirementItem> get _filteredJobs {
    final query = _searchController.text.trim().toLowerCase();
    return _jobs.where((job) {
      if (_selectedCategoryFilter != 'All' &&
          !job.category.toLowerCase().contains(
            _selectedCategoryFilter.toLowerCase(),
          )) {
        return false;
      }
      if (_onlyEmergency && !job.urgency.toLowerCase().contains('emergency')) {
        return false;
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

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;

    return Scaffold(
      backgroundColor: widget.isTab ? Colors.white : AppColors.canvasBlue,
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
                isBn ? 'লাইভ কাজের ফিড' : 'Live Jobs Feed',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.post_add_rounded, color: Colors.white),
                  tooltip: 'Post Requirement',
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.postRequirement),
                ),
              ],
            ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar & Filters Header
            LiveJobFeedFilterBar(
              searchController: _searchController,
              selectedCategory: _selectedCategoryFilter,
              onlyEmergency: _onlyEmergency,
              onCategoryChanged: (cat) =>
                  setState(() => _selectedCategoryFilter = cat),
              onToggleEmergency: () =>
                  setState(() => _onlyEmergency = !_onlyEmergency),
              onSearchChanged: () => setState(() {}),
            ),

            // 2. Job Posts Count & Live Status Strip
            Padding(
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
                        '${_filteredJobs.length} ${isBn ? "টি সক্রিয় কাজের সুযোগ" : "Open Job Opportunities"}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
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
            const SizedBox(height: 4),

            // 3. Scrollable List of Job Requirement Cards
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryRoyal,
                      ),
                    )
                  : _filteredJobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isBn
                                ? 'কোনো কাজ পাওয়া যায়নি'
                                : 'No matching jobs found',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                      itemCount: _filteredJobs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        final job = _filteredJobs[index];
                        return JobRequirementFeedCard(
                          job: job,
                          onApply: () => _showBidBottomSheet(job),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // Floating Action Button to Post Requirement
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryRoyal,
        elevation: 3,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white, size: 18),
        label: Text(
          isBn ? 'কাজ পোস্ট করুন' : 'Post a Job',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.postRequirement),
      ),
    );
  }
}
