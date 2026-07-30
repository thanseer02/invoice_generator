enum UserRole { admin, manager, employee }

class AppUser {
  final String id;
  final String? companyId; // Nullable for backwards compat/guests
  final String? email;
  final String? displayName;
  final bool isGuest;
  final UserRole role;

  AppUser({
    required this.id,
    this.companyId,
    this.email,
    this.displayName,
    this.isGuest = false,
    this.role = UserRole.admin, // Default to admin for first user
  });

  factory AppUser.fromFirebaseUser(dynamic firebaseUser) {
    return AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      isGuest: firebaseUser.isAnonymous,
      role: UserRole.admin, // We will map this properly later
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'email': email,
      'displayName': displayName,
      'isGuest': isGuest,
      'role': role.name,
    };
  }

  AppUser copyWith({
    String? id,
    String? companyId,
    String? email,
    String? displayName,
    bool? isGuest,
    UserRole? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isGuest: isGuest ?? this.isGuest,
      role: role ?? this.role,
    );
  }
}
