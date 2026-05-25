import 'package:flutter/material.dart';
import '../../services/team_service.dart';
import '../team/add_player_screen.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<Map<String, dynamic>> _teamMembers = [];
  bool _isLoading = true;

  final TeamService _teamService = TeamService();
  static const String _teamId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    final members = await _teamService.getTeamMembers(_teamId);
    if (mounted) {
      setState(() {
        _teamMembers = members;
        _isLoading = false;
      });
    }
  }

  Future<void> _addPlayer() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPlayerScreen()));
    if (result == true) {
      await _loadTeamMembers();
    }
  }

  void _removePlayer(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление игрока'),
        content: const Text('Вы уверены, что хотите удалить этого игрока из команды?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _teamService.removePlayerFromTeam(_teamId, userId);
      await _loadTeamMembers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Игрок удалён')));
      }
    }
  }

  void _editPlayer(Map<String, dynamic> player) {
    final nameController = TextEditingController(text: player['full_name']);
    final phoneController = TextEditingController(text: player['phone']);
    final positionController = TextEditingController(text: player['position']);
    final numberController = TextEditingController(text: (player['number'] ?? '').toString());
    final emailController = TextEditingController(text: player['email']);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Редактировать игрока'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'ФИО')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Телефон'), keyboardType: TextInputType.phone),
              TextField(controller: positionController, decoration: const InputDecoration(labelText: 'Позиция')),
              TextField(controller: numberController, decoration: const InputDecoration(labelText: 'Номер'), keyboardType: TextInputType.number),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), enabled: false),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              await _teamService.updatePlayerInTeam(
                userId: player['user_id'],
                fullName: nameController.text,
                phone: phoneController.text,
                position: positionController.text,
                number: int.tryParse(numberController.text) ?? 0,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              await _loadTeamMembers();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Данные игрока обновлены')));
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Команда'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPlayer,
            tooltip: 'Добавить игрока',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _teamMembers.length,
              itemBuilder: (context, index) {
                final player = _teamMembers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(player['number']?.toString() ?? '?', style: const TextStyle(color: Colors.blue)),
                    ),
                    title: Text('${player['full_name'] ?? ''}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Позиция: ${player['position'] ?? 'не указана'}'),
                        Text('Дата рождения: ${player['birth_date'] ?? '—'}'),
                        Text('Телефон: ${player['phone'] ?? '—'}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editPlayer(player),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removePlayer(player['user_id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}