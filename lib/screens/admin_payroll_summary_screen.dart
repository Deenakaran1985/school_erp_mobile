import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AdminPayrollSummaryScreen extends StatefulWidget {
  @override
  _AdminPayrollSummaryScreenState createState() => _AdminPayrollSummaryScreenState();
}

class _AdminPayrollSummaryScreenState extends State<AdminPayrollSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchPayrollSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payroll Summary')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.payrollSummary == null) return Center(child: Text('No data'));

          final disbursed = provider.payrollSummary!['disbursed'];
          final pending = provider.payrollSummary!['pending'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: Text('Total Disbursed'),
                    trailing: Text('\$${disbursed}', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Total Pending'),
                    trailing: Text('\$${pending}', style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
