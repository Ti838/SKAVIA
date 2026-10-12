import 'package:flutter/foundation.dart';

import '../../data/datasources/catalog_remote_datasource.dart';
import '../../data/models/category_model.dart';
import '../../data/models/service_model.dart';

class CatalogController extends ChangeNotifier {
  final CatalogRemoteDataSource _dataSource = CatalogRemoteDataSource();

  List<CategoryModel> _categories = [];
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _selectedCategoryId = 'all';
  String _searchQuery = '';
  bool _isDisposed = false;
  String? _errorMessage;

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

  CatalogController() {
    initCatalog();
  }

  Future<void> initCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedCategories = await _dataSource.getCategories();
      final fetchedServices = await _dataSource.getServices();
      _categories = fetchedCategories;
      _services = fetchedServices;
    } catch (e) {
      _errorMessage = e.toString();
      _categories = CategoryModel.defaultCategories;
      _services = ServiceModel.defaultServices;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByCategory(String? categoryId) async {
    _selectedCategoryId = categoryId ?? 'all';
    _isLoading = true;
    notifyListeners();

    try {
      if (_searchQuery.isNotEmpty) {
        final results = await _dataSource.searchServices(_searchQuery);
        if (_selectedCategoryId != 'all') {
          _services = results
              .where((s) => s.categoryId == _selectedCategoryId)
              .toList();
        } else {
          _services = results;
        }
      } else {
        _services = await _dataSource.getServices(
          categoryId: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query.trim();
    _isLoading = true;
    notifyListeners();

    try {
      if (_searchQuery.isEmpty) {
        _services = await _dataSource.getServices(
          categoryId: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
        );
      } else {
        final results = await _dataSource.searchServices(_searchQuery);
        if (_selectedCategoryId != null && _selectedCategoryId != 'all') {
          _services = results
              .where((s) => s.categoryId == _selectedCategoryId)
              .toList();
        } else {
          _services = results;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    filterByCategory(_selectedCategoryId);
  }
}
