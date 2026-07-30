import 'package:flutter/material.dart';
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  AppUser? _user;
  bool _isLoading = true;

  AuthProvider(this._authRepository) {
    _init();
  }

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  void _init() {
    _authRepository.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    await _authRepository.signInWithGoogle();
  }

  Future<void> signInAsGuest() async {
    await _authRepository.signInAsGuest();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
