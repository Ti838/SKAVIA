import 'package:flutter/material.dart';

import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/authentication/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/authentication/presentation/screens/otp_verification_screen.dart';
import '../../features/authentication/presentation/screens/role_selection_screen.dart';
import '../../features/customer/presentation/screens/category_catalog_screen.dart';
import '../../features/customer/presentation/screens/post_requirement_screen.dart';
import '../../features/customer/presentation/screens/candidate_matches_screen.dart';
import '../../features/customer/presentation/screens/booking_confirmation_screen.dart';
import '../../features/worker/presentation/screens/worker_edit_profile_screen.dart';
import '../../features/worker/presentation/screens/worker_profile_detail_screen.dart';
import '../../features/worker/presentation/screens/incoming_requests_screen.dart';
import '../../features/worker/presentation/screens/worker_earnings_screen.dart';
import '../../features/worker/presentation/screens/availability_calendar_screen.dart';
import '../../features/worker/presentation/screens/portfolio_management_screen.dart';
import '../../features/team_project/presentation/screens/project_dashboard_screen.dart';
import '../../features/team_project/presentation/screens/team_discovery_screen.dart';
import '../../features/team_project/presentation/screens/project_showcase_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/team_project/presentation/screens/task_board_screen.dart';
import '../../features/team_project/presentation/screens/assign_task_screen.dart';
import '../../features/team_project/presentation/screens/team_roster_screen.dart';
import '../../features/navigation/presentation/screens/main_scaffold_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/reviews/presentation/screens/submit_review_screen.dart';
import '../../features/reviews/presentation/screens/worker_reputation_screen.dart';
import '../../features/ai_assistant/presentation/screens/skavia_ai_screen.dart';
import '../../features/customer/presentation/screens/live_job_feed_screen.dart';
import '../../features/billing/presentation/screens/simulated_checkout_screen.dart';
import '../../features/billing/presentation/screens/invoice_screen.dart';
import '../../features/billing/presentation/screens/payment_success_screen.dart';
import '../../features/billing/presentation/screens/transaction_history_screen.dart';
import '../../features/admin/presentation/screens/verification_queue_screen.dart';
import '../../features/admin/presentation/screens/dispute_resolution_screen.dart';
import '../../features/admin/presentation/screens/team_assembly_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/profile/presentation/screens/about_skavia_screen.dart';
import '../../features/app_update/presentation/screens/app_update_screen.dart';
import '../../features/profile/presentation/screens/edit_detailed_profile_screen.dart';
import '../../features/profile/presentation/screens/notification_preferences_screen.dart';
import '../../features/profile/presentation/screens/privacy_security_screen.dart';
import '../../features/profile/presentation/screens/saved_addresses_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/support_faq_screen.dart';
import '../../features/reviews/presentation/screens/submit_complaint_screen.dart';
import 'app_routes.dart';
import 'route_guards.dart';

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

      case AppRoutes.roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

      case AppRoutes.otpVerify:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: args?['phoneNumber'] as String?,
            fullName: args?['fullName'] as String?,
            verificationId: args?['verificationId'] as String?,
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
            workerProfileId: args?['workerProfileId'] as String?,
            name: args?['name'] as String? ?? 'SKAVIA Specialist',
            title: args?['title'] as String? ?? 'Certified Technician',
            rating: (args?['rating'] as num?)?.toDouble() ?? 4.8,
            reviewsCount: (args?['reviewsCount'] as num?)?.toInt() ?? 0,
            experience: args?['experience'] as String? ?? '2+ years',
            location: args?['location'] as String? ?? 'Dhaka, Bangladesh',
            hourlyRate: args?['hourlyRate'] as String? ?? '৳ 1,500/hr',
            avatarUrl: args?['avatarUrl'] as String? ?? '',
          ),
        );

      case AppRoutes.incomingRequests:
        return MaterialPageRoute(
          builder: (_) => const IncomingRequestsScreen(),
        );

      case AppRoutes.workerEarnings:
        return MaterialPageRoute(builder: (_) => const WorkerEarningsScreen());

      case AppRoutes.availabilityCalendar:
        return MaterialPageRoute(
          builder: (_) => const AvailabilityCalendarScreen(),
        );

      case AppRoutes.portfolioManagement:
        return MaterialPageRoute(
          builder: (_) => const PortfolioManagementScreen(),
        );

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

      case AppRoutes.taskBoard:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TaskBoardScreen(
            projectId: args?['projectId'] as String? ?? 'proj_001',
            projectTitle: args?['projectTitle'] as String? ?? 'Project Tasks',
          ),
        );

      case AppRoutes.assignTask:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AssignTaskScreen(
            projectId: args?['projectId'] as String? ?? 'proj_001',
          ),
        );

      case AppRoutes.teamRoster:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TeamRosterScreen(
            projectId: args?['projectId'] as String? ?? 'proj_001',
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
            requirementId: args?['requirementId'] as String?,
            workerProfileId: args?['workerProfileId'] as String? ?? 'wp_001',
            workerName: args?['workerName'] as String? ?? 'SKAVIA Specialist',
            tradeTitle: args?['tradeTitle'] as String? ?? 'Certified Technician',
            hourlyRate: (args?['hourlyRate'] as num?)?.toDouble() ?? 1500.0,
            jobTitle: args?['jobTitle'] as String? ?? 'Technical Service',
            location: args?['location'] as String? ?? 'Dhaka, Bangladesh',
          ),
        );

      case AppRoutes.checkout:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SimulatedCheckoutScreen(
            title: args?['title'] as String? ?? 'On-Demand Service',
            amount: (args?['amount'] as num?)?.toDouble() ?? 1000.0,
            serviceRequestId: args?['serviceRequestId'] as String?,
            projectId: args?['projectId'] as String?,
            workerProfileId: args?['workerProfileId'] as String?,
            specialistName:
                args?['specialistName'] as String? ?? 'SKAVIA Specialist',
            location: args?['location'] as String? ?? 'Dhaka, Bangladesh',
          ),
        );

      case AppRoutes.invoice:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => InvoiceScreen(
            invoiceNumber: args?['invoiceNumber'] as String? ?? 'INV-1001',
            serviceTitle:
                args?['serviceTitle'] as String? ?? 'General Technical Service',
            clientName: args?['clientName'] as String? ?? 'Valued Client',
            clientPhone: args?['clientPhone'] as String? ?? '01700000000',
            specialistName:
                args?['specialistName'] as String? ?? 'SKAVIA Specialist',
            baseAmount: (args?['baseAmount'] as num?)?.toDouble() ?? 1000.0,
            platformFee: (args?['platformFee'] as num?)?.toDouble() ?? 150.0,
            totalAmount: (args?['totalAmount'] as num?)?.toDouble() ?? 1150.0,
            paymentMethod: args?['paymentMethod'] as String? ?? 'bKash',
            transactionId: args?['transactionId'] as String? ?? 'TRX-1001',
            paidAt: args?['paidAt'] as DateTime? ?? DateTime.now(),
          ),
        );

      case AppRoutes.paymentSuccess:
        final args = settings.arguments as Map<String, dynamic>?;
        final totalAmount = (args?['amount'] as num?)?.toDouble() ?? 1150.0;
        final baseAmount =
            (args?['baseAmount'] as num?)?.toDouble() ?? (totalAmount / 1.15);
        final platformFee =
            (args?['platformFee'] as num?)?.toDouble() ??
            (totalAmount - baseAmount);
        final transactionId =
            args?['transactionId'] as String? ?? 'TRX-1001';
        final paymentMethod =
            args?['paymentMethod'] as String? ?? 'bKash';
        final jobTitle = args?['jobTitle'] as String? ?? 'Service';
        final specialistName =
            args?['specialistName'] as String? ?? 'SKAVIA Specialist';

        return MaterialPageRoute(
          builder: (routeContext) => PaymentSuccessScreen(
            amount: totalAmount,
            transactionId: transactionId,
            paymentMethod: paymentMethod,
            jobTitle: jobTitle,
            specialistName: specialistName,
            serviceRequestId: args?['serviceRequestId'] as String?,
            projectId: args?['projectId'] as String?,
            onViewInvoice: () {
              Navigator.of(routeContext).pushNamed(
                AppRoutes.invoice,
                arguments: {
                  'invoiceNumber':
                      args?['invoiceNumber'] as String? ??
                      'INV-${transactionId.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}',
                  'serviceTitle': jobTitle,
                  'clientName':
                      args?['clientName'] as String? ?? 'Valued Client',
                  'clientPhone': args?['clientPhone'] as String? ?? '',
                  'specialistName': specialistName,
                  'baseAmount': baseAmount,
                  'platformFee': platformFee,
                  'totalAmount': totalAmount,
                  'paymentMethod': paymentMethod,
                  'transactionId': transactionId,
                  'paidAt': args?['paidAt'] as DateTime? ?? DateTime.now(),
                },
              );
            },
          ),
        );

      case AppRoutes.teamDiscovery:
        return MaterialPageRoute(builder: (_) => const TeamDiscoveryScreen());

      case AppRoutes.projectShowcase:
        return MaterialPageRoute(builder: (_) => const ProjectShowcaseScreen());

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) =>
              const ProtectedAdminRoute(child: AdminDashboardScreen()),
        );

      case AppRoutes.verificationQueue:
        return MaterialPageRoute(
          builder: (_) =>
              const ProtectedAdminRoute(child: VerificationQueueScreen()),
        );

      case AppRoutes.disputeResolution:
        return MaterialPageRoute(
          builder: (_) =>
              const ProtectedAdminRoute(child: DisputeResolutionScreen()),
        );

      case AppRoutes.teamAssembly:
        return MaterialPageRoute(
          builder: (_) =>
              const ProtectedAdminRoute(child: TeamAssemblyScreen()),
        );

      case AppRoutes.appShell:
        return MaterialPageRoute(builder: (_) => const MainScaffoldScreen());

      case AppRoutes.editDetailedProfile:
        final controller =
            (settings.arguments as ProfileController?) ??
            ProfileController.shared;
        return MaterialPageRoute(
          builder: (_) => EditDetailedProfileScreen(controller: controller),
        );

      case AppRoutes.savedAddresses:
        final controller =
            (settings.arguments as ProfileController?) ??
            ProfileController.shared;
        return MaterialPageRoute(
          builder: (_) => SavedAddressesScreen(controller: controller),
        );

      case AppRoutes.notificationPreferences:
        final controller =
            (settings.arguments as ProfileController?) ??
            ProfileController.shared;
        return MaterialPageRoute(
          builder: (_) =>
              NotificationPreferencesScreen(controller: controller),
        );

      case AppRoutes.privacySecurity:
        final controller =
            (settings.arguments as ProfileController?) ??
            ProfileController.shared;
        return MaterialPageRoute(
          builder: (_) => PrivacySecurityScreen(controller: controller),
        );

      case AppRoutes.notificationCenter:
        return MaterialPageRoute(
          builder: (_) => const NotificationCenterScreen(),
        );

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.supportFaq:
        return MaterialPageRoute(builder: (_) => const SupportFaqScreen());

      case AppRoutes.aboutSkavia:
        return MaterialPageRoute(builder: (_) => const AboutSkaviaScreen());

      case AppRoutes.appUpdate:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AppUpdateScreen(
            blockingMode: args?['blocking'] as bool? ?? false,
          ),
        );

      case AppRoutes.transactionHistory:
        return MaterialPageRoute(
          builder: (_) => const TransactionHistoryScreen(),
        );

      case AppRoutes.submitComplaint:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SubmitComplaintScreen(
            serviceRequestId: args?['serviceRequestId'] as String?,
            projectId: args?['projectId'] as String?,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
