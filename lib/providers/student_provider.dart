import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class StudentProvider with ChangeNotifier {
  final ApiService _apiService;
  
  bool _isLoading = false;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _attendanceSummary;
  List<dynamic> _homework = [];
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get profile => _profile;
  Map<String, dynamic>? get attendanceSummary => _attendanceSummary;
  List<dynamic> get homework => _homework;
  String? get error => _error;

  StudentProvider(this._apiService);

  Future<void> fetchStudentData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Fetch Profile
      final profileRes = await _apiService.get('/profile');
      if (profileRes.statusCode == 200 && profileRes.data['success'] == true) {
        final data = profileRes.data['data'];
        // If parent, data is a list. If student, it's an object.
        // We'll just take the first student for dashboard simplicity.
        if (data is List && data.isNotEmpty) {
          _profile = data[0];
        } else if (data is Map<String, dynamic>) {
          _profile = data;
        }

        if (_profile != null) {
          final studentId = _profile!['id'];

          // 2. Fetch Attendance
          final attRes = await _apiService.get('/student/$studentId/attendance');
          if (attRes.statusCode == 200) {
            _attendanceSummary = attRes.data['summary'];
          }

          // 3. Fetch Homework
          final hwRes = await _apiService.get('/student/$studentId/homework');
          if (hwRes.statusCode == 200) {
            _homework = hwRes.data['data'];
          }
        }
      } else {
        _error = 'Failed to load profile';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
