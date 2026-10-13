import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/core/services/location_service.dart';
import 'package:skavia/core/services/skavia_ai_service.dart';
import 'package:skavia/features/customer/data/models/requirement_model.dart';

void main() {
  group('SKAVIA Social Feed & Map Location Unit Tests', () {
    test('JobRequirementItem copyWith correctly updates like and comment counters', () {
      final initialJob = JobRequirementItem(
        id: 'job_001',
        title: 'Emergency AC Repair',
        category: 'HVAC & AC',
        categoryId: 'cat_ac_hvac',
        description: 'AC compressor not cooling, urgent fix needed',
        location: 'Gulshan 2, Dhaka',
        budgetMin: 1500,
        budgetMax: 2500,
        urgency: 'Emergency (2 hours)',
        timeAgo: '10m ago',
        clientName: 'Tanvir Hossain',
        likesCount: 5,
        isLikedByMe: false,
        commentsCount: 2,
        isSavedByMe: false,
      );

      final likedJob = initialJob.copyWith(
        isLikedByMe: true,
        likesCount: initialJob.likesCount + 1,
      );

      expect(likedJob.isLikedByMe, isTrue);
      expect(likedJob.likesCount, equals(6));
      expect(likedJob.commentsCount, equals(2));

      final commentedJob = likedJob.copyWith(
        commentsCount: likedJob.commentsCount + 1,
      );

      expect(commentedJob.commentsCount, equals(3));
      expect(commentedJob.isSavedByMe, isFalse);

      final bookmarkedJob = commentedJob.copyWith(isSavedByMe: true);
      expect(bookmarkedJob.isSavedByMe, isTrue);
    });

    test('LocationService.calculateDistanceKm accurately calculates Dhaka geographical distances', () {
      // Dhanmondi 27 (23.7540, 90.3742) to Gulshan 1 (23.7925, 90.4078)
      final distanceKm = LocationService.calculateDistanceKm(
        23.7540,
        90.3742,
        23.7925,
        90.4078,
      );

      // Distance should be approximately 5.6 km
      expect(distanceKm, greaterThan(4.0));
      expect(distanceKm, lessThan(7.0));

      // Same point distance should be 0.0
      final zeroDistance = LocationService.calculateDistanceKm(
        23.7540,
        90.3742,
        23.7540,
        90.3742,
      );
      expect(zeroDistance, equals(0.0));
    });

    test('SkaviaAiService.diagnoseRequirement returns structured diagnosis matching SRS requirements', () async {
      final aiService = SkaviaAiService();
      final diagnosis = await aiService.diagnoseRequirement(
        'AC fan motor stopped spinning and making humming noise in Dhanmondi',
      );

      expect(diagnosis, isNotNull);
      final res = diagnosis!;
      expect(res['category_id'], equals('cat_ac_hvac'));
      expect(res['suggested_title'], isNotEmpty);
      expect(res['budget_estimate'], isNotNull);
      expect((res['budget_estimate'] as num).toDouble(), greaterThan(0));
      expect(res['skills'], isA<List>());
    });
  });
}
