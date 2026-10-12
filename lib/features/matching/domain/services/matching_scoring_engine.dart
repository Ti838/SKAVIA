import '../entities/match_result_entity.dart';

/// Algorithmic Matching Scoring Engine.
/// Implements the exact weighted scoring model defined in SKAVIA SRS Section 3.1.G (FR-G01 - FR-G04):
/// Total Match Score = (0.40 * S_skill) + (0.25 * S_loc) + (0.20 * S_rat) + (0.15 * S_rate)
class MatchingScoringEngine {
  static const double weightSkill = 0.40;
  static const double weightLocation = 0.25;
  static const double weightRating = 0.20;
  static const double weightRate = 0.15;

  /// Calculate granular component scores and overall weighted match score
  static double calculateTotalScore({
    required double skillScore,
    required double locationScore,
    required double ratingScore,
    required double rateScore,
  }) {
    final total =
        (skillScore.clamp(0.0, 100.0) * weightSkill) +
        (locationScore.clamp(0.0, 100.0) * weightLocation) +
        (ratingScore.clamp(0.0, 100.0) * weightRating) +
        (rateScore.clamp(0.0, 100.0) * weightRate);
    return double.parse(total.toStringAsFixed(1));
  }

  /// Evaluates location proximity between requirement location and worker location
  static double evaluateLocationScore({
    required String requirementZone,
    required String workerZone,
  }) {
    if (requirementZone.trim().toLowerCase() ==
        workerZone.trim().toLowerCase()) {
      return 100.0; // Perfect local match
    }
    if (workerZone.toLowerCase().contains('all dhaka') ||
        requirementZone.toLowerCase().contains('all dhaka')) {
      return 85.0; // Broad metropolitan coverage
    }
    // Partial neighborhood match
    final reqWords = requirementZone.toLowerCase().split(' ');
    final wrkWords = workerZone.toLowerCase().split(' ');
    for (final rw in reqWords) {
      if (rw.isNotEmpty && wrkWords.contains(rw)) {
        return 75.0;
      }
    }
    return 60.0; // Same city baseline
  }

  /// Evaluates rate alignment score relative to client's planned budget/hourly rate
  static double evaluateRateScore({
    required double expectedRate,
    required double clientBudget,
  }) {
    if (clientBudget <= 0) return 85.0; // No strict budget constraint
    if (expectedRate <= clientBudget) {
      return 100.0; // Within or below budget
    }
    final ratio = (expectedRate - clientBudget) / clientBudget;
    final score = 100.0 - (ratio * 100.0);
    return score.clamp(30.0, 100.0);
  }

  /// Evaluates rating score (5.0 scale -> 100 scale)
  static double evaluateRatingScore(double rating) {
    final clamped = rating.clamp(0.0, 5.0);
    return (clamped / 5.0) * 100.0;
  }

  /// Scores and ranks a raw list of candidate worker profiles against a submitted requirement
  static List<MatchResultEntity> rankCandidates({
    required String requirementId,
    required String requirementZone,
    required double clientBudget,
    required List<Map<String, dynamic>> rawWorkers,
  }) {
    final matches = <MatchResultEntity>[];

    for (int i = 0; i < rawWorkers.length; i++) {
      final worker = rawWorkers[i];
      final workerLocation = worker['location']?.toString() ?? 'Dhaka';
      final workerRate = (worker['expected_rate'] as num?)?.toDouble() ?? 500.0;
      final workerRating =
          (worker['rating_average'] as num?)?.toDouble() ?? 4.8;
      final isVerified =
          worker['verification_status'] == 'Verified' ||
          worker['is_verified'] == true;

      // Component scores
      final skillScore = isVerified ? 95.0 : 80.0;
      final locScore = evaluateLocationScore(
        requirementZone: requirementZone,
        workerZone: workerLocation,
      );
      final ratScore = evaluateRatingScore(workerRating);
      final rateScore = evaluateRateScore(
        expectedRate: workerRate,
        clientBudget: clientBudget,
      );

      final totalScore = calculateTotalScore(
        skillScore: skillScore,
        locationScore: locScore,
        ratingScore: ratScore,
        rateScore: rateScore,
      );

      matches.add(
        MatchResultEntity(
          matchId: 'match_${DateTime.now().millisecondsSinceEpoch}_$i',
          requirementId: requirementId,
          workerProfileId:
              worker['worker_profile_id']?.toString() ??
              worker['user_id']?.toString() ??
              'w_$i',
          matchScore: totalScore,
          rankPosition: 0, // Will be assigned after sorting
          skillScore: skillScore,
          distanceScore: locScore,
          ratingScore: ratScore,
          rateScore: rateScore,
          workerName:
              worker['full_name']?.toString() ??
              worker['users']?['full_name']?.toString() ??
              'Specialist $i',
          avatarUrl:
              worker['avatar_url']?.toString() ??
              worker['users']?['avatar_url']?.toString(),
          tradeTitle: worker['title']?.toString() ?? 'Certified Specialist',
          location: workerLocation,
          hourlyRate: workerRate,
          rating: workerRating,
          completedJobs: (worker['completed_jobs'] as num?)?.toInt() ?? 12,
          isVerified: isVerified,
          skills:
              (worker['skills'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              ['Technical Specialist', 'Standard SLA'],
        ),
      );
    }

    // Sort descending by matchScore
    matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    // Assign rank positions
    return List.generate(matches.length, (index) {
      final item = matches[index];
      return MatchResultEntity(
        matchId: item.matchId,
        requirementId: item.requirementId,
        workerProfileId: item.workerProfileId,
        matchScore: item.matchScore,
        rankPosition: index + 1,
        skillScore: item.skillScore,
        distanceScore: item.distanceScore,
        ratingScore: item.ratingScore,
        rateScore: item.rateScore,
        workerName: item.workerName,
        avatarUrl: item.avatarUrl,
        tradeTitle: item.tradeTitle,
        location: item.location,
        hourlyRate: item.hourlyRate,
        rating: item.rating,
        completedJobs: item.completedJobs,
        isVerified: item.isVerified,
        skills: item.skills,
      );
    });
  }
}
