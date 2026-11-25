import 'package:flutter/material.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/dispute_resolution_screen.dart';
import '../../features/admin/presentation/screens/team_assembly_screen.dart';
import '../../features/admin/presentation/screens/verification_queue_screen.dart';
import '../../features/ai_assistant/presentation/screens/skavia_ai_screen.dart';
import '../../features/app_update/presentation/screens/app_update_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/otp_verification_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/authentication/presentation/screens/role_selection_screen.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/billing/presentation/screens/invoice_screen.dart';
import '../../features/billing/presentation/screens/payment_success_screen.dart';
import '../../features/billing/presentation/screens/simulated_checkout_screen.dart';
import '../../features/billing/presentation/screens/transaction_history_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/customer/presentation/screens/booking_confirmation_screen.dart';
import '../../features/customer/presentation/screens/candidate_matches_screen.dart';
import '../../features/customer/presentation/screens/category_catalog_screen.dart';
import '../../features/customer/presentation/screens/live_job_feed_screen.dart';
import '../../features/customer/presentation/screens/post_requirement_screen.dart';
import '../../features/diagnostics/presentation/screens/device_diagnostics_screen.dart';
import '../../features/navigation/presentation/screens/main_scaffold_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/profile/presentation/screens/about_skavia_screen.dart';
import '../../features/profile/presentation/screens/edit_detailed_profile_screen.dart';
import '../../features/profile/presentation/screens/notification_preferences_screen.dart';
import '../../features/profile/presentation/screens/nid_verification_screen.dart';
import '../../features/profile/presentation/screens/privacy_security_screen.dart';
import '../../features/profile/presentation/screens/saved_addresses_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/support_faq_screen.dart';
import '../../features/reviews/presentation/screens/submit_complaint_screen.dart';
import '../../features/reviews/presentation/screens/submit_review_screen.dart';
import '../../features/reviews/presentation/screens/worker_reputation_screen.dart';
import '../../features/team_project/presentation/screens/assign_task_screen.dart';
import '../../features/team_project/presentation/screens/project_dashboard_screen.dart';
import '../../features/team_project/presentation/screens/project_showcase_screen.dart';
import '../../features/team_project/presentation/screens/task_board_screen.dart';
import '../../features/team_project/presentation/screens/team_discovery_screen.dart';
import '../../features/team_project/presentation/screens/team_roster_screen.dart';
import '../../features/worker/presentation/screens/active_job_screen.dart';
import '../../features/worker/presentation/screens/availability_calendar_screen.dart';
import '../../features/worker/presentation/screens/incoming_requests_screen.dart';
import '../../features/worker/presentation/screens/portfolio_management_screen.dart';
import '../../features/worker/presentation/screens/worker_earnings_screen.dart';
import '../../features/worker/presentation/screens/worker_edit_profile_screen.dart';
import '../../features/worker/presentation/screens/worker_profile_detail_screen.dart';
import 'app_routes.dart';
import 'route_guards.dart';

abstract class AppRouter {
  static MaterialPageRoute<dynamic> _page(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return MaterialPageRoute(settings: settings, builder: builder);
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(settings, (_) => const SplashScreen());

      case AppRoutes.onboarding:
        return _page(settings, (_) => const OnboardingScreen());

      case AppRoutes.login:
        return _page(settings, (_) => const LoginScreen());

      case AppRoutes.register:
        return _page(settings, (_) => const RegisterScreen());

      case AppRoutes.roleSelection:
        return _page(settings, (_) => const RoleSelectionScreen());

      case AppRoutes.otpVerify:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => OtpVerificationScreen(
            phoneNumber: args?['phoneNumber'] as String?,
            fullName: args?['fullName'] as String?,
            verificationId: args?['verificationId'] as String?,
          ),
        );

