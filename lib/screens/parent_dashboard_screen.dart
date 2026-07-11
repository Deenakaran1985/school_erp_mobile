import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';

class ParentDashboardScreen extends StatefulWidget {
  @override
  _ParentDashboardScreenState createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchStudentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.children.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          if (provider.children.isEmpty) {
            return Center(child: Text('No children found.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildChildSelector(provider),
              Expanded(
                child: provider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _buildDashboardContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChildSelector(StudentProvider provider) {
    final activeChild = provider.profile;
    
    return Container(
      color: Colors.blue.shade50,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: activeChild?['id'],
          isExpanded: true,
          items: provider.children.map<DropdownMenuItem<int>>((child) {
            return DropdownMenuItem<int>(
              value: child['id'],
              child: Text(
                '${child['name']} - ${child['class'] ?? ''} ${child['section'] ?? ''}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (int? newChildId) {
            if (newChildId != null && newChildId != activeChild?['id']) {
              provider.switchChild(newChildId);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(StudentProvider provider) {
    final activeChild = provider.profile;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activeChild != null) ...[
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: activeChild['photo_url'] != null 
                    ? NetworkImage(activeChild['photo_url']) 
                    : null,
                child: activeChild['photo_url'] == null ? Icon(Icons.person, size: 40) : null,
              ),
            ),
            SizedBox(height: 16),
            Text('Attendance Summary', style: Theme.of(context).textTheme.titleLarge),
            _buildAttendanceCard(provider.attendanceSummary),
            
            SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildActionCard(context, 'Exams', Icons.assignment, '/student_exams'),
                _buildActionCard(context, 'Results', Icons.grade, '/student_results'),
                _buildActionCard(context, 'Fees', Icons.payment, '/student_fees'),
              ],
            ),
            
            SizedBox(height: 16),
            Text('Recent Homework', style: Theme.of(context).textTheme.titleLarge),
            ...provider.homework.take(3).map((hw) => Card(
              child: ListTile(
                title: Text(hw['subject'] + ' - ' + hw['title']),
                subtitle: Text('Due: ' + hw['due_date']),
                trailing: hw['submitted'] ? Icon(Icons.check_circle, color: Colors.green) : null,
              ),
            )).toList(),
          ]
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic>? summary) {
    if (summary == null) return Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No data')));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat('Present', summary['present']?.toString() ?? '0', Colors.green),
            _buildStat('Absent', summary['absent']?.toString() ?? '0', Colors.red),
            _buildStat('Late', summary['late']?.toString() ?? '0', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        child: Container(
          width: 100,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
