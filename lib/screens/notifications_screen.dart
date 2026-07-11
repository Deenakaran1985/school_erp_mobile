import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.error != null) return Center(child: Text('Error: ${provider.error}'));
          if (provider.notifications.isEmpty) return Center(child: Text('No notifications'));

          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notif = provider.notifications[index];
              final isRead = notif['read_at'] != null;

              return ListTile(
                leading: Icon(
                  isRead ? Icons.notifications_none : Icons.notifications_active,
                  color: isRead ? Colors.grey : Colors.blue,
                ),
                title: Text(notif['data']['title'] ?? 'Notification'),
                subtitle: Text(notif['data']['message'] ?? ''),
                trailing: Text(notif['created_at']?.substring(0, 10) ?? ''),
                onTap: () {
                  if (!isRead) {
                    provider.markAsRead(notif['id']);
                  }
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(notif['data']['title'] ?? 'Notification'),
                      content: Text(notif['data']['message'] ?? ''),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c), child: Text('Close'))
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
