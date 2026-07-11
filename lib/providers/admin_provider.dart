import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AdminProvider with ChangeNotifier {
  final ApiService _apiService;
  
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _feeSummary;
  Map<String, dynamic>? _payrollSummary;
  List<dynamic> _staffList = [];
  List<dynamic> _expenses = [];
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  Map<String, dynamic>? get feeSummary => _feeSummary;
  Map<String, dynamic>? get payrollSummary => _payrollSummary;
  List<dynamic> get staffList => _staffList;
  List<dynamic> get expenses => _expenses;
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

  Future<void> fetchFeeSummary() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/correspondent/fee-summary');
      if (response.statusCode == 200) _feeSummary = response.data['data'];
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPayrollSummary() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/correspondent/payroll-summary');
      if (response.statusCode == 200) _payrollSummary = response.data['data'];
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStaffList() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/correspondent/staff');
      if (response.statusCode == 200) _staffList = response.data['data'] ?? [];
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/correspondent/expenses');
      if (response.statusCode == 200) _expenses = response.data['data'] ?? [];
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendNotification(Map<String, dynamic> payload) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.post('/correspondent/notifications/send', data: payload);
      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
