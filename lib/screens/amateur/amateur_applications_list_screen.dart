import 'package:flutter/material.dart';
import '../../services/application_service.dart';
import '../../services/notification_service.dart';

class AmateurApplicationsListScreen extends StatefulWidget {
  final String gameId;
  const AmateurApplicationsListScreen({super.key, required this.gameId});

  @override
  State<AmateurApplicationsListScreen> createState() => _AmateurApplicationsListScreenState();
}

class _AmateurApplicationsListScreenState extends State<AmateurApplicationsListScreen> {
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;
  final ApplicationService _appService = ApplicationService();
  final NotificationService _notifService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    _applications = await _appService.getActiveApplications();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Игроки, ищущие команду')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _applications.length,
              itemBuilder: (context, index) {
                final app = _applications[index];
                final player = app['profiles'];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(player['full_name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Позиция: ${app['position']}'),
                        Text('Стаж: ${app['experience']}'),
                        Text('Тип: ${app['game_type']}'),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _invitePlayer(app['user_id']),
                      child: const Text('Пригласить'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _invitePlayer(String userId) async {
    await _appService.invitePlayerToGame(widget.gameId, userId);
    await _notifService.sendNotificationToAll(
      title: 'Приглашение на игру',
      message: 'Вас пригласили на игру!',
      userId: userId,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Приглашение отправлено')));
    }
  }
}