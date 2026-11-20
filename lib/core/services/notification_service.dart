import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'sound_haptic_preferences.dart';

/// Notification sound categories supported across the SKAVIA ecosystem.
enum NotificationSoundType { general, urgent, message, completed }

/// Production-Grade Notification & Audio Chime Service for SKAVIA.
///
/// Implements multi-channel alert architecture modeled after high-scale on-demand platforms:
/// 1. Heads-up priority banner & custom audio chime for urgent jobs/bids.
/// 2. Dedicated message chime for in-app chat conversations.
/// 3. Success chime for completed jobs and escrow disbursements.
/// 4. Polite runtime permission management with rationale flow (Android 13+ & iOS).
/// 5. In-app audio feedback + haptic vibration for real-time foreground updates.
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

  static const String messageChannelId = 'skavia_message_channel';
  static const String messageChannelName = 'Chat & Messages';
  static const String messageChannelDescription =
      'Audio chimes and alerts for incoming messages and customer inquiries.';

  static const String generalChannelId = 'skavia_general_channel';
  static const String generalChannelName = 'General Updates';
  static const String generalChannelDescription =
      'Notifications for status updates, chat messages, and account notices.';

  /// Custom notification sound assets in res/raw (Android)
  static const String customSoundResource = 'notification_sound';
  static const String customSoundUrgent = 'urgent_dispatch';
  static const String customSoundMessage = 'message_chime';
  static const String customSoundCompleted = 'job_completed';

  /// Initializes the notification channels, plugin drivers, and audio pool.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Android & Darwin (iOS/macOS) Initialization Settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
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
            '[NotificationService] Notification clicked with payload: ${response.payload}',
          );
          _notificationSelectController.add(response.payload);
        },
      );

      // 3. Register Explicit Android Notification Channels
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        if (androidImpl != null) {
          // Urgent Channel: Max importance (Heads-up pop down) with Custom Sound
          final urgentChannel = AndroidNotificationChannel(
            urgentChannelId,
            urgentChannelName,
            description: urgentChannelDescription,
            importance: Importance.max,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound(customSoundUrgent),
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
            enableLights: true,
            ledColor: const Color(0xFF0D9488),
          );

          // Message Channel: High importance for in-app chat conversations
          const messageChannel = AndroidNotificationChannel(
            messageChannelId,
            messageChannelName,
            description: messageChannelDescription,
            importance: Importance.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(customSoundMessage),
            enableVibration: true,
            vibrationPattern: null,
          );

          // General Channel: Standard notifications
          const generalChannel = AndroidNotificationChannel(
            generalChannelId,
            generalChannelName,
            description: generalChannelDescription,
            importance: Importance.defaultImportance,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(customSoundResource),
            enableVibration: true,
          );

          await androidImpl.createNotificationChannel(urgentChannel);
          await androidImpl.createNotificationChannel(messageChannel);
          await androidImpl.createNotificationChannel(generalChannel);
        }
      }

      _isInitialized = true;
      debugPrint('[NotificationService] Initialized successfully.');
    } catch (e, stack) {
      debugPrint('[NotificationService] Initialization error: $e\n$stack');
    }
  }

  Future<AudioPlayer> _ensureAudioPlayer() async {
    final existing = _audioPlayer;
    if (existing != null) return existing;
    final created = AudioPlayer();
    _audioPlayer = created;
    try {
      await created.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.notification,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );
    } catch (audioErr) {
      debugPrint('[NotificationService] AudioContext notice: $audioErr');
    }
    return created;
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

  /// Plays in-app chime and triggers haptic vibration for foreground events,
  /// respecting persisted user sound and haptic preferences.
  Future<void> playInAppNotificationSound({
    bool? withHaptic,
    bool isMessage = false,
    bool forcePreview = false,
    NotificationSoundType soundType = NotificationSoundType.general,
  }) async {
    final effectiveType = isMessage ? NotificationSoundType.message : soundType;
    final prefs = SoundHapticPreferences.instance;
    final allowSound = forcePreview
        ? true
        : (effectiveType == NotificationSoundType.message
              ? prefs.messageSoundEnabled
              : prefs.notificationSoundEnabled);
    final allowHaptic = forcePreview
        ? true
        : (withHaptic ?? prefs.hapticFeedbackEnabled);

    try {
      if (allowHaptic) {
        if (effectiveType == NotificationSoundType.urgent) {
          await HapticFeedback.heavyImpact();
        } else {
          await HapticFeedback.mediumImpact();
        }
      }
      if (!allowSound) return;
      final player = await _ensureAudioPlayer();
      await player.stop();

      final String assetName;
      switch (effectiveType) {
        case NotificationSoundType.urgent:
          assetName = 'sounds/urgent_dispatch.wav';
          break;
        case NotificationSoundType.message:
          assetName = 'sounds/message_chime.wav';
          break;
        case NotificationSoundType.completed:
          assetName = 'sounds/job_completed.wav';
          break;
        case NotificationSoundType.general:
          assetName = 'sounds/notification_sound.wav';
          break;
      }

      await player.play(AssetSource(assetName), volume: 1.0);
    } catch (e) {
      // Audio playback fallback to pure system haptic
      if (allowHaptic) {
        await HapticFeedback.mediumImpact();
      }
      debugPrint('[NotificationService] In-app audio notice: $e');
    }
  }

  /// Explicit live chime preview for any sound type in Sound & Haptics settings.
  Future<void> previewNotificationSound({
    NotificationSoundType soundType = NotificationSoundType.urgent,
  }) async {
    await playInAppNotificationSound(
      withHaptic: true,
      forcePreview: true,
      soundType: soundType,
    );
  }

  /// Displays a heads-up system tray notification with sound, vibration, and optional action buttons.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isUrgent = true,
    bool triggerInAppChime = true,
    NotificationSoundType? soundType,
    List<AndroidNotificationAction>? actions,
    NotificationVisibility visibility = NotificationVisibility.public,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final effectiveType =
          soundType ??
          (isUrgent
              ? NotificationSoundType.urgent
              : NotificationSoundType.general);
      final prefs = SoundHapticPreferences.instance;

      // Play in-app chime if enabled
      if (triggerInAppChime && prefs.notificationSoundEnabled) {
        unawaited(playInAppNotificationSound(soundType: effectiveType));
      }

      final String channelId;
      final String channelName;
      final String channelDesc;
      final String soundResource;
      final Importance importance;
      final Priority priority;

      switch (effectiveType) {
        case NotificationSoundType.urgent:
          channelId = urgentChannelId;
          channelName = urgentChannelName;
          channelDesc = urgentChannelDescription;
          soundResource = customSoundUrgent;
          importance = Importance.max;
          priority = Priority.high;
          break;
        case NotificationSoundType.message:
          channelId = messageChannelId;
          channelName = messageChannelName;
          channelDesc = messageChannelDescription;
          soundResource = customSoundMessage;
          importance = Importance.high;
          priority = Priority.high;
          break;
        case NotificationSoundType.completed:
        case NotificationSoundType.general:
          channelId = generalChannelId;
          channelName = generalChannelName;
          channelDesc = generalChannelDescription;
          soundResource = customSoundResource;
          importance = Importance.defaultImportance;
          priority = Priority.defaultPriority;
          break;
      }

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: importance,
        priority: priority,
        playSound: prefs.notificationSoundEnabled,
        sound: prefs.notificationSoundEnabled
            ? RawResourceAndroidNotificationSound(soundResource)
            : null,
        enableVibration: prefs.vibrationEnabled,
        vibrationPattern: (isUrgent && prefs.vibrationEnabled)
            ? Int64List.fromList([0, 500, 200, 500])
            : null,
        visibility: visibility,
        ticker: title,
        actions: actions,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: isUrgent ? 'Urgent Alert' : 'SKAVIA',
        ),
      );

      final darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: '$soundResource.wav',
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
