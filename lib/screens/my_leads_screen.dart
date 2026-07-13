import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/crm_provider.dart';

class MyLeadsScreen extends StatefulWidget {
  const MyLeadsScreen({super.key});

  @override
  State<MyLeadsScreen> createState() => _MyLeadsScreenState();
}

class _MyLeadsScreenState extends State<MyLeadsScreen> {
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CrmProvider>().fetchMyLeads();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'contacted':
        return Colors.amber;
      case 'follow_up':
        return Colors.orange;
      case 'admitted':
        return Colors.green;
      case 'lost':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) => status.replaceAll('_', ' ').split(' ').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F9),
      appBar: AppBar(
        title: const Text('My Leads'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [null, 'new', 'contacted', 'follow_up', 'admitted', 'lost'].map((s) {
                final selected = _statusFilter == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s == null ? 'All' : _statusLabel(s)),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _statusFilter = s);
                      context.read<CrmProvider>().fetchMyLeads(status: s);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: Consumer<CrmProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());

          final leads = provider.myLeads;
          if (leads.isEmpty) {
            return const Center(child: Text('No leads assigned to you.', style: TextStyle(color: Colors.grey)));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMyLeads(status: _statusFilter),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: leads.length,
              itemBuilder: (context, index) {
                final lead = leads[index];
                final status = lead['status'] as String;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () => context.push('/lead_detail/${lead['id']}'),
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(status).withOpacity(0.1),
                      child: Icon(Icons.person_outline, color: _statusColor(status)),
                    ),
                    title: Text(lead['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${lead['phone'] ?? ''}${lead['campaign'] != null ? ' · ${lead['campaign']}' : ''}'),
                        if (lead['next_follow_up_date'] != null)
                          Text('Follow up: ${lead['next_follow_up_date']}', style: const TextStyle(fontSize: 12, color: Colors.orange)),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(_statusLabel(status), style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold, fontSize: 11)),
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
