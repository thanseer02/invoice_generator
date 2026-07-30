import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Uncomment when Apple is configured
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

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
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    return AppUser.fromFirebaseUser(userCredential.user!);
  }

  @override
  Future<AppUser> signInWithApple() async {
    // Placeholder for Apple Sign In implementation.
    // Requires sign_in_with_apple package and proper Apple Developer setup.
    throw UnimplementedError('Apple Sign In requires physical device configuration.');
  }

  @override
  Future<AppUser> signInAsGuest() async {
    final credential = await _firebaseAuth.signInAnonymously();
    return AppUser.fromFirebaseUser(credential.user!);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
