import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';

class StaffStudentsScreen extends StatefulWidget {
  @override
  _StaffStudentsScreenState createState() => _StaffStudentsScreenState();
}

class _StaffStudentsScreenState extends State<StaffStudentsScreen> {
  String? _selectedClassId;
  String? _selectedSectionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Students')),
      body: Consumer<StaffProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
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
                            provider.fetchStudents(_selectedClassId!, _selectedSectionId!);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: provider.students.length,
                        itemBuilder: (context, index) {
                          final student = provider.students[index];
                          return ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text(student['name']),
                            subtitle: Text('Roll No: ${student['roll_number']}'),
                            trailing: IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () {
                                // Show student info dialog
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
