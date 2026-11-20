import 'package:flutter/foundation.dart';

import '../../data/datasources/catalog_remote_datasource.dart';
import '../../data/models/category_model.dart';
import '../../data/models/service_model.dart';

class CatalogController extends ChangeNotifier {
  final CatalogRemoteDataSource _dataSource;

  List<CategoryModel> _categories = [];
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _selectedCategoryId = 'all';
  String _searchQuery = '';
  bool _isDisposed = false;
  String? _errorMessage;
  int _requestSequence = 0;

  CatalogController({
    CatalogRemoteDataSource? dataSource,
    String? initialCategoryId,
    String? initialSearchQuery,
  }) : _dataSource = dataSource ?? CatalogRemoteDataSource() {
    if (initialCategoryId != null && initialCategoryId.isNotEmpty) {
      _selectedCategoryId = initialCategoryId;
    }
    if (initialSearchQuery != null && initialSearchQuery.trim().isNotEmpty) {
      _searchQuery = initialSearchQuery.trim();
    }
    initCatalog();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  List<CategoryModel> get categories => _categories;
  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  bool get hasActiveFilter =>
      (_selectedCategoryId != null && _selectedCategoryId != 'all') ||
      _searchQuery.isNotEmpty;

  Future<void> initCatalog() async {
    final seq = ++_requestSequence;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedCategories = await _dataSource.getCategories();
      final fetchedServices = await _fetchServicesForCurrentFilters();
      if (seq != _requestSequence) return;
      _categories = fetchedCategories;
      _services = fetchedServices;
    } catch (e) {
      if (seq != _requestSequence) return;
      _errorMessage = 'Could not load the service catalogue. Please try again.';
    } finally {
      if (seq == _requestSequence) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<List<ServiceModel>> _fetchServicesForCurrentFilters() async {
    if (_searchQuery.isNotEmpty) {
      final results = await _dataSource.searchServices(_searchQuery);
      if (_selectedCategoryId != null && _selectedCategoryId != 'all') {
        return results
            .where((s) => s.categoryId == _selectedCategoryId)
            .toList();
      }
      return results;
    }
    return _dataSource.getServices(
      categoryId: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
    );
  }

  Future<void> filterByCategory(String? categoryId) async {
    final seq = ++_requestSequence;
    _selectedCategoryId = (categoryId == null || categoryId.isEmpty)
        ? 'all'
        : categoryId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _fetchServicesForCurrentFilters();
      if (seq != _requestSequence) return;
      _services = fetched;
    } catch (_) {
      if (seq != _requestSequence) return;
      _errorMessage = 'Could not filter services. Please try again.';
    } finally {
      if (seq == _requestSequence) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> search(String query) async {
    final seq = ++_requestSequence;
    _searchQuery = query.trim();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _fetchServicesForCurrentFilters();
      if (seq != _requestSequence) return;
      _services = fetched;
    } catch (_) {
      if (seq != _requestSequence) return;
      _errorMessage = 'Search failed. Please check your connection.';
    } finally {
      if (seq == _requestSequence) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    _searchQuery = '';
    filterByCategory(_selectedCategoryId);
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategoryId = 'all';
    initCatalog();
  }
}
