import 'package:flutter/foundation.dart';

import '../../data/datasources/customer_remote_datasource.dart';
import '../../domain/entities/requirement_entity.dart';

/// Controller handling the multi-step posting of a customer service requirement.
class PostRequirementController extends ChangeNotifier {
  final CustomerRemoteDataSource _dataSource;

  PostRequirementController({CustomerRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? CustomerRemoteDataSource();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _createdRequirementId;
  String? get createdRequirementId => _createdRequirementId;

  Future<String?> submitRequirement({
    required String clientId,
    required String title,
    required String description,
    required String categoryId,
    required String location,
    required double budget,
    bool isComplex = false,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final req = RequirementEntity(
        requirementId: '',
        clientId: clientId,
        title: title,
        description: description,
        categoryId: categoryId,
        location: location,
        budget: budget,
        createdAt: DateTime.now(),
        isComplexProject: isComplex,
      );
      _createdRequirementId = await _dataSource.createRequirement(req);
      return _createdRequirementId;
    } catch (e) {
      debugPrint('[PostRequirementController] submitRequirement error: $e');
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
