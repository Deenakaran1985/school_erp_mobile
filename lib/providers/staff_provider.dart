import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class StaffProvider with ChangeNotifier {
  final ApiService _apiService;
  
  bool _isLoading = false;
  Map<String, dynamic>? _profile;
  List<dynamic> _myClasses = [];
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get profile => _profile;
  List<dynamic> get myClasses => _myClasses;
  String? get error => _error;

  StaffProvider(this._apiService);

  Future<void> fetchStaffData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profileRes = await _apiService.get('/staff/profile');
      if (profileRes.statusCode == 200 && profileRes.data['success'] == true) {
        _profile = profileRes.data['data'];
      }

      final classesRes = await _apiService.get('/staff/my-classes');
      if (classesRes.statusCode == 200 && classesRes.data['success'] == true) {
        _myClasses = classesRes.data['data'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
