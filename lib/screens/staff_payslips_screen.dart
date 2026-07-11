import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';

class StaffPayslipsScreen extends StatefulWidget {
  @override
  _StaffPayslipsScreenState createState() => _StaffPayslipsScreenState();
}

class _StaffPayslipsScreenState extends State<StaffPayslipsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StaffProvider>(context, listen: false).fetchPayslips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payslips')),
      body: Consumer<StaffProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.payslips.isEmpty) return Center(child: Text('No payslips found.'));

          return ListView.builder(
            itemCount: provider.payslips.length,
            itemBuilder: (context, index) {
              final payslip = provider.payslips[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.receipt),
                  title: Text('Month: ${payslip['month']}'),
                  subtitle: Text('Net Salary: \$${payslip['net_salary']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading...')));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
