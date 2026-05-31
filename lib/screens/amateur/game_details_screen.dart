import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/invitation_service.dart';

class GameDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> game;
  const GameDetailsScreen({super.key, required this.game});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  final InvitationService _invitationService = InvitationService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final auth = Provider.of<AuthProvider>(context);
    final currentUserId = auth.currentUser?.id;
    final isOwner = game['created_by'] == currentUserId;

    return Scaffold(
      appBar: AppBar(title: Text(game['title'] ?? 'Детали игры')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📅 Дата: ${game['date']} ${game['start_time']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('📍 Место: ${game['location']}', style: const TextStyle(fontSize: 16)),
                    if (game['address'] != null) ...[
                      const SizedBox(height: 8),
                      Text('🏠 Адрес: ${game['address']}', style: const TextStyle(fontSize: 16)),
                    ],
                    const SizedBox(height: 8),
                    Text('💰 Стоимость: ${game['cost'] ?? 'Бесплатно'}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('👫 Пол: ${game['target_gender'] ?? 'любой'}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('🎂 Возраст: ${game['target_age'] ?? 'любой'}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('⚡ Уровень: ${game['level'] ?? 'любой'}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('👨‍⚖️ Судья: ${game['referee'] ?? 'не указан'}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isOwner)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _showInviteDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Пригласить участника'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInviteDialog() async {
    final emailController = TextEditingController();
    Map<String, dynamic>? foundUser;
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Пригласить игрока'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email приглашаемого', border: OutlineInputBorder()),
                onChanged: (value) async {
                  if (value.length > 3) {
                    final user = await _invitationService.findUserByEmail(value);
                    if (dialogContext.mounted) {
                      setStateDialog(() => foundUser = user);
                    }
                  }
                },
              ),
              if (foundUser != null)
                Card(
                  margin: const EdgeInsets.only(top: 16),
                  child: ListTile(
                    title: Text(foundUser!['full_name'] ?? 'Без имени'),
                    subtitle: Text(foundUser!['email']),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                if (foundUser != null) {
                  setState(() => _isLoading = true);
                  try {
                    await _invitationService.inviteToGame(
                      gameId: widget.game['id'],
                      inviterId: Provider.of<AuthProvider>(context, listen: false).currentUser!.id,
                      inviteeId: foundUser!['id'],
                    );
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Приглашение отправлено')));
                      Navigator.pop(dialogContext);
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
                    }
                  } finally {
                    setState(() => _isLoading = false);
                  }
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Пользователь не найден')));
                }
              },
              child: const Text('Пригласить'),
            ),
          ],
        ),
      ),
    );
  }
}