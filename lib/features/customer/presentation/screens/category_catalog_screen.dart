import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../shared/empty_states/empty_data_view.dart';
import '../../../../shared/error_states/error_view.dart';
import '../../../../shared/loaders/list_shimmer_skeleton.dart';
import '../../../../shared/widgets/skavia_search_field.dart';
import '../../data/models/service_model.dart';
import '../controllers/catalog_controller.dart';
import '../widgets/catalog_filter_pill.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final initialQuery = widget.initialSearchQuery?.trim();
    if (initialQuery != null && initialQuery.isNotEmpty) {
      _searchController.text = initialQuery;
    }
    _controller = CatalogController(
      initialCategoryId: widget.initialCategoryId,
      initialSearchQuery: initialQuery,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onBookService(ServiceModel service) {
    CatalogServiceDetailSheet.show(context, service);
  }

  void _selectCategory(String categoryId, {bool scrollToTop = false}) {
    _controller.filterByCategory(categoryId);
    if (scrollToTop && _scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: !widget.isTab,
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (!widget.isTab) ...[
                        IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).backButtonTooltip,
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          l10n.servicesAndCategories,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SkaviaSearchField(
                    controller: _searchController,
                    hintText: l10n.servicesSearchHint,
                    debounceDuration: const Duration(milliseconds: 250),
                    onChanged: _controller.search,
                    onClear: _controller.clearSearch,
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  if (_controller.isLoading && _controller.categories.isEmpty) {
                    return const ListShimmerSkeleton(itemCount: 4);
                  }

                  if (_controller.errorMessage != null &&
                      _controller.services.isEmpty &&
                      _controller.categories.isEmpty) {
                    return ErrorView(
                      title: l10n.servicesErrorTitle,
                      message: _controller.errorMessage!,
                      retryText: l10n.commonRetry,
                      onRetry: _controller.initCatalog,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _controller.initCatalog,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppDimensions.space16),
                        ),

                        // Horizontal Category Filter Chips
                        SliverToBoxAdapter(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                CatalogFilterPill(
                                  id: 'all',
                                  label: l10n.servicesAll,
                                  isSelected:
                                      _controller.selectedCategoryId == 'all',
                                  onSelected: _selectCategory,
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
                                    onSelected: _selectCategory,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 16)),

                        // Section Header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.servicesAvailableCount(_controller.services.length),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                  ),
                                ),
                                if (_controller.hasActiveFilter) ...[
                                  const SizedBox(width: 8),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _controller.resetFilters();
                                    },
                                    child: Text(l10n.commonReset),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 10)),

                        // Loading indicator for filter/search refresh
                        if (_controller.isLoading)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 28),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              ),
                            ),
                          )
                        else if (_controller.errorMessage != null)
                          SliverToBoxAdapter(
                            child: ErrorView(
                              scrollable: false,
                              title: l10n.servicesErrorTitle,
                              message: _controller.errorMessage!,
                              retryText: l10n.commonRetry,
                              onRetry: _controller.initCatalog,
                            ),
                          )
                        else if (_controller.services.isEmpty)
                          SliverToBoxAdapter(
                            child: EmptyDataView(
                              scrollable: false,
                              isFiltered: _controller.hasActiveFilter,
                              icon: Icons.grid_view_outlined,
                              title: _controller.hasActiveFilter
                                  ? l10n.servicesFilteredEmptyTitle
                                  : l10n.servicesEmptyTitle,
                              message: _controller.hasActiveFilter
                                  ? l10n.servicesFilteredEmptyMessage
                                  : l10n.servicesEmptyMessage,
                              actionText: _controller.hasActiveFilter
                                  ? l10n.commonClearFilters
                                  : null,
                              onAction: _controller.hasActiveFilter
                                  ? () {
                                      _searchController.clear();
                                      _controller.resetFilters();
                                    }
                                  : null,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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

                        if (_controller.categories.isNotEmpty) ...[
                          const SliverToBoxAdapter(child: SizedBox(height: 20)),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                AppLanguageService.tr('browse_by_trade'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 12)),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  onTap: () => _selectCategory(
                                    cat.categoryId,
                                    scrollToTop: true,
                                  ),
                                );
                              }, childCount: _controller.categories.length),
                            ),
                          ),
                        ],

                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 32,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: tokens.subtleCardBg.withValues(alpha: 0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
