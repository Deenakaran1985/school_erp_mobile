import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';

class StudentResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Results & Report Cards')),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.results.isEmpty) return Center(child: Text('No results found.'));

          return ListView.builder(
            itemCount: provider.results.length,
            itemBuilder: (context, index) {
              final result = provider.results[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(result['exam_name'] ?? 'Result'),
                  subtitle: Text('Grade: ${result['grade']} - Percentage: ${result['percentage']}%'),
                  trailing: IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () {
                      // Handle report card download/viewing
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading report card...')));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
