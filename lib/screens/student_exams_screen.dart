import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';

class StudentExamsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exams')),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.exams.isEmpty) return Center(child: Text('No exams found.'));

          return ListView.builder(
            itemCount: provider.exams.length,
            itemBuilder: (context, index) {
              final exam = provider.exams[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(exam['name'] ?? 'Exam'),
                  subtitle: Text('Start Date: ${exam['start_date']}'),
                  trailing: Text(exam['status'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
