import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/notification_service.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель администратора'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            context,
            title: 'Управление пользователями',
            icon: Icons.people,
            color: Colors.blue,
            onTap: () => context.push('/admin/users'),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: 'Управление расписанием игр',
            icon: Icons.calendar_today,
            color: Colors.green,
            onTap: () => context.push('/admin/games'),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: 'Отправить уведомление об обновлении',
            icon: Icons.notifications_active,
            color: Colors.orange,
            onTap: () => _showUpdateNotificationDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
              const SizedBox(width: 20),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateNotificationDialog(BuildContext context) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Отправить уведомление об обновлении'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(labelText: 'Текст уведомления'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              final message = messageController.text.trim();
              if (message.isNotEmpty) {
                final notificationService = NotificationService();
                await notificationService.sendNotificationToAll(
                  title: 'Обновление приложения',
                  message: message,
                );
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Уведомление отправлено')));
                  Navigator.pop(dialogContext);
                }
              }
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }
}