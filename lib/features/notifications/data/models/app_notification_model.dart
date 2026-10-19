import '../../../../core/utils/uuid_util.dart';

class AppNotificationModel {
  final String id;
  final String userId;
  final String? dedupKey;
  final String title;
  final String body;
  final String category;
  final String? actionRoute;
  final Map<String, dynamic> metadata;
  final bool isRead;
  final DateTime createdAt;

  AppNotificationModel({
    required this.id,
    required this.userId,
    this.dedupKey,
    required this.title,
    required this.body,
    this.category = 'general',
    this.actionRoute,
    this.metadata = const {},
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'dedup_key': dedupKey,
        'title': title,
        'body': body,
        'category': category,
        'action_route': actionRoute,
        'metadata': metadata,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      AppNotificationModel(
        id: json['id']?.toString() ?? UuidUtil.generateUuidV4(),
        userId: json['user_id']?.toString() ?? '',
        dedupKey: json['dedup_key']?.toString(),
        title: json['title']?.toString() ?? 'Notification',
        body: json['body']?.toString() ?? '',
        category: json['category']?.toString() ?? 'general',
        actionRoute: json['action_route']?.toString(),
        metadata: json['metadata'] is Map
            ? Map<String, dynamic>.from(json['metadata'] as Map)
            : const {},
        isRead: json['is_read'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  AppNotificationModel copyWith({
    String? id,
    String? userId,
    String? dedupKey,
    String? title,
    String? body,
    String? category,
    String? actionRoute,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dedupKey: dedupKey ?? this.dedupKey,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      actionRoute: actionRoute ?? this.actionRoute,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

