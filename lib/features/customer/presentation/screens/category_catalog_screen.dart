import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/app_language_service.dart';
import '../../data/models/service_model.dart';
import '../controllers/catalog_controller.dart';
import '../widgets/catalog_filter_pill.dart';
import '../widgets/catalog_search_bar.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        top: !widget.isTab,
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
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ] else
                    const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLanguageService.tr('services_and_categories'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar Area matching Screen 5
            CatalogSearchBar(
              controller: _searchController,
              onChanged: (val) => _controller.search(val),
              onClear: () {
                _searchController.clear();
                _controller.clearSearch();
              },
            ),

            // Content Area
            Expanded(
              child: Container(
                width: double.infinity,
                color: colorScheme.surface,
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
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                CatalogFilterPill(
                                  id: 'all',
                                  label: AppLanguageService.tr('all_services'),
                                  isSelected:
                                      _controller.selectedCategoryId == 'all',
                                  onSelected: (id) =>
                                      _controller.filterByCategory(id),
                                ),
                                ..._controller.categories.map((cat) {
                                  return CatalogFilterPill(
                                    id: cat.categoryId,
                                    label: AppLanguageService.getCategoryName(
                                      cat.slug,
                                      cat.name,
                                    ),
                                    isSelected:
                                        _controller.selectedCategoryId ==
                                        cat.categoryId,
                                    onSelected: (id) =>
                                        _controller.filterByCategory(id),
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
                              children: [
                                Expanded(
                                  child: Text(
                                    '${AppLanguageService.tr('available_services')} (${_controller.services.length})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: AppTypography.headingFont,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (_controller.selectedCategoryId != 'all') ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () =>
                                        _controller.filterByCategory('all'),
                                    child: Text(
                                      AppLanguageService.tr('reset_filter'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? colorScheme.primary
                                            : AppColors.primarySky,
                                      ),
                                    ),
                                  ),
                                ],
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
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'No services found',
                                    style: TextStyle(
                                      fontFamily: AppTypography.headingFont,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Try searching for different keywords like AC, electric, plumbing...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.onSurfaceVariant,
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
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              AppLanguageService.tr('browse_by_trade'),
                              style: TextStyle(
                                fontFamily: AppTypography.headingFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
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
}
