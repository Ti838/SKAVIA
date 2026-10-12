import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/features/matching/domain/services/matching_scoring_engine.dart';

void main() {
  group(
    'SKAVIA SRS Section 3.1.G — Algorithmic Matching Scoring Engine Unit Tests',
    () {
      test('FR-G01: Matches evaluate with exact formula weights (0.40, 0.25, 0.20, 0.15)', () {
        final score = MatchingScoringEngine.calculateTotalScore(
          skillScore: 100.0,
          locationScore: 100.0,
          ratingScore: 100.0,
          rateScore: 100.0,
        );
        expect(score, equals(100.0));

        // Test custom components: (90*0.4)+(80*0.25)+(100*0.20)+(60*0.15) = 36 + 20 + 20 + 9 = 85.0
        final customScore = MatchingScoringEngine.calculateTotalScore(
          skillScore: 90.0,
          locationScore: 80.0,
          ratingScore: 100.0,
          rateScore: 60.0,
        );
        expect(customScore, equals(85.0));
      });

      test(
        'FR-G01: Location proximity score evaluates higher for identical zone',
        () {
          final exactScore = MatchingScoringEngine.evaluateLocationScore(
            requirementZone: 'Mirpur, Dhaka',
            workerZone: 'Mirpur, Dhaka',
          );
          expect(exactScore, equals(100.0));

          final metroScore = MatchingScoringEngine.evaluateLocationScore(
            requirementZone: 'Gulshan, Dhaka',
            workerZone: 'All Dhaka City',
          );
          expect(metroScore, equals(85.0));
        },
      );

      test('FR-G01: Rate alignment score awards 100% when worker rate is within client budget', () {
        final withinBudgetScore = MatchingScoringEngine.evaluateRateScore(
          expectedRate: 500.0,
          clientBudget: 600.0,
        );
        expect(withinBudgetScore, equals(100.0));

        final overBudgetScore = MatchingScoringEngine.evaluateRateScore(
          expectedRate: 800.0,
          clientBudget: 600.0,
        );
        expect(overBudgetScore, lessThan(100.0));
      });

      test('FR-G02: rankCandidates returns candidates sorted descending by match score', () {
        final rawCandidates = [
          {
            'worker_profile_id': 'w1',
            'full_name': 'Candidate A',
            'location': 'Uttara, Dhaka',
            'expected_rate': 900.0,
            'rating_average': 4.5,
            'verification_status': 'Pending',
          },
          {
            'worker_profile_id': 'w2',
            'full_name': 'Candidate B (Ideal)',
            'location': 'Mirpur, Dhaka',
            'expected_rate': 500.0,
            'rating_average': 5.0,
            'verification_status': 'Verified',
          },
        ];

        final results = MatchingScoringEngine.rankCandidates(
          requirementId: 'req_001',
          requirementZone: 'Mirpur, Dhaka',
          clientBudget: 600.0,
          rawWorkers: rawCandidates,
        );

        expect(results.length, equals(2));
        expect(results.first.rankPosition, equals(1));
        expect(results.first.workerName, equals('Candidate B (Ideal)'));
        expect(results.first.matchScore, greaterThan(results.last.matchScore));
      });
    },
  );
}
