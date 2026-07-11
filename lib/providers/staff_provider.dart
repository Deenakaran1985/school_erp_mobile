import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class StaffProvider with ChangeNotifier {
  final ApiService _apiService;
  
  bool _isLoading = false;
  Map<String, dynamic>? _profile;
  List<dynamic> _myClasses = [];
  List<dynamic> _payslips = [];
  Map<String, dynamic>? _attendanceSummary;
  List<dynamic> _students = [];
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get profile => _profile;
  List<dynamic> get myClasses => _myClasses;
  List<dynamic> get payslips => _payslips;
  Map<String, dynamic>? get attendanceSummary => _attendanceSummary;
  List<dynamic> get students => _students;
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

  Future<void> fetchPayslips() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/staff/payslips');
      if (response.statusCode == 200) _payslips = response.data['data'] ?? [];
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAttendance() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/staff/attendance');
      if (response.statusCode == 200) _attendanceSummary = response.data['data'];
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStudents(String classId, String sectionId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/staff/students?class_id=$classId&section_id=$sectionId');
      if (response.statusCode == 200) _students = response.data['data'] ?? [];
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markAttendance(Map<String, dynamic> attendanceData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.post('/staff/attendance/mark', data: attendanceData);
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

  Future<bool> createHomework(Map<String, dynamic> homeworkData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.post('/staff/homework', data: homeworkData);
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
