import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class CrmProvider with ChangeNotifier {
  final ApiService _apiService;

  bool _isLoading = false;
  List<dynamic> _myLeads = [];
  Map<String, dynamic>? _selectedLead;
  String? _error;

  bool get isLoading => _isLoading;
  List<dynamic> get myLeads => _myLeads;
  Map<String, dynamic>? get selectedLead => _selectedLead;
  String? get error => _error;

  CrmProvider(this._apiService);

  Future<void> fetchMyLeads({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.get('/crm/my-leads', queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      });
      if (response.statusCode == 200) _myLeads = response.data['data'] ?? [];
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchLeadDetail(int leadId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.get('/crm/leads/$leadId');
      if (response.statusCode == 200) _selectedLead = response.data['data'];
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> logActivity(int leadId, Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.post('/crm/leads/$leadId/activity', data: payload);
      if (response.statusCode == 200) {
        await fetchLeadDetail(leadId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> convertLead(int leadId, {int? convertedStudentId}) async {
    try {
      final response = await _apiService.post('/crm/leads/$leadId/convert', data: {
        if (convertedStudentId != null) 'converted_student_id': convertedStudentId,
      });
      if (response.statusCode == 200) {
        await fetchLeadDetail(leadId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
