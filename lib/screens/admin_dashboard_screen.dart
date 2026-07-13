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
      backgroundColor: const Color(0xFFF0F2F9),
      appBar: AppBar(
        title: Text('Admin Dashboard ($role)'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () => context.push('/notifications')),
          IconButton(icon: Icon(Icons.person), onPressed: () => context.push('/profile')),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());

          final actions = _getRoleBasedActions(role, context);

          return RefreshIndicator(
            onRefresh: () => provider.fetchDashboardData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (provider.dashboardData != null)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  const SizedBox(height: 24),
                  const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 12),
                  if (actions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(child: Text('No actions available for your role', style: TextStyle(color: Colors.grey))),
                    )
                  else
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: actions,
                    ),
                ],
              ),
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
      actions.add(_buildActionCard(context, 'Staff List', Icons.people, Colors.blue, '/admin_staff_list'));
      actions.add(_buildActionCard(context, 'Send Notice', Icons.send, Colors.indigo, '/admin_send_notification'));
    }

    if (role == 'super_admin' || role == 'accountant' || role == 'correspondent') {
      actions.add(_buildActionCard(context, 'Fee Summary', Icons.monetization_on, Colors.green, '/admin_fee_summary'));
      actions.add(_buildActionCard(context, 'Fee Balance', Icons.timer_outlined, Colors.red, '/admin_fee_balance'));
      actions.add(_buildActionCard(context, 'Payroll', Icons.account_balance_wallet, Colors.purple, '/admin_payroll_summary'));
      actions.add(_buildActionCard(context, 'Expenses', Icons.receipt, Colors.orange, '/admin_expenses'));
    }

    return actions;
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, MaterialColor color, String route) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.shade100, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color.shade500, size: 28),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
