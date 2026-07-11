import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;

  AuthProvider(this._apiService) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      _isAuthenticated = true;
      notifyListeners();
      await fetchUser();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.write(key: 'auth_token', value: token);
        _isAuthenticated = true;
        _user = response.data['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle login error
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      if (response.statusCode == 200) {
        _user = response.data['data'];
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
