import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Uncomment when Apple is configured
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user == null) return null;
      return AppUser.fromFirebaseUser(user);
    });
  }

  @override
  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? AppUser.fromFirebaseUser(user) : null;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AppUser.fromFirebaseUser(credential.user!);
  }

  @override
  Future<AppUser> registerWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AppUser.fromFirebaseUser(credential.user!);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    // Placeholder for Google Sign In implementation.
    // Requires physical device configuration and Firebase Setup.
    throw UnimplementedError('Google Sign In requires Firebase configuration.');
  }

  @override
  Future<AppUser> signInWithApple() async {
    // Placeholder for Apple Sign In implementation.
    // Requires sign_in_with_apple package and proper Apple Developer setup.
    throw UnimplementedError('Apple Sign In requires Apple Developer configuration.');
  }

  @override
  Future<AppUser> signInAsGuest() async {
    final credential = await _firebaseAuth.signInAnonymously();
    return AppUser.fromFirebaseUser(credential.user!);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
