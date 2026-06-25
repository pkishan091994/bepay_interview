import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the app-wide dark/light theme state.
///
/// Persists the user's theme preference using [FlutterSecureStorage] so the
/// choice survives app restarts and is stored securely on-device.
class ThemeNotifier extends ChangeNotifier {
  static const _key = 'isDarkMode';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeNotifier() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final value = await _storage.read(key: _key);
    _isDarkMode = value == 'true';
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storage.write(key: _key, value: _isDarkMode.toString());
  }
}
