import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';

class CreateHomeworkScreen extends StatefulWidget {
  @override
  _CreateHomeworkScreenState createState() => _CreateHomeworkScreenState();
}

class _CreateHomeworkScreenState extends State<CreateHomeworkScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedClassId;
  String? _selectedSectionId;

  void _submit() async {
    if (_titleController.text.isEmpty || _selectedClassId == null) return;

    final provider = Provider.of<StaffProvider>(context, listen: false);
    final success = await provider.createHomework({
      'title': _titleController.text,
      'description': _descController.text,
      'class_id': _selectedClassId,
      'section_id': _selectedSectionId,
      'due_date': DateTime.now().add(Duration(days: 2)).toIso8601String().split('T')[0], // Mock due date
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Homework created')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create homework')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Homework')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<StaffProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                DropdownButtonFormField<String>(
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
                    }
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 4,
                ),
                SizedBox(height: 32),
                provider.isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                        child: Text('Create'),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
