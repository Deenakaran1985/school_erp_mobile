import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/staff_provider.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchStaffData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final profile = staffProvider.profile;
    final classes = staffProvider.myClasses;
    
    final name = profile?['name'] ?? 'Staff Member';
    final designation = profile?['designation'] ?? 'Teacher';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F9),
      appBar: AppBar(
        title: const Text('Staff Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: staffProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : staffProvider.error != null
              ? Center(child: Text(staffProvider.error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: () => context.read<StaffProvider>().fetchStaffData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xFF10B981),
                              child: Icon(Icons.person, size: 30, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, $name',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                  Text(designation, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Quick Links
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.3,
                          children: [
                            _buildCard('Mark Attendance', Icons.checklist, Colors.teal),
                            _buildCard('Add Homework', Icons.add_task, Colors.indigo),
                            _buildCard('View Students', Icons.groups, Colors.blue),
                            _buildCard('My Payslips', Icons.receipt, Colors.purple),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Text('My Classes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 12),
                        
                        if (classes.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('No classes assigned', style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        else
                          ...classes.map((c) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo.shade50,
                                  child: Text(c['class_name']?.toString()[0] ?? 'C', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                                ),
                                title: Text('Class ${c['class_name']} - ${c['section_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(c['subject_name'] ?? 'Class Teacher'),
                                trailing: const Icon(Icons.chevron_right),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCard(String title, IconData icon, MaterialColor color) {
    return Container(
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
    );
  }
}
