import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crm_provider.dart';

class LeadDetailScreen extends StatefulWidget {
  final int leadId;

  const LeadDetailScreen({super.key, required this.leadId});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  static const activityTypes = ['call', 'whatsapp', 'email', 'meeting', 'note'];
  static const statuses = ['new', 'contacted', 'follow_up', 'admitted', 'lost'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CrmProvider>().fetchLeadDetail(widget.leadId);
    });
  }

  void _openLogActivitySheet() {
    String activityType = activityTypes.first;
    String? newStatus;
    DateTime? nextFollowUp;
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Log Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: activityType,
                      decoration: const InputDecoration(labelText: 'Activity Type', border: OutlineInputBorder()),
                      items: activityTypes.map((t) => DropdownMenuItem(value: t, child: Text(t[0].toUpperCase() + t.substring(1)))).toList(),
                      onChanged: (v) => setSheetState(() => activityType = v ?? activityTypes.first),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: newStatus,
                      decoration: const InputDecoration(labelText: 'Update Status (optional)', border: OutlineInputBorder()),
                      items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ')))).toList(),
                      onChanged: (v) => setSheetState(() => newStatus = v),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: sheetContext,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setSheetState(() => nextFollowUp = picked);
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(nextFollowUp == null
                          ? 'Set Next Follow-up Date (optional)'
                          : 'Follow-up: ${nextFollowUp!.toIso8601String().substring(0, 10)}'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () async {
                        final ok = await context.read<CrmProvider>().logActivity(widget.leadId, {
                          'activity_type': activityType,
                          'notes': notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                          'status': newStatus,
                          'next_follow_up_date': nextFollowUp?.toIso8601String().substring(0, 10),
                        });
                        if (!mounted) return;
                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(ok ? 'Activity logged.' : 'Failed to log activity.')),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _convert() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Mark as Admitted'),
        content: const Text('Confirm this lead has been admitted to the school?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final ok = await context.read<CrmProvider>().convertLead(widget.leadId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Lead marked as admitted!' : 'Failed to update lead.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F9),
      appBar: AppBar(title: const Text('Lead Detail')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openLogActivitySheet,
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
        label: const Text('Log Activity', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<CrmProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.selectedLead == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final lead = provider.selectedLead!;
          final activities = lead['activities'] as List<dynamic>? ?? [];

          return RefreshIndicator(
            onRefresh: () => provider.fetchLeadDetail(widget.leadId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(lead['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              if (lead['status'] != 'admitted')
                                TextButton.icon(
                                  onPressed: _convert,
                                  icon: const Icon(Icons.check_circle_outline, size: 18),
                                  label: const Text('Admit'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${lead['phone'] ?? ''}${lead['email'] != null ? ' · ${lead['email']}' : ''}', style: const TextStyle(color: Colors.grey)),
                          if (lead['interested_class'] != null) Text('Interested in: ${lead['interested_class']}'),
                          if (lead['campaign'] != null) Text('Campaign: ${lead['campaign']}'),
                          Text('Source: ${lead['source']}'),
                          if (lead['next_follow_up_date'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text('Next follow-up: ${lead['next_follow_up_date']}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Activity History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (activities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('No activity logged yet.', style: TextStyle(color: Colors.grey))),
                    )
                  else
                    ...activities.map((a) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                          child: ListTile(
                            leading: const Icon(Icons.history, color: Color(0xFF6366F1)),
                            title: Text((a['activity_type'] as String).replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(a['notes'] ?? ''),
                            trailing: Text(a['created_at'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                        )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
