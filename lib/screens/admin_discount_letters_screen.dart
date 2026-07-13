import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';

class AdminDiscountLettersScreen extends StatefulWidget {
  final int studentId;
  final String studentName;

  const AdminDiscountLettersScreen({super.key, required this.studentId, required this.studentName});

  @override
  _AdminDiscountLettersScreenState createState() => _AdminDiscountLettersScreenState();
}

class _AdminDiscountLettersScreenState extends State<AdminDiscountLettersScreen> {
  static const designations = ['principal', 'correspondent', 'director', 'president', 'treasurer', 'mla', 'minister', 'other'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDiscountLetters(studentId: widget.studentId);
    });
  }

  void _openAddForm() {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    final nameController = TextEditingController();
    final referenceController = TextEditingController();
    String designation = designations.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Add Discount Letter', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Discount Amount (₹)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: designation,
                      decoration: const InputDecoration(labelText: 'Granted By (Designation)', border: OutlineInputBorder()),
                      items: designations.map((d) => DropdownMenuItem(value: d, child: Text(d[0].toUpperCase() + d.substring(1)))).toList(),
                      onChanged: (v) => setSheetState(() => designation = v ?? designations.first),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Granted By (Name)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: referenceController,
                      decoration: const InputDecoration(labelText: 'Letter Reference (optional)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () async {
                        final amount = double.tryParse(amountController.text);
                        if (amount == null || amount <= 0 || nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(content: Text('Enter a valid amount and name.')),
                          );
                          return;
                        }

                        final ok = await context.read<AdminProvider>().addDiscountLetter({
                          'student_id': widget.studentId,
                          'amount': amount,
                          'reason': reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
                          'granted_by_designation': designation,
                          'granted_by_name': nameController.text.trim(),
                          'letter_reference': referenceController.text.trim().isEmpty ? null : referenceController.text.trim(),
                        });

                        if (!mounted) return;
                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(ok ? 'Discount letter recorded.' : 'Failed to save discount letter.')),
                        );
                        if (ok) {
                          context.read<AdminProvider>().fetchDiscountLetters(studentId: widget.studentId);
                        }
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

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?['role'];
    final canGrantDiscount = ['super_admin', 'principal', 'correspondent', 'director', 'president', 'treasurer'].contains(role);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F9),
      appBar: AppBar(title: Text('Discounts - ${widget.studentName}')),
      floatingActionButton: canGrantDiscount
          ? FloatingActionButton.extended(
              onPressed: _openAddForm,
              backgroundColor: const Color(0xFF6366F1),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Discount', style: TextStyle(color: Colors.white)),
            )
          : null,
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());

          final letters = provider.discountLetters;
          if (letters.isEmpty) {
            return const Center(child: Text('No discount letters recorded for this student.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: letters.length,
            itemBuilder: (context, index) {
              final l = letters[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: const Icon(Icons.local_offer, color: Colors.green)),
                  title: Text('₹${(l['amount'] as num).toStringAsFixed(2)} - ${l['academic_year']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${l['reason'] ?? 'No reason given'}\nGranted by: ${l['granted_by_name']} (${l['granted_by_designation']})'
                    '${l['letter_reference'] != null ? '\nRef: ${l['letter_reference']}' : ''}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
