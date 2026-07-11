import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AdminStaffListScreen extends StatefulWidget {
  @override
  _AdminStaffListScreenState createState() => _AdminStaffListScreenState();
}

class _AdminStaffListScreenState extends State<AdminStaffListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchStaffList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Staff List')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.staffList.isEmpty) return Center(child: Text('No staff found'));

          return ListView.builder(
            itemCount: provider.staffList.length,
            itemBuilder: (context, index) {
              final staff = provider.staffList[index];
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(staff['name']),
                subtitle: Text(staff['designation'] ?? 'Staff'),
                trailing: Text(staff['department'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
