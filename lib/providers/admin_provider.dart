import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AdminProvider with ChangeNotifier {
  final ApiService _apiService;
  
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardData;
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  String? get error => _error;

  AdminProvider(this._apiService);

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/correspondent/dashboard');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _dashboardData = response.data['data'];
      } else {
        _error = 'Failed to load data';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
