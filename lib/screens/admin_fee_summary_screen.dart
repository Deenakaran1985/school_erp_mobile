import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AdminFeeSummaryScreen extends StatefulWidget {
  @override
  _AdminFeeSummaryScreenState createState() => _AdminFeeSummaryScreenState();
}

class _AdminFeeSummaryScreenState extends State<AdminFeeSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchFeeSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fee Summary')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.feeSummary == null) return Center(child: Text('No data'));

          final collected = provider.feeSummary!['collected'];
          final pending = provider.feeSummary!['pending'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: Text('Total Collected'),
                    trailing: Text('\$${collected}', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Total Pending'),
                    trailing: Text('\$${pending}', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
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
