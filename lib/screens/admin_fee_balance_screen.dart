import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AdminFeeBalanceScreen extends StatefulWidget {
  @override
  _AdminFeeBalanceScreenState createState() => _AdminFeeBalanceScreenState();
}

class _AdminFeeBalanceScreenState extends State<AdminFeeBalanceScreen> {
  final Set<int> _notifying = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchFeeBalanceReport();
    });
  }

  Future<void> _notify(int studentId, String name) async {
    setState(() => _notifying.add(studentId));
    final ok = await context.read<AdminProvider>().notifyParentOfBalance(studentId);
    if (!mounted) return;
    setState(() => _notifying.remove(studentId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Parent of $name notified.' : 'Could not send notification.')),
    );
  }

  Color _daysColor(int days) {
    if (days <= 0) return Colors.blue;
    if (days < 15) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F9),
      appBar: AppBar(title: const Text('Fee Balance Report')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());

          final report = provider.feeBalanceReport;
          if (report.isEmpty) {
            return const Center(child: Text('No students with a pending balance.', style: TextStyle(color: Colors.grey)));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchFeeBalanceReport(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: report.length,
              itemBuilder: (context, index) {
                final s = report[index];
                final int days = s['days_pending'] ?? 0;
                final double balance = (s['balance'] as num).toDouble();
                final bool isNotifying = _notifying.contains(s['student_id']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('${s['class'] ?? ''} - ${s['section'] ?? ''}', style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            if (s['has_arrears'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                                child: const Text('Arrears', style: TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('₹${balance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: _daysColor(days).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                days > 0 ? '$days days overdue' : 'Not yet due',
                                style: TextStyle(color: _daysColor(days), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push('/admin_discount_letters', extra: {
                                  'student_id': s['student_id'],
                                  'student_name': s['name'],
                                }),
                                icon: const Icon(Icons.local_offer_outlined, size: 16),
                                label: const Text('Discounts'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: isNotifying ? null : () => _notify(s['student_id'], s['name']),
                                icon: isNotifying
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.notifications_active_outlined, size: 16),
                                label: Text(isNotifying ? 'Sending...' : 'Notify Parent'),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
