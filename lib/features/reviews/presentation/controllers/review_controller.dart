import 'package:flutter/foundation.dart';

import '../../data/datasources/review_remote_datasource.dart';

/// Controller managing review submission and worker reputation retrieval.
class ReviewController extends ChangeNotifier {
  final ReviewRemoteDataSource _dataSource;

  ReviewController({ReviewRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? ReviewRemoteDataSource();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<bool> submitReview({
    required String reviewerId,
    required String workerProfileId,
    required double rating,
    required String comment,
    String? serviceRequestId,
    String? projectId,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final success = await _dataSource.submitReview(
        workerProfileId: workerProfileId,
        clientId: reviewerId,
        rating: rating.round(),
        comment: comment,
        serviceRequestId: serviceRequestId,
        projectId: projectId,
      );
      return success;
    } catch (e) {
      debugPrint('[ReviewController] submitReview notice: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
