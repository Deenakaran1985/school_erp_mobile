import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final role = user?['role'] ?? 'admin';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard ($role)'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () => context.push('/notifications')),
          IconButton(icon: Icon(Icons.person), onPressed: () => context.push('/profile')),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (provider.dashboardData != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat('Students', provider.dashboardData!['total_students'].toString()),
                          _buildStat('Staff', provider.dashboardData!['total_staff'].toString()),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _getRoleBasedActions(role, context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
        Text(label),
      ],
    );
  }

  List<Widget> _getRoleBasedActions(String role, BuildContext context) {
    List<Widget> actions = [];

    if (role == 'super_admin' || role == 'principal' || role == 'correspondent') {
      actions.add(_buildActionCard(context, 'Staff List', Icons.people, '/admin_staff_list'));
      actions.add(_buildActionCard(context, 'Send Notice', Icons.send, '/admin_send_notification'));
    }

    if (role == 'super_admin' || role == 'accountant' || role == 'correspondent') {
      actions.add(_buildActionCard(context, 'Fee Summary', Icons.monetization_on, '/admin_fee_summary'));
      actions.add(_buildActionCard(context, 'Payroll', Icons.account_balance_wallet, '/admin_payroll_summary'));
      actions.add(_buildActionCard(context, 'Expenses', Icons.receipt, '/admin_expenses'));
    }

    return actions;
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () => context.push(route),
      child: Card(
        child: Container(
          width: 100,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
