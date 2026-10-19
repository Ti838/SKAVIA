import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Production-Grade Notification & Audio Chime Service for SKAVIA.
///
/// Implements dual-channel high-priority alert architecture modeled after
/// leading on-demand service platforms (e.g., Uber, Swiggy, TaskRabbit):
/// 1. Heads-up priority banner & custom audio chime for urgent jobs/bids.
/// 2. Polite runtime permission management with rationale flow (Android 13+ & iOS).
/// 3. In-app audio feedback + haptic vibration for real-time foreground updates.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AudioPlayer? _audioPlayer;

  final StreamController<String?> _notificationSelectController =
      StreamController<String?>.broadcast();

  Stream<String?> get onNotificationTapped =>
      _notificationSelectController.stream;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Channel IDs
  static const String urgentChannelId = 'skavia_urgent_channel';
  static const String urgentChannelName = 'Urgent Jobs & Bids';
  static const String urgentChannelDescription =
      'High-priority sound alerts and heads-up banners for incoming jobs, bids, and OTPs.';

  static const String generalChannelId = 'skavia_general_channel';
  static const String generalChannelName = 'General Updates';
  static const String generalChannelDescription =
      'Notifications for status updates, chat messages, and account notices.';

  /// Custom notification sound asset in res/raw (Android)
  static const String customSoundResource = 'notification_sound';

  /// Initializes the notification channels, plugin drivers, and audio pool.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Android & Darwin (iOS/macOS) Initialization Settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      // 2. Initialize Plugin with Payload Tap Callback
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint(
              '[NotificationService] Notification clicked with payload: ${response.payload}');
          _notificationSelectController.add(response.payload);
        },
      );

      // 3. Register Explicit Android Notification Channels
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        if (androidImpl != null) {
          // Urgent Channel: Max importance (Heads-up pop down) with Custom Sound
          final urgentChannel = AndroidNotificationChannel(
            urgentChannelId,
            urgentChannelName,
            description: urgentChannelDescription,
            importance: Importance.max,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound(customSoundResource),
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
            enableLights: true,
            ledColor: const Color(0xFF0D9488),
          );

          // General Channel: Standard notifications
          const generalChannel = AndroidNotificationChannel(
            generalChannelId,
            generalChannelName,
            description: generalChannelDescription,
            importance: Importance.defaultImportance,
            playSound: true,
            enableVibration: true,
          );

          await androidImpl.createNotificationChannel(urgentChannel);
          await androidImpl.createNotificationChannel(generalChannel);
        }
      }

      // Configure audio player mode safely
      try {
        _audioPlayer ??= AudioPlayer();
        await _audioPlayer?.setAudioContext(AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.notification,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ));
      } catch (audioErr) {
        debugPrint('[NotificationService] AudioContext notice: $audioErr');
      }

      _isInitialized = true;
      debugPrint('[NotificationService] Initialized successfully with audio channels.');
    } catch (e, stack) {
      debugPrint('[NotificationService] Initialization error: $e\n$stack');
    }
  }

  /// Checks the current system notification permission status.
  Future<PermissionStatus> checkPermissionStatus() async {
    return await Permission.notification.status;
  }

  /// Requests system notification permission (Android 13+ and iOS).
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      debugPrint('[NotificationService] Permission request result: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('[NotificationService] Permission request error: $e');
      return false;
    }
  }

  /// Requests camera permission for job proof, verification, or profile photos.
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Requests photo library / storage permission.
  Future<bool> requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();
      if (status.isGranted) return true;
      // Fallback for Android 12 and below
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Requests runtime location permission.
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Opens the device app settings if notifications or permissions were permanently denied.
  Future<bool> openAppSettingsPage() async {
    return await openAppSettings();
  }

  /// Plays in-app bell chime and triggers haptic vibration for foreground events.
  Future<void> playInAppNotificationSound({bool withHaptic = true}) async {
    try {
      if (withHaptic) {
        await HapticFeedback.heavyImpact();
      }
      _audioPlayer ??= AudioPlayer();
      await _audioPlayer?.stop();
      await _audioPlayer?.play(AssetSource('sounds/notification_sound.wav'), volume: 1.0);
    } catch (e) {
      // Audio playback fallback to pure system haptic
      if (withHaptic) {
        await HapticFeedback.mediumImpact();
      }
      debugPrint('[NotificationService] In-app audio notice: $e');
    }
  }

  /// Displays a heads-up system tray notification with sound, vibration, and optional action buttons.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isUrgent = true,
    bool triggerInAppChime = true,
    List<AndroidNotificationAction>? actions,
    NotificationVisibility visibility = NotificationVisibility.public,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Play in-app chime if active
      if (triggerInAppChime) {
        unawaited(playInAppNotificationSound());
      }

      final androidDetails = AndroidNotificationDetails(
        isUrgent ? urgentChannelId : generalChannelId,
        isUrgent ? urgentChannelName : generalChannelName,
        channelDescription:
            isUrgent ? urgentChannelDescription : generalChannelDescription,
        importance: isUrgent ? Importance.max : Importance.defaultImportance,
        priority: isUrgent ? Priority.high : Priority.defaultPriority,
        playSound: true,
        sound: isUrgent
            ? const RawResourceAndroidNotificationSound(customSoundResource)
            : null,
        enableVibration: true,
        vibrationPattern:
            isUrgent ? Int64List.fromList([0, 500, 200, 500]) : null,
        visibility: visibility,
        ticker: title,
        actions: actions,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: isUrgent ? 'Urgent Alert' : 'SKAVIA',
        ),
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: '$customSoundResource.wav',
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] showNotification error: $e');
    }
  }

  /// Displays an Ongoing / Persistent status notification (e.g. Technician arriving, Active Job).
  /// Cannot be accidentally swiped away until completed.
  Future<void> showOngoingJobNotification({
    required int id,
    required String title,
    required String body,
    int? progress,
    int? maxProgress,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final androidDetails = AndroidNotificationDetails(
        generalChannelId,
        generalChannelName,
        channelDescription: generalChannelDescription,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showProgress: progress != null,
        maxProgress: maxProgress ?? 100,
        progress: progress ?? 0,
        visibility: NotificationVisibility.public,
        styleInformation: BigTextStyleInformation(body, contentTitle: title),
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(presentAlert: true),
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] showOngoingJobNotification error: $e');
    }
  }

  /// Cancels an active notification by ID.
  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancels all active notifications.
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Disposes background streams and audio players.
  void dispose() {
    _notificationSelectController.close();
    _audioPlayer?.dispose();
  }
}
