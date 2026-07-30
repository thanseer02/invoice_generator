import 'dart:io';

abstract class CloudBackupProvider {
  String get providerName;
  bool get isAuthenticated;

  Future<bool> authenticate();
  Future<void> signOut();
  
  Future<bool> uploadBackup(File databaseFile);
  Future<File?> downloadLatestBackup();
  
  Future<DateTime?> getLastBackupTimestamp();
}

class GoogleDriveProvider implements CloudBackupProvider {
  bool _authenticated = false;

  @override
  String get providerName => 'Google Drive';

  @override
  bool get isAuthenticated => _authenticated;

  @override
  Future<bool> authenticate() async {
    // MOCK: In production, use google_sign_in and googleapis
    await Future.delayed(const Duration(seconds: 1));
    _authenticated = true;
    return true;
  }

  @override
  Future<void> signOut() async {
    _authenticated = false;
  }

  @override
  Future<bool> uploadBackup(File databaseFile) async {
    // MOCK
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Future<File?> downloadLatestBackup() async {
    // MOCK
    await Future.delayed(const Duration(seconds: 2));
    return null; // For demo, returning null
  }

  @override
  Future<DateTime?> getLastBackupTimestamp() async {
    // MOCK
    return DateTime.now().subtract(const Duration(days: 1));
  }
}

class DropboxProvider implements CloudBackupProvider {
  bool _authenticated = false;

  @override
  String get providerName => 'Dropbox';

  @override
  bool get isAuthenticated => _authenticated;

  @override
  Future<bool> authenticate() async {
    // MOCK: In production, launch OAuth flow
    await Future.delayed(const Duration(seconds: 1));
    _authenticated = true;
    return true;
  }

  @override
  Future<void> signOut() async {
    _authenticated = false;
  }

  @override
  Future<bool> uploadBackup(File databaseFile) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Future<File?> downloadLatestBackup() async {
    await Future.delayed(const Duration(seconds: 2));
    return null;
  }

  @override
  Future<DateTime?> getLastBackupTimestamp() async {
    return DateTime.now().subtract(const Duration(days: 3));
  }
}
