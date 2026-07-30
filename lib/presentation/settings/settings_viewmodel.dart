import 'package:flutter/material.dart';
import '../../data/repositories/sqlite_settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SqliteSettingsRepository _repository;
  
  Map<String, String> _settings = {};
  Map<String, String> get settings => _settings;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SettingsViewModel(this._repository) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _settings = await _repository.getAllSettings();
      
      // Set some defaults if empty
      _settings['companyName'] ??= 'My Company';
      _settings['companyAddress'] ??= '';
      _settings['companyEmail'] ??= '';
      _settings['companyPhone'] ??= '';
      _settings['defaultCurrency'] ??= '\$';
      _settings['invoicePrefix'] ??= 'INV-';
      
      _settings['themeMode'] ??= 'system';
      _settings['appLanguage'] ??= 'en';
      _settings['requirePin'] ??= 'false';
      _settings['useBiometric'] ??= 'false';
      _settings['appPin'] ??= '';
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveSetting(String key, String value) async {
    await _repository.saveSetting(key, value);
    _settings[key] = value;
    notifyListeners();
  }
  
  Future<void> saveMultipleSettings(Map<String, String> newSettings) async {
    for (final entry in newSettings.entries) {
      await _repository.saveSetting(entry.key, entry.value);
      _settings[entry.key] = entry.value;
    }
    notifyListeners();
  }
  
  // Helpers
  String get companyName => _settings['companyName'] ?? 'My Company';
  String get companyAddress => _settings['companyAddress'] ?? '';
  String get companyEmail => _settings['companyEmail'] ?? '';
  String get companyPhone => _settings['companyPhone'] ?? '';
  String get companyGst => _settings['companyGst'] ?? '';
  String get defaultCurrency => _settings['defaultCurrency'] ?? '\$';
  String get invoicePrefix => _settings['invoicePrefix'] ?? 'INV-';
  String get bankDetails => _settings['bankDetails'] ?? '';
  String get upiId => _settings['upiId'] ?? '';
  String get logoPath => _settings['logoPath'] ?? '';
  String get upiQrPath => _settings['upiQrPath'] ?? '';
  
  // App Settings
  ThemeMode get themeMode {
    switch (_settings['themeMode']) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }
  
  String get appLanguage => _settings['appLanguage'] ?? 'en';
  bool get requirePin => _settings['requirePin'] == 'true';
  bool get useBiometric => _settings['useBiometric'] == 'true';
  String get appPin => _settings['appPin'] ?? '';
}