      case AppRoutes.categoryCatalog:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => CategoryCatalogScreen(
            initialCategoryId:
                (args?['categoryId'] ?? args?['category']) as String?,
            initialSearchQuery: args?['searchQuery'] as String?,
          ),
        );

      case AppRoutes.postRequirement:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => PostRequirementScreen(
            preselectedCategory: args?['categoryId'] as String?,
          ),
        );

      case AppRoutes.candidateMatches:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => CandidateMatchesScreen(
            requirementId: args?['requirementId'] as String? ?? '',
            requirementTitle:
                args?['requirementTitle'] as String? ?? 'Service Requirement',
            requirementZone: args?['requirementZone'] as String? ?? 'Dhaka',
            budget: (args?['budget'] as num?)?.toDouble() ?? 0.0,
            isComplexProject: args?['isComplexProject'] as bool? ?? false,
            categoryId: args?['categoryId'] as String?,
          ),
        );

      case AppRoutes.workerProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args?['isEdit'] == true) {
          return _page(settings, (_) => const WorkerEditProfileScreen());
        }
        final rawSkills = args?['skills'];
        final skills = rawSkills is List
            ? rawSkills.map((e) => e.toString()).toList()
            : const <String>[];
        return _page(
          settings,
          (_) => WorkerProfileDetailScreen(
            workerProfileId: args?['workerProfileId'] as String?,
            name: args?['name'] as String? ?? 'Specialist',
            title: args?['title'] as String? ?? 'Trade Specialist',
            rating: (args?['rating'] as num?)?.toDouble() ?? 0.0,
            reviewsCount: (args?['reviewsCount'] as num?)?.toInt() ?? 0,
            experience: args?['experience'] as String? ?? '',
            location: args?['location'] as String? ?? 'Dhaka, Bangladesh',
            hourlyRate: args?['hourlyRate'] as String? ?? '৳ 0/hr',
            skills: skills,
            avatarUrl: args?['avatarUrl'] as String? ?? '',
            isVerified: args?['isVerified'] as bool? ?? false,
          ),
        );

      case AppRoutes.incomingRequests:
        return _page(settings, (_) => const IncomingRequestsScreen());

      case AppRoutes.activeJob:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => ActiveJobScreen(
            requestId: args?['requestId'] as String? ?? '',
            clientName: args?['clientName'] as String? ?? 'Client',
            jobTitle: args?['jobTitle'] as String? ?? 'Service Job',
            location: args?['location'] as String? ?? 'Dhaka',
            agreedPrice: (args?['agreedPrice'] as num?)?.toDouble() ?? 0.0,
            expectedOtp: args?['expectedOtp'] as String? ?? '',
            scheduledTime: args?['scheduledTime'] as String? ?? '',
            serviceNotes: args?['serviceNotes'] as String? ?? '',
            clientPhone: args?['clientPhone'] as String?,
          ),
        );

      case AppRoutes.workerEarnings:
        return _page(settings, (_) => const WorkerEarningsScreen());

      case AppRoutes.availabilityCalendar:
        return _page(settings, (_) => const AvailabilityCalendarScreen());

      case AppRoutes.portfolioManagement:
        return _page(settings, (_) => const PortfolioManagementScreen());

      case AppRoutes.projectDashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => ProjectDashboardScreen(
            projectId: args?['projectId'] as String?,
            projectTitle: args?['projectTitle'] as String? ?? 'Projects',
          ),
        );

      case AppRoutes.taskBoard:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => TaskBoardScreen(
            projectId: args?['projectId'] as String? ?? '',
            projectTitle: args?['projectTitle'] as String? ?? 'Project Tasks',
          ),
        );

      case AppRoutes.assignTask:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) =>
              AssignTaskScreen(projectId: args?['projectId'] as String? ?? ''),
        );

      case AppRoutes.teamRoster:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) =>
              TeamRosterScreen(projectId: args?['projectId'] as String? ?? ''),
        );

      case AppRoutes.chatList:
        return _page(settings, (_) => const ChatListScreen());

      case AppRoutes.chatRoom:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => ChatRoomScreen(
            conversationId: args?['conversationId'] as String? ?? '',
            otherParticipantName:
                args?['otherParticipantName'] as String? ?? 'SKAVIA Member',
            otherParticipantAvatar: args?['otherParticipantAvatar'] as String?,
            otherParticipantId: args?['otherParticipantId'] as String? ?? '',
          ),
        );

      case AppRoutes.submitReview:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => SubmitReviewScreen(
            workerProfileId: args?['workerProfileId'] as String? ?? '',
            workerName: args?['workerName'] as String? ?? 'Specialist',
            workerAvatar: args?['workerAvatar'] as String?,
            serviceRequestId: args?['serviceRequestId'] as String?,
            projectId: args?['projectId'] as String?,
          ),
        );

      case AppRoutes.workerReputation:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => WorkerReputationScreen(
            workerProfileId: args?['workerProfileId'] as String?,
            workerName: args?['workerName'] as String?,
          ),
        );

      case AppRoutes.skaviaAi:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) =>
              SkaviaAiScreen(initialPrompt: args?['initialPrompt'] as String?),
        );

      case AppRoutes.liveJobFeed:
        return _page(settings, (_) => const LiveJobFeedScreen());

      case AppRoutes.bookingConfirmation:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => BookingConfirmationScreen(
            requirementId: args?['requirementId'] as String?,
            workerProfileId: args?['workerProfileId'] as String? ?? '',
            workerName: args?['workerName'] as String? ?? 'Specialist',
            tradeTitle: args?['tradeTitle'] as String? ?? 'Trade Service',
            hourlyRate: (args?['hourlyRate'] as num?)?.toDouble() ?? 0.0,
            jobTitle: args?['jobTitle'] as String? ?? 'Technical Service',
            location: args?['location'] as String? ?? 'Dhaka, Bangladesh',
          ),
        );

      case AppRoutes.checkout:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => SimulatedCheckoutScreen(
            title: args?['title'] as String? ?? 'On-Demand Service',
            amount: (args?['amount'] as num?)?.toDouble() ?? 0.0,
            serviceRequestId: args?['serviceRequestId'] as String?,
            projectId: args?['projectId'] as String?,
            workerProfileId: args?['workerProfileId'] as String?,
            specialistName: args?['specialistName'] as String? ?? 'Specialist',
            location: args?['location'] as String? ?? 'Dhaka, Bangladesh',
          ),
        );

      case AppRoutes.invoice:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => InvoiceScreen(
            invoiceNumber: args?['invoiceNumber'] as String? ?? '',
            serviceTitle:
                args?['serviceTitle'] as String? ?? 'Technical Service',
            clientName: args?['clientName'] as String? ?? 'Client',
            clientPhone: args?['clientPhone'] as String? ?? '',
            specialistName: args?['specialistName'] as String? ?? 'Specialist',
            baseAmount: (args?['baseAmount'] as num?)?.toDouble() ?? 0.0,
            platformFee: (args?['platformFee'] as num?)?.toDouble() ?? 0.0,
            totalAmount: (args?['totalAmount'] as num?)?.toDouble() ?? 0.0,
            paymentMethod: args?['paymentMethod'] as String? ?? 'bKash',
            transactionId: args?['transactionId'] as String? ?? '',
            paidAt: args?['paidAt'] as DateTime? ?? DateTime.now(),
            status: args?['status'] as String? ?? 'Paid',
          ),
        );

      case AppRoutes.paymentSuccess:
        final args = settings.arguments as Map<String, dynamic>?;
        final totalAmount = (args?['amount'] as num?)?.toDouble() ?? 0.0;
        final baseAmount =
            (args?['baseAmount'] as num?)?.toDouble() ?? totalAmount;
        final platformFee = (args?['platformFee'] as num?)?.toDouble() ?? 0.0;
        final transactionId = args?['transactionId'] as String? ?? '';
        final paymentMethod = args?['paymentMethod'] as String? ?? 'bKash';
        final jobTitle = args?['jobTitle'] as String? ?? 'Service';
        final specialistName =
            args?['specialistName'] as String? ?? 'SKAVIA Specialist';

        return _page(
          settings,
          (routeContext) => PaymentSuccessScreen(
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
                  'clientName': args?['clientName'] as String? ?? 'Client',
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
        return _page(settings, (_) => const TeamDiscoveryScreen());

      case AppRoutes.projectShowcase:
        return _page(settings, (_) => const ProjectShowcaseScreen());

      case AppRoutes.adminDashboard:
        return _page(
          settings,
          (_) => const ProtectedAdminRoute(child: AdminDashboardScreen()),
        );

      case AppRoutes.verificationQueue:
        return _page(
          settings,
          (_) => const ProtectedAdminRoute(child: VerificationQueueScreen()),
        );

      case AppRoutes.disputeResolution:
        return _page(
          settings,
          (_) => const ProtectedAdminRoute(child: DisputeResolutionScreen()),
        );

      case AppRoutes.teamAssembly:
        return _page(
          settings,
          (_) => const ProtectedAdminRoute(child: TeamAssemblyScreen()),
        );

      case AppRoutes.appShell:
        return _page(settings, (_) => const MainScaffoldScreen());

      case AppRoutes.editDetailedProfile:
        final controller =
            (settings.arguments as ProfileController?) ??
            ProfileController.shared;
        return _page(
          settings,
          (_) => EditDetailedProfileScreen(controller: controller),
        );

      case AppRoutes.savedAddresses:
        final controller =
            (settings.arguments as ProfileController?) ??
            ProfileController.shared;
        return _page(
          settings,
          (_) => SavedAddressesScreen(controller: controller),
        );

      case AppRoutes.notificationPreferences:
        final controller =
            (settings.arguments as ProfileController?) ??
            ProfileController.shared;
        return _page(
          settings,
          (_) => NotificationPreferencesScreen(controller: controller),
        );

      case AppRoutes.privacySecurity:
        final controller =
            (settings.arguments as ProfileController?) ??
            ProfileController.shared;
        return _page(
          settings,
          (_) => PrivacySecurityScreen(controller: controller),
        );

      case AppRoutes.nidVerification:
        final controller =
            (settings.arguments as ProfileController?) ??
            ProfileController.shared;
        return _page(
          settings,
          (_) => NidVerificationScreen(controller: controller),
        );

      case AppRoutes.notificationCenter:
        return _page(settings, (_) => const NotificationCenterScreen());

      case AppRoutes.settings:
        return _page(settings, (_) => const SettingsScreen());

      case AppRoutes.supportFaq:
        return _page(settings, (_) => const SupportFaqScreen());

      case AppRoutes.aboutSkavia:
        return _page(settings, (_) => const AboutSkaviaScreen());

      case AppRoutes.appUpdate:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => AppUpdateScreen(
            blockingMode: args?['blocking'] as bool? ?? false,
          ),
        );

      case AppRoutes.deviceDiagnostics:
        return _page(settings, (_) => const DeviceDiagnosticsScreen());

      case AppRoutes.transactionHistory:
        return _page(settings, (_) => const TransactionHistoryScreen());

      case AppRoutes.submitComplaint:
        final args = settings.arguments as Map<String, dynamic>?;
        return _page(
          settings,
          (_) => SubmitComplaintScreen(
            serviceRequestId: args?['serviceRequestId'] as String?,
            projectId: args?['projectId'] as String?,
          ),
        );

      default:
        return _page(
          settings,
          (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
