import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = user?['name'] ?? 'Admin';
    final adminProvider = context.watch<AdminProvider>();
    final data = adminProvider.dashboardData;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F9),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          )
        ],
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminProvider.error != null
              ? Center(child: Text(adminProvider.error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: () => context.read<AdminProvider>().fetchDashboardData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, $name 👋',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Academic Year: ${data?['academic_year'] ?? 'Loading...'}',
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 24),
                        
                        // KPI Grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                          children: [
                            _buildKpiCard('Total Students', '${data?['total_students'] ?? 0}', Icons.people, const Color(0xFF6366F1)),
                            _buildKpiCard('Staff Members', '${data?['total_staff'] ?? 0}', Icons.badge, const Color(0xFF10B981)),
                            _buildKpiCard('Fee Collected', '₹${data?['fee_collected'] ?? 0}', Icons.currency_rupee, const Color(0xFF06B6D4)),
                            _buildKpiCard('Payroll Pending', '₹${data?['payroll_pending'] ?? 0}', Icons.account_balance_wallet, const Color(0xFFF43F5E)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Quick Actions
                        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildActionBtn('Fees', Icons.payments, Colors.indigo),
                            _buildActionBtn('Exams', Icons.assignment, Colors.teal),
                            _buildActionBtn('Notify', Icons.notifications_active, Colors.orange),
                            _buildActionBtn('Payroll', Icons.account_balance, Colors.purple),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionBtn(String title, IconData icon, MaterialColor color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.shade50,
          child: Icon(icon, color: color.shade500, size: 28),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
      ],
    );
  }
}
