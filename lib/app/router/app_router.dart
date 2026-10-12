import 'package:flutter/material.dart';

import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/authentication/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/authentication/presentation/screens/otp_verification_screen.dart';
import '../../features/customer/presentation/screens/category_catalog_screen.dart';
import '../../features/customer/presentation/screens/post_requirement_screen.dart';
import '../../features/customer/presentation/screens/candidate_matches_screen.dart';
import '../../features/customer/presentation/screens/booking_confirmation_screen.dart';
import '../../features/worker/presentation/screens/worker_edit_profile_screen.dart';
import '../../features/worker/presentation/screens/worker_profile_detail_screen.dart';
import '../../features/worker/presentation/screens/incoming_requests_screen.dart';
import '../../features/worker/presentation/screens/worker_earnings_screen.dart';
import '../../features/team_project/presentation/screens/project_dashboard_screen.dart';
import '../../features/team_project/presentation/screens/team_discovery_screen.dart';
import '../../features/team_project/presentation/screens/project_showcase_screen.dart';
import '../../features/team_project/presentation/screens/admin_dashboard_screen.dart';
import '../../features/navigation/presentation/screens/main_scaffold_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/reviews/presentation/screens/submit_review_screen.dart';
import '../../features/reviews/presentation/screens/worker_reputation_screen.dart';
import '../../features/ai_assistant/presentation/screens/skavia_ai_screen.dart';
import '../../features/customer/presentation/screens/live_job_feed_screen.dart';
import 'app_routes.dart';

abstract class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.otpVerify:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: args?['phoneNumber'] as String?,
            fullName: args?['fullName'] as String?,
          ),
        );

      case AppRoutes.categoryCatalog:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CategoryCatalogScreen(
            initialCategoryId:
                (args?['categoryId'] ?? args?['category']) as String?,
            initialSearchQuery: args?['searchQuery'] as String?,
          ),
        );

      case AppRoutes.postRequirement:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PostRequirementScreen(
            preselectedCategory: args?['categoryId'] as String?,
          ),
        );

      case AppRoutes.candidateMatches:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CandidateMatchesScreen(
            requirementId: args?['requirementId'] as String? ?? 'req_temp',
            requirementTitle:
                args?['requirementTitle'] as String? ?? 'Service Requirement',
            requirementZone: args?['requirementZone'] as String? ?? 'Dhaka',
            budget: (args?['budget'] as num?)?.toDouble() ?? 1000.0,
            isComplexProject: args?['isComplexProject'] as bool? ?? false,
          ),
        );

      case AppRoutes.workerProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args?['isEdit'] == true) {
          return MaterialPageRoute(
            builder: (_) => const WorkerEditProfileScreen(),
          );
        }
        return MaterialPageRoute(
          builder: (_) => WorkerProfileDetailScreen(
            name: args?['name'] as String? ?? 'Rahul Ahmed',
            title: args?['title'] as String? ?? 'Flutter Developer',
            rating: (args?['rating'] as num?)?.toDouble() ?? 4.8,
            reviewsCount: (args?['reviewsCount'] as num?)?.toInt() ?? 32,
            experience: args?['experience'] as String? ?? '2+ years',
            location: args?['location'] as String? ?? 'Dhaka, Bangladesh',
            hourlyRate: args?['hourlyRate'] as String? ?? '\$15/hr',
          ),
        );

      case AppRoutes.incomingRequests:
        return MaterialPageRoute(
          builder: (_) => const IncomingRequestsScreen(),
        );

      case AppRoutes.workerEarnings:
        return MaterialPageRoute(builder: (_) => const WorkerEarningsScreen());

      case AppRoutes.projectDashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProjectDashboardScreen(
            projectId: args?['projectId'] as String? ?? 'proj_001',
            projectTitle:
                args?['projectTitle'] as String? ??
                'Complete Turnkey Business Project',
          ),
        );

      case AppRoutes.chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());

      case AppRoutes.chatRoom:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            conversationId: args?['conversationId'] as String? ?? '',
            otherParticipantName:
                args?['otherParticipantName'] as String? ?? 'SKAVIA Member',
            otherParticipantAvatar: args?['otherParticipantAvatar'] as String?,
            otherParticipantId: args?['otherParticipantId'] as String? ?? '',
          ),
        );

      case AppRoutes.submitReview:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SubmitReviewScreen(
            workerProfileId: args?['workerProfileId'] as String? ?? '',
            workerName: args?['workerName'] as String? ?? 'Specialist',
            workerAvatar: args?['workerAvatar'] as String?,
            serviceRequestId: args?['serviceRequestId'] as String?,
            projectId: args?['projectId'] as String?,
          ),
        );

      case AppRoutes.workerReputation:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => WorkerReputationScreen(
            workerProfileId: args?['workerProfileId'] as String?,
            workerName: args?['workerName'] as String?,
          ),
        );

      case AppRoutes.skaviaAi:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              SkaviaAiScreen(initialPrompt: args?['initialPrompt'] as String?),
        );

      case AppRoutes.liveJobFeed:
        return MaterialPageRoute(builder: (_) => const LiveJobFeedScreen());

      case AppRoutes.bookingConfirmation:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            workerProfileId: args?['workerProfileId'] as String? ?? 'wp_001',
            workerName: args?['workerName'] as String? ?? 'Rahul Ahmed',
            tradeTitle: args?['tradeTitle'] as String? ?? 'Flutter Developer',
            hourlyRate: (args?['hourlyRate'] as num?)?.toDouble() ?? 150.0,
            jobTitle: args?['jobTitle'] as String? ?? 'Mobile App Development',
            location: args?['location'] as String? ?? 'Dhaka, Bangladesh',
          ),
        );

      case AppRoutes.teamDiscovery:
        return MaterialPageRoute(builder: (_) => const TeamDiscoveryScreen());

      case AppRoutes.projectShowcase:
        return MaterialPageRoute(builder: (_) => const ProjectShowcaseScreen());

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case AppRoutes.appShell:
        return MaterialPageRoute(builder: (_) => const MainScaffoldScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
