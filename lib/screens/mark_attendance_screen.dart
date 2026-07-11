import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';

class MarkAttendanceScreen extends StatefulWidget {
  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  String? _selectedClassId;
  String? _selectedSectionId;
  Map<int, String> _attendanceMap = {};

  void _submit() async {
    if (_selectedClassId == null || _selectedSectionId == null) return;
    
    final provider = Provider.of<StaffProvider>(context, listen: false);
    final success = await provider.markAttendance({
      'class_id': _selectedClassId,
      'section_id': _selectedSectionId,
      'date': DateTime.now().toIso8601String().split('T')[0],
      'attendance': _attendanceMap,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Attendance marked successfully' : 'Failed to mark attendance')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mark Attendance')),
      body: Consumer<StaffProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Class & Section'),
                  items: provider.myClasses.map((cls) {
                    return DropdownMenuItem<String>(
                      value: '${cls['class_id']}_${cls['section_id']}',
                      child: Text('${cls['class_name']} - ${cls['section_name']}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final parts = val.split('_');
                      _selectedClassId = parts[0];
                      _selectedSectionId = parts[1];
                      _attendanceMap.clear();
                      provider.fetchStudents(_selectedClassId!, _selectedSectionId!);
                    }
                  },
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: provider.students.length,
                        itemBuilder: (context, index) {
                          final student = provider.students[index];
                          final sId = student['id'];
                          // Default to present
                          _attendanceMap.putIfAbsent(sId, () => 'present');

                          return ListTile(
                            title: Text(student['name']),
                            subtitle: Text('Roll No: ${student['roll_number']}'),
                            trailing: DropdownButton<String>(
                              value: _attendanceMap[sId],
                              items: [
                                DropdownMenuItem(value: 'present', child: Text('Present')),
                                DropdownMenuItem(value: 'absent', child: Text('Absent')),
                                DropdownMenuItem(value: 'late', child: Text('Late')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _attendanceMap[sId] = val;
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
              if (provider.students.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                    child: Text('Submit Attendance'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
