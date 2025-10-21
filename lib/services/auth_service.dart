import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:local_auth/local_auth.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static bool get isAuthenticated => _currentUser != null;

  static Future<bool> login(String email, String password) async {
    try {
      final user = DatabaseService.getCurrentUser();
      if (user == null) return false;

      final hashedPassword = _hashPassword(password);
      if (user.email == email && user.pinHash == hashedPassword) {
        _currentUser = user.copyWith(lastLoginAt: DateTime.now());
        await DatabaseService.saveUser(_currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> register(String name, String email, String password) async {
    try {
      // Check if user already exists
      final existingUser = DatabaseService.getCurrentUser();
      if (existingUser != null) return false;

      final hashedPassword = _hashPassword(password);
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        pinHash: hashedPassword,
      );

      await DatabaseService.saveUser(user);
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> authenticateWithBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access CheckMe',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        _currentUser = DatabaseService.getCurrentUser();
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(lastLoginAt: DateTime.now());
          await DatabaseService.saveUser(_currentUser!);
        }
      }

      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> enableBiometricAuth() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication for CheckMe',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(biometricEnabled: true);
        await DatabaseService.saveUser(_currentUser!);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> disableBiometricAuth() async {
    if (_currentUser == null) return false;

    _currentUser = _currentUser!.copyWith(biometricEnabled: false);
    await DatabaseService.saveUser(_currentUser!);
    return true;
  }

  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;

    final oldHashedPassword = _hashPassword(oldPassword);
    if (_currentUser!.pinHash != oldHashedPassword) return false;

    final newHashedPassword = _hashPassword(newPassword);
    _currentUser = _currentUser!.copyWith(pinHash: newHashedPassword);
    await DatabaseService.saveUser(_currentUser!);
    return true;
  }

  static Future<bool> updateProfile({
    String? name,
    String? avatarPath,
  }) async {
    if (_currentUser == null) return false;

    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      avatarPath: avatarPath ?? _currentUser!.avatarPath,
    );
    await DatabaseService.saveUser(_currentUser!);
    return true;
  }

  static Future<bool> updateTheme(bool isDarkMode) async {
    if (_currentUser == null) return false;

    _currentUser = _currentUser!.copyWith(isDarkMode: isDarkMode);
    await DatabaseService.saveUser(_currentUser!);
    return true;
  }

  static Future<bool> updateNotificationSettings({
    bool? enabled,
    int? timeBeforeDue,
  }) async {
    if (_currentUser == null) return false;

    _currentUser = _currentUser!.copyWith(
      notificationsEnabled: enabled ?? _currentUser!.notificationsEnabled,
      notificationTime: timeBeforeDue ?? _currentUser!.notificationTime,
    );
    await DatabaseService.saveUser(_currentUser!);
    return true;
  }

  static Future<void> logout() async {
    _currentUser = null;
  }

  static Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    try {
      await DatabaseService.clearAllData();
      _currentUser = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> isBiometricAvailable() async {
    return await _localAuth.canCheckBiometrics;
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    final enabled = _currentUser?.biometricEnabled == true;
    return enabled ? await _localAuth.getAvailableBiometrics() : [];
  }
}


