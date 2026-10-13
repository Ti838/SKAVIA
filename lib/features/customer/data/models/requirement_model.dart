class JobRequirementItem {
  final String id;
  final String title;
  final String category;
  final String categoryId;
  final String description;
  final String location;
  final double budgetMin;
  final double budgetMax;
  final String urgency;
  final String timeAgo;
  final String clientName;
  final bool isVerifiedClient;
  final int likesCount;
  final bool isLikedByMe;
  final int commentsCount;
  final bool isSavedByMe;
  final String authorRole;
  final String postType; // 'Job', 'Service Request', 'Professional Update'
  final String status; // 'Open', 'In Progress', 'Closed'
  final List<String> skills;

  const JobRequirementItem({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryId,
    required this.description,
    required this.location,
    required this.budgetMin,
    required this.budgetMax,
    required this.urgency,
    required this.timeAgo,
    required this.clientName,
    this.isVerifiedClient = true,
    this.likesCount = 0,
    this.isLikedByMe = false,
    this.commentsCount = 0,
    this.isSavedByMe = false,
    this.authorRole = 'Client',
    this.postType = 'Job',
    this.status = 'Open',
    this.skills = const [],
  });

  JobRequirementItem copyWith({
    String? id,
    String? title,
    String? category,
    String? categoryId,
    String? description,
    String? location,
    double? budgetMin,
    double? budgetMax,
    String? urgency,
    String? timeAgo,
    String? clientName,
    bool? isVerifiedClient,
    int? likesCount,
    bool? isLikedByMe,
    int? commentsCount,
    bool? isSavedByMe,
    String? authorRole,
    String? postType,
    String? status,
    List<String>? skills,
  }) {
    return JobRequirementItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      location: location ?? this.location,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      urgency: urgency ?? this.urgency,
      timeAgo: timeAgo ?? this.timeAgo,
      clientName: clientName ?? this.clientName,
      isVerifiedClient: isVerifiedClient ?? this.isVerifiedClient,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      commentsCount: commentsCount ?? this.commentsCount,
      isSavedByMe: isSavedByMe ?? this.isSavedByMe,
      authorRole: authorRole ?? this.authorRole,
      postType: postType ?? this.postType,
      status: status ?? this.status,
      skills: skills ?? this.skills,
    );
  }

  factory JobRequirementItem.fromMap(Map<String, dynamic> map) {
    return JobRequirementItem(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General',
      categoryId: map['category_id']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      location: map['location']?.toString() ?? 'Dhaka',
      budgetMin: (map['budget_min'] as num?)?.toDouble() ?? 500.0,
      budgetMax: (map['budget_max'] as num?)?.toDouble() ?? 1500.0,
      urgency: map['urgency']?.toString() ?? 'Standard',
      timeAgo: map['created_at'] != null ? 'Recently' : 'Just now',
      clientName: map['client_name']?.toString() ?? 'SKAVIA Member',
      isVerifiedClient: map['is_verified'] as bool? ?? true,
      likesCount: (map['likes_count'] as num?)?.toInt() ?? 0,
      isLikedByMe: map['is_liked'] as bool? ?? false,
      commentsCount: (map['comments_count'] as num?)?.toInt() ?? 0,
      isSavedByMe: map['is_saved'] as bool? ?? false,
      authorRole: map['author_role']?.toString() ?? 'Client',
      postType: map['post_type']?.toString() ?? 'Job',
      status: map['status']?.toString() ?? 'Open',
      skills: (map['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
