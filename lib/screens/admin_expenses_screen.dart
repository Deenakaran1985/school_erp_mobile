import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AdminExpensesScreen extends StatefulWidget {
  @override
  _AdminExpensesScreenState createState() => _AdminExpensesScreenState();
}

class _AdminExpensesScreenState extends State<AdminExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expenses')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.expenses.isEmpty) return Center(child: Text('No expenses found'));

          return ListView.builder(
            itemCount: provider.expenses.length,
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return ListTile(
                leading: Icon(Icons.receipt),
                title: Text(expense['title']),
                subtitle: Text(expense['date']),
                trailing: Text('\$${expense['amount']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open add expense dialog/screen
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
