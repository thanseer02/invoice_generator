class AppUser {
  final String id;
  final String? email;
  final String? displayName;
  final bool isGuest;

  AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.isGuest = false,
  });

  factory AppUser.fromFirebaseUser(dynamic firebaseUser) {
    return AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      isGuest: firebaseUser.isAnonymous,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'isGuest': isGuest,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isGuest,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}
