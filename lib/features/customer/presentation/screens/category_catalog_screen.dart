import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../data/models/service_model.dart';
import '../controllers/catalog_controller.dart';
import '../widgets/catalog_service_card.dart';
import '../widgets/catalog_service_detail_sheet.dart';
import '../widgets/category_list_tile.dart';

class CategoryCatalogScreen extends StatefulWidget {
  final String? initialCategoryId;
  final String? initialSearchQuery;
  final bool isTab;

  const CategoryCatalogScreen({
    super.key,
    this.initialCategoryId,
    this.initialSearchQuery,
    this.isTab = false,
  });

  @override
  State<CategoryCatalogScreen> createState() => _CategoryCatalogScreenState();
}

class _CategoryCatalogScreenState extends State<CategoryCatalogScreen> {
  late final CatalogController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CatalogController();
    if (widget.initialSearchQuery != null &&
        widget.initialSearchQuery!.trim().isNotEmpty) {
      final query = widget.initialSearchQuery!.trim();
      _searchController.text = query;
      _controller.search(query);
    } else if (widget.initialCategoryId != null) {
      _controller.filterByCategory(widget.initialCategoryId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onBookService(ServiceModel service) {
    CatalogServiceDetailSheet.show(context, service);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar matching Screen 5 (Services & Categories)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  if (!widget.isTab) ...[
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ] else
                    const SizedBox(width: 8),
                  const Text(
                    'Services & Categories',
                    style: TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Search Bar Area matching Screen 5
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.sheetSurfaceSubtle,
                  borderRadius: AppDimensions.roundedPill,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => _controller.search(val),
                  style: const TextStyle(
                    fontFamily: AppTypography.bodyFont,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search for services...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textMedium,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: AppColors.textMedium,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _controller.clearSearch();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // White Sheet Content
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    if (_controller.isLoading &&
                        _controller.categories.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primarySky,
                        ),
                      );
                    }

                    return CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),

                        // Horizontal Category Filter Pills
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 42,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              children: [
                                _buildFilterPill(
                                  id: 'all',
                                  label: 'All Services',
                                  isSelected:
                                      _controller.selectedCategoryId == 'all',
                                ),
                                ..._controller.categories.map((cat) {
                                  return _buildFilterPill(
                                    id: cat.categoryId,
                                    label: cat.name,
                                    isSelected:
                                        _controller.selectedCategoryId ==
                                        cat.categoryId,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 20)),

                        // Services List Header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Available Services (${_controller.services.length})',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.headingFont,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                if (_controller.selectedCategoryId != 'all')
                                  GestureDetector(
                                    onTap: () =>
                                        _controller.filterByCategory('all'),
                                    child: const Text(
                                      'Reset Filter',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primarySky,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        // Services List or Empty State
                        if (_controller.services.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 40,
                                horizontal: 20,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 64,
                                    color: AppColors.textMuted.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'No services found',
                                    style: TextStyle(
                                      fontFamily: AppTypography.headingFont,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Try searching for different keywords like AC, electric, plumbing...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final service = _controller.services[index];
                                return CatalogServiceCard(
                                  service: service,
                                  onBook: () => _onBookService(service),
                                );
                              }, childCount: _controller.services.length),
                            ),
                          ),

                        const SliverToBoxAdapter(child: SizedBox(height: 24)),

                        // Categories Showcase Header
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Browse by Trade Specialization',
                              style: TextStyle(
                                fontFamily: AppTypography.headingFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 14)),

                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final cat = _controller.categories[index];
                              return CategoryListTile(
                                category: cat,
                                isSelected:
                                    _controller.selectedCategoryId ==
                                    cat.categoryId,
                                onTap: () => _controller.filterByCategory(
                                  cat.categoryId,
                                ),
                              );
                            }, childCount: _controller.categories.length),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 36)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String id,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _controller.filterByCategory(id),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRoyal : Colors.white,
          borderRadius: AppDimensions.roundedPill,
          border: Border.all(
            color: isSelected ? AppColors.primaryRoyal : AppColors.borderLight,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryRoyal.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.bodyFont,
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
