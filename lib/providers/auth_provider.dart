import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../services/biometric_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final BiometricService _biometricService = BiometricService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _biometricEnabled = false;
  bool _isUnlocked = true;
  Map<String, dynamic>? _user;
  String? _lastError;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get biometricEnabled => _biometricEnabled;
  bool get isUnlocked => _isUnlocked;
  Map<String, dynamic>? get user => _user;
  String? get lastError => _lastError;

  AuthProvider(this._apiService) {
    _checkAuth();
  }

  Future<bool> isBiometricAvailable() => _biometricService.isAvailable();

  Future<void> _checkAuth() async {
    final token = await _storage.read(key: 'auth_token');
    final bioFlag = await _storage.read(key: 'biometric_enabled');
    _biometricEnabled = bioFlag == 'true';

    if (token != null) {
      _isAuthenticated = true;
      _isUnlocked = !_biometricEnabled;
      notifyListeners();
      await fetchUser();
    }
  }

  Future<bool> unlockWithBiometric() async {
    final ok = await _biometricService.authenticate();
    if (ok) {
      _isUnlocked = true;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      final available = await _biometricService.isAvailable();
      if (!available) return false;
      final ok = await _biometricService.authenticate();
      if (!ok) return false;
    }
    _biometricEnabled = enabled;
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/login', data: {
        'phone': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.write(key: 'auth_token', value: token);
        _isAuthenticated = true;
        _isUnlocked = true;
        _user = response.data['user'];
        _user!['role'] = response.data['role'];
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _lastError = 'Unexpected response (status ${response.statusCode}).';
    } on DioException catch (e) {
      final serverMessage = e.response?.data is Map ? e.response?.data['message'] : null;
      _lastError = serverMessage ??
          (e.response != null
              ? 'Server error (${e.response?.statusCode}).'
              : 'Network error: ${e.message}');
    } catch (e) {
      _lastError = 'Unexpected error: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      if (response.statusCode == 200) {
        _user = response.data['user'];
        notifyListeners();
      }
    } catch (e) {
      logout(); // Token might be invalid
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Ignore error, clear local anyway
    }
    await _storage.delete(key: 'auth_token');
    _isAuthenticated = false;
    _isUnlocked = true;
    _user = null;
    notifyListeners();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.post('/auth/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      });
      if (response.statusCode == 200) {
        // Successful password change usually logs out or requires re-login
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Error handling
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
