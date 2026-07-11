import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/student_provider.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStudentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final profile = studentProvider.profile;
    final attSummary = studentProvider.attendanceSummary;
    final homework = studentProvider.homework;
    
    // Calculate values
    final name = profile?['name'] ?? 'Student';
    final className = profile?['class_section'] ?? '';
    
    // Calculate attendance percentage
    final totalAtt = (attSummary?['present'] ?? 0) + (attSummary?['absent'] ?? 0) + (attSummary?['late'] ?? 0);
    final present = (attSummary?['present'] ?? 0) + (attSummary?['late'] ?? 0);
    final attPercent = totalAtt > 0 ? ((present / totalAtt) * 100).toStringAsFixed(1) : '0.0';

    final pendingHw = homework.where((hw) => hw['submitted'] == false).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F9),
      appBar: AppBar(
        title: const Text('Student Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          )
        ],
      ),
      body: studentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentProvider.error != null
              ? Center(child: Text(studentProvider.error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: () => context.read<StudentProvider>().fetchStudentData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.indigo.shade100,
                              backgroundImage: profile?['photo_url'] != null ? NetworkImage(profile!['photo_url']) : null,
                              child: profile?['photo_url'] == null 
                                  ? const Icon(Icons.person, size: 30, color: Colors.indigo)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi, $name 👋',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                  if (className.isNotEmpty)
                                    Text('Class $className', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
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
                            _buildCard('Attendance', '$attPercent%', Icons.check_circle_outline, Colors.green, null),
                            _buildCard('Homework', '$pendingHw Pending', Icons.book_outlined, Colors.orange, null),
                            _buildCard('Exams', 'View Results', Icons.assessment_outlined, Colors.blue, () => context.push('/student_exams')),
                            _buildCard('Fees', 'No Dues', Icons.receipt_long_outlined, Colors.purple, () => context.push('/student_fees')),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Text('Recent Homework', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 12),
                        
                        if (homework.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('No homework assigned', style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        else
                          ...homework.take(3).map((hw) {
                            final bool submitted = hw['submitted'] == true;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: submitted ? Colors.green.shade50 : Colors.orange.shade50,
                                  child: Icon(
                                    submitted ? Icons.check : Icons.access_time, 
                                    color: submitted ? Colors.green : Colors.orange,
                                  ),
                                ),
                                title: Text(hw['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Due: ${hw['due_date']}'),
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

  Widget _buildCard(String title, String subtitle, IconData icon, MaterialColor color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
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
            Text(subtitle, style: TextStyle(color: color.shade700, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
