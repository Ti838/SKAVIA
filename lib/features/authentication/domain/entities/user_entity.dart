/// Domain entity representing an authenticated user and their active role mode in SKAVIA.
class UserEntity {
  final String userId;
  final String fullName;
  final String? email;
  final String? phone;
  final String activeMode; // 'client', 'worker', 'admin'
  final String status;
  final String? avatarUrl;
  final String location;
  final List<String> roles;

  const UserEntity({
    required this.userId,
    required this.fullName,
    this.email,
    this.phone,
    this.activeMode = 'client',
    this.status = 'Active',
    this.avatarUrl,
    this.location = 'Dhaka, Bangladesh',
    this.roles = const ['Customer'],
  });

  bool get isWorker => activeMode == 'worker' || roles.contains('Worker');
  bool get isAdmin =>
      activeMode == 'admin' ||
      roles.contains('Admin') ||
      roles.contains('Super Admin');
}
