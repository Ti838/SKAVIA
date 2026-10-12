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
  });

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
      clientName: map['client_name']?.toString() ?? 'SKAVIA Client',
      isVerifiedClient: map['is_verified'] as bool? ?? true,
    );
  }
}
