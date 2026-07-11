import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class StudentProvider with ChangeNotifier {
  final ApiService _apiService;
  
  bool _isLoading = false;
  Map<String, dynamic>? _profile;
  List<dynamic> _children = []; // For parents
  
  Map<String, dynamic>? _attendanceSummary;
  List<dynamic> _homework = [];
  List<dynamic> _exams = [];
  List<dynamic> _results = [];
  List<dynamic> _pendingFees = [];
  List<dynamic> _feeHistory = [];
  
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get profile => _profile;
  List<dynamic> get children => _children;
  Map<String, dynamic>? get attendanceSummary => _attendanceSummary;
  List<dynamic> get homework => _homework;
  List<dynamic> get exams => _exams;
  List<dynamic> get results => _results;
  List<dynamic> get pendingFees => _pendingFees;
  List<dynamic> get feeHistory => _feeHistory;
  String? get error => _error;

  StudentProvider(this._apiService);

  Future<void> fetchStudentData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profileRes = await _apiService.get('/profile');
      if (profileRes.statusCode == 200 && profileRes.data['success'] == true) {
        final data = profileRes.data['data'];
        
        if (data is List) {
          // It's a parent with multiple children
          _children = data;
          if (_children.isNotEmpty) {
            _profile = _children[0]; // Set active profile to first child by default
          }
        } else if (data is Map<String, dynamic>) {
          // It's a single student
          _profile = data;
          _children = [];
        }

        if (_profile != null) {
          await _fetchDataForActiveProfile();
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
  
  Future<void> switchChild(int childId) async {
    final targetChild = _children.firstWhere((c) => c['id'] == childId, orElse: () => null);
    if (targetChild != null) {
      _profile = targetChild;
      _isLoading = true;
      notifyListeners();
      
      await _fetchDataForActiveProfile();
      
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchDataForActiveProfile() async {
    final studentId = _profile!['id'];

    // 1. Fetch Attendance
    try {
      final attRes = await _apiService.get('/student/$studentId/attendance');
      if (attRes.statusCode == 200) _attendanceSummary = attRes.data['summary'];
    } catch (_) {}

    // 2. Fetch Homework
    try {
      final hwRes = await _apiService.get('/student/$studentId/homework');
      if (hwRes.statusCode == 200) _homework = hwRes.data['data'] ?? [];
    } catch (_) {}
    
    // 3. Fetch Exams
    try {
      final examRes = await _apiService.get('/exams?student_id=$studentId');
      if (examRes.statusCode == 200) _exams = examRes.data['data'] ?? [];
    } catch (_) {}
    
    // 4. Fetch Results
    try {
      final resRes = await _apiService.get('/results?student_id=$studentId');
      if (resRes.statusCode == 200) _results = resRes.data['data'] ?? [];
    } catch (_) {}
    
    // 5. Fetch Fees (Pending & History)
    try {
      final pendingRes = await _apiService.get('/fees/pending?student_id=$studentId');
      if (pendingRes.statusCode == 200) _pendingFees = pendingRes.data['data'] ?? [];
      
      final historyRes = await _apiService.get('/fees/history?student_id=$studentId');
      if (historyRes.statusCode == 200) _feeHistory = historyRes.data['data'] ?? [];
    } catch (_) {}
  }
}
