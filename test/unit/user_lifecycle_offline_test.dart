import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/core/network/network_connectivity_service.dart';
import 'package:skavia/core/network/offline_sync_queue_manager.dart';
import 'package:skavia/core/services/feature_eligibility_service.dart';
import 'package:skavia/core/storage/local_cache_service.dart';
import 'package:skavia/core/utils/uuid_util.dart';
import 'package:skavia/features/notifications/data/models/app_notification_model.dart';
import 'package:skavia/features/notifications/presentation/controllers/notification_center_controller.dart';
import 'package:skavia/features/profile/data/models/user_address_model.dart';
import 'package:skavia/features/profile/data/models/user_profile_model.dart';
import 'package:skavia/features/profile/domain/services/profile_completion_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SKAVIA User Lifecycle, Profile Completion & Intelligence Tests', () {
    test('PR-01: Profile completion starts at base score for bare profile', () {
      final bareProfile = UserProfileModel(
        id: 'user_01',
        email: 'test@skavia.com',
        fullName: 'SKAVIA Member',
      );

      final result = ProfileCompletionEngine.evaluate(bareProfile);
      // Bare profile only has valid email (15 pts) -> 15%
      expect(result.percentage, 15);
      expect(result.isComplete, isFalse);
      expect(result.missingFields.any((f) => f.key == 'saved_address'), isTrue);
    });

    test('PR-02: Profile completion reaches 100% when all attributes are filled', () {
      final completeProfile = UserProfileModel(
        id: 'user_02',
        email: 'rahim.ahmed@gmail.com',
        fullName: 'Rahim Ahmed',
        phone: '+8801711223344',
        avatarUrl: 'https://skavia.com/avatars/rahim.png',
        dateOfBirth: DateTime(1992, 5, 14),
        emergencyContactName: 'Karim Ahmed',
        emergencyContactPhone: '+8801811998877',
        savedAddresses: [
          UserAddressModel(
            id: 'addr_1',
            userId: 'user_02',
            addressLine: 'House 14, Road 5, Sector 4, Uttara',
            isDefault: true,
          ),
        ],
      );

      final result = ProfileCompletionEngine.evaluate(completeProfile);
      expect(result.percentage, 100);
      expect(result.isComplete, isTrue);
      expect(result.missingFields, isEmpty);
      expect(result.nextRecommendedAction, isNull);
    });

    test('PR-03: Next recommended action prioritizes highest-weight missing field', () {
      final profile = UserProfileModel(
        id: 'user_03',
        email: 'fatima@gmail.com',
        fullName: 'Fatima Begum',
        phone: '+8801999888777',
      );

      final result = ProfileCompletionEngine.evaluate(profile);
      // Saved Address carries 20% weight (highest missing)
      expect(result.nextRecommendedAction?.key, 'saved_address');
      expect(result.nextRecommendedAction?.weight, 20);
    });
  });

  group('SKAVIA Progressive Feature Eligibility Tests', () {
    test('EL-01: Customer cannot book without a saved address', () {
      final profileNoAddress = UserProfileModel(
        id: 'cust_01',
        email: 'client@skavia.com',
        fullName: 'Client One',
        phone: '+8801700000000',
        savedAddresses: [],
      );

      final result = FeatureEligibilityService.checkEligibility(
        feature: AppFeature.bookService,
        profile: profileNoAddress,
      );

      expect(result.isEligible, isFalse);
      expect(result.missingRequirements.first,
          contains('A delivery address is required'));
    });

    test('EL-02: Customer is eligible to book once address and phone exist', () {
      final eligibleProfile = UserProfileModel(
        id: 'cust_02',
        email: 'client@skavia.com',
        fullName: 'Client Two',
        phone: '+8801700000000',
        savedAddresses: [
          UserAddressModel(
            id: 'addr_1',
            userId: 'cust_02',
            addressLine: 'Gulshan 2',
          ),
        ],
      );

      final result = FeatureEligibilityService.checkEligibility(
        feature: AppFeature.bookService,
        profile: eligibleProfile,
      );

      expect(result.isEligible, isTrue);
      expect(result.missingRequirements, isEmpty);
    });

    test('EL-03: Suspended accounts are barred from all operations', () {
      final suspendedProfile = UserProfileModel(
        id: 'susp_01',
        email: 'badactor@skavia.com',
        fullName: 'Suspended User',
        accountStatus: 'suspended',
      );

      final result = FeatureEligibilityService.checkEligibility(
        feature: AppFeature.bookService,
        profile: suspendedProfile,
      );

      expect(result.isEligible, isFalse);
      expect(result.missingRequirements.first, contains('suspended'));
    });
  });

  group('SKAVIA Offline Architecture, Local Cache & Sync Queue Tests', () {
    test('OFF-01: LocalCacheService handles put, get, TTL and remove', () {
      final cache = LocalCacheService.instance;
      cache.put('test_key', {'name': 'SKAVIA', 'version': '1.0'});

      expect(cache.has('test_key'), isTrue);
      final retrieved = cache.get('test_key');
      expect(retrieved['name'], 'SKAVIA');

      cache.remove('test_key');
      expect(cache.has('test_key'), isFalse);
    });

    test('OFF-02: OfflineSyncQueueManager enqueues operations with UUID idempotency key', () {
      final syncManager = OfflineSyncQueueManager.instance;
      syncManager.clearQueue();

      final item = syncManager.enqueue(
        operationType: 'create_draft_booking',
        payload: {'service': 'AC Master Wash', 'price': 1200},
        autoSync: false,
      );

      expect(item.idempotencyKey.isNotEmpty, isTrue);
      expect(UuidUtil.isValidUuid(item.idempotencyKey), isTrue);
      expect(syncManager.pendingCount, 1);
    });

    test('OFF-03: Sync queue processes items and calculates exponential backoff', () async {
      final syncManager = OfflineSyncQueueManager.instance;
      syncManager.clearQueue();

      syncManager.enqueue(
        operationType: 'update_address',
        payload: {'zone': 'Dhanmondi'},
        autoSync: false,
      );
      expect(syncManager.pendingCount, 1);

      final successCount = await syncManager.processQueue();
      expect(successCount, 1);
      expect(syncManager.pendingCount, 0);

      // Verify backoff formula: 2^retry * 1000
      expect(syncManager.calculateBackoffDelayMs(0), 1000);
      expect(syncManager.calculateBackoffDelayMs(1), 2000);
      expect(syncManager.calculateBackoffDelayMs(2), 4000);
      expect(syncManager.calculateBackoffDelayMs(3), 8000);
    });

    test('OFF-04: NetworkQualityState transitions correctly', () {
      final net = NetworkConnectivityService.instance;
      net.setManualState(NetworkQualityState.offline);
      expect(net.currentState, NetworkQualityState.offline);

      net.setManualState(NetworkQualityState.online);
      expect(net.currentState, NetworkQualityState.online);
    });
  });

  group('SKAVIA Notification Deduplication & Lifecycle Alerts Tests', () {
    test('NOTIF-01: Duplicate notifications are rejected via dedup_key', () {
      final controller = NotificationCenterController.instance;

      final n1 = AppNotificationModel(
        id: 'notif_1',
        userId: 'u1',
        dedupKey: 'welcome_unique_key',
        title: 'Welcome',
        body: 'Welcome to SKAVIA',
        createdAt: DateTime.now(),
      );

      final addedFirst = controller.addNotification(n1);
      final addedSecond = controller.addNotification(n1);

      expect(addedFirst, isTrue);
      expect(addedSecond, isFalse); // duplicate prevented!
    });

    test('NOTIF-02: Birthday gift triggers on user birthday date match', () {
      final controller = NotificationCenterController.instance;
      final today = DateTime.now();

      final birthdayUser = UserProfileModel(
        id: 'bday_user',
        email: 'bday@skavia.com',
        fullName: 'Birthday Person',
        dateOfBirth: DateTime(1995, today.month, today.day),
        birthdayNotificationsEnabled: true,
      );

      controller.checkAndTriggerBirthdayGift(birthdayUser);

      final birthdayNotif = controller.notifications.firstWhere(
        (n) => n.category == 'birthday',
      );
      expect(birthdayNotif.title, contains('Happy Birthday'));
      expect(birthdayNotif.body, contains('20% discount'));
    });

    test('NOTIF-03: Mark all as read and dismiss operate cleanly', () {
      final controller = NotificationCenterController.instance;
      controller.markAllAsRead();
      expect(controller.unreadCount, 0);

      final initialCount = controller.notifications.length;
      if (initialCount > 0) {
        final firstId = controller.notifications.first.id;
        controller.dismiss(firstId);
        expect(controller.notifications.length, initialCount - 1);
      }
    });
  });
}

