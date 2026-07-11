import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AdminSendNotificationScreen extends StatefulWidget {
  @override
  _AdminSendNotificationScreenState createState() => _AdminSendNotificationScreenState();
}

class _AdminSendNotificationScreenState extends State<AdminSendNotificationScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedRole = 'all';

  void _submit() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) return;

    final provider = Provider.of<AdminProvider>(context, listen: false);
    final success = await provider.sendNotification({
      'title': _titleController.text,
      'message': _messageController.text,
      'target_role': _selectedRole,
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notification sent')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Send Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(labelText: 'Target Audience'),
              items: [
                DropdownMenuItem(value: 'all', child: Text('All Users')),
                DropdownMenuItem(value: 'student', child: Text('Students')),
                DropdownMenuItem(value: 'parent', child: Text('Parents')),
                DropdownMenuItem(value: 'teacher', child: Text('Teachers')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
            ),
            SizedBox(height: 16),
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
            SizedBox(height: 16),
            TextField(controller: _messageController, decoration: InputDecoration(labelText: 'Message'), maxLines: 4),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
