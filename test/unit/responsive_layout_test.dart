import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/features/customer/data/models/service_model.dart';
import 'package:skavia/features/customer/presentation/widgets/candidate_match_card.dart';
import 'package:skavia/features/customer/presentation/widgets/catalog_service_card.dart';
import 'package:skavia/features/matching/domain/entities/match_result_entity.dart';
import 'package:skavia/features/navigation/presentation/screens/main_scaffold_screen.dart';
import 'package:skavia/features/navigation/presentation/widgets/dashboard_bottom_nav_bar.dart';
import 'package:skavia/features/team_project/presentation/widgets/team_member_tile.dart';
import 'package:skavia/shared/widgets/app_button.dart';

void main() {
  group('SKAVIA UI Responsiveness & Zero Overflow Verification Suite', () {
    testWidgets('AppButton renders without overflow under severe width constraint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 90,
                child: AppButton(
                  text: 'Super Long Button Action Label That Exceeds Width',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(AppButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DashboardBottomNavBar renders on 320dp screen with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: DashboardBottomNavBar(
              currentIndex: 0,
              currentMode: AppRoleMode.customer,
              onTabSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(DashboardBottomNavBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CandidateMatchCard renders on 320dp screen without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const candidate = MatchResultEntity(
        matchId: 'm1',
        requirementId: 'r1',
        workerProfileId: 'w1',
        matchScore: 94.5,
        rankPosition: 1,
        workerName: 'Md. Saifuddin Chowdhury Senior Electrician',
        tradeTitle: 'Master Electrician & Industrial Automation Specialist',
        location: 'Bashundhara Residential Area Block-C, Dhaka, Bangladesh',
        hourlyRate: 850.0,
        rating: 4.95,
        completedJobs: 142,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CandidateMatchCard(
                candidate: candidate,
                requirementTitle: 'Complex Industrial Wiring & Substation Inspection',
                requirementZone: 'Bashundhara R/A',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CandidateMatchCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CatalogServiceCard renders on 320dp screen without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const service = ServiceModel(
        serviceId: 's1',
        categoryId: 'c1',
        name: 'Full Home Air Conditioner Overhaul & Gas Refill Service',
        description: 'Comprehensive cooling test, chemical foam coil cleanup and diagnostics',
        basePrice: 2500,
        estimatedDuration: '3-4 Hours Extended',
        ratingAverage: 4.88,
        totalBookings: 320,
        popularBadge: 'Top Rated',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CatalogServiceCard(
                service: service,
                onBook: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CatalogServiceCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TeamMemberTile renders long names on 320dp screen without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TeamMemberTile(
              member: {
                'name': 'Dr. Mohammad Shafiur Rahman Chowdhury',
                'role': 'Chief Lead Infrastructure Architect & Safety Coordinator',
                'isLeader': true,
              },
            ),
          ),
        ),
      );

      expect(find.byType(TeamMemberTile), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
