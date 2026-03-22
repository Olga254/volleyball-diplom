import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _notifications = [
        {'title': 'Новая игра', 'message': 'Капитан Иван приглашает вас на игру 10.04.2025', 'time': '2025-04-01 10:00', 'read': false},
        {'title': 'Обновление приложения', 'message': 'Доступна новая версия. Обновитесь!', 'time': '2025-03-30 15:30', 'read': true},
        {'title': 'Изменение состава', 'message': 'В вашу команду добавлен новый игрок', 'time': '2025-03-29 09:15', 'read': false},
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Уведомления'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final n = _notifications[index];
                return Card(
                  color: n['read'] ? null : Colors.blue.shade50,
                  child: ListTile(
                    title: Text(n['title']),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n['message']), const SizedBox(height: 4), Text(n['time'], style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                    trailing: n['read'] ? null : const Icon(Icons.circle, size: 12, color: Colors.blue),
                    onTap: () => setState(() => n['read'] = true),
                  ),
                );
              },
            ),
    );
  }
}