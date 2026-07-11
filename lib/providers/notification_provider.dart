import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService;
  
  bool _isLoading = false;
  List<dynamic> _notifications = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<dynamic> get notifications => _notifications;
  String? get error => _error;

  NotificationProvider(this._apiService);

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/notifications');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _notifications = response.data['data'] ?? [];
      } else {
        _error = 'Failed to load notifications';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await _apiService.post('/notifications/$id/read');
      if (response.statusCode == 200) {
        // Update local state
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['read_at'] = DateTime.now().toIso8601String();
          notifyListeners();
        }
      }
    } catch (e) {
      // Ignore error for now
    }
  }
}
