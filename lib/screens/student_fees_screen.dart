import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';

class StudentFeesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fees'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: Consumer<StudentProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) return Center(child: CircularProgressIndicator());

            return TabBarView(
              children: [
                _buildPendingFees(provider.pendingFees, context),
                _buildFeeHistory(provider.feeHistory),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPendingFees(List<dynamic> pending, BuildContext context) {
    if (pending.isEmpty) return Center(child: Text('No pending fees!'));
    return ListView.builder(
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final fee = pending[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(fee['title'] ?? 'Fee'),
            subtitle: Text('Due: ${fee['due_date']}'),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment gateway mock opened.')));
              },
              child: Text('Pay \$${fee['amount']}'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeeHistory(List<dynamic> history) {
    if (history.isEmpty) return Center(child: Text('No fee history.'));
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final fee = history[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(fee['title'] ?? 'Fee'),
            subtitle: Text('Paid on: ${fee['paid_at']}'),
            trailing: Text('\$${fee['amount']}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
