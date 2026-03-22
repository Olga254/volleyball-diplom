import 'package:flutter/material.dart';
import '../../services/game_service.dart';

class TeamsFollowScreen extends StatefulWidget {
  const TeamsFollowScreen({super.key});

  @override
  State<TeamsFollowScreen> createState() => _TeamsFollowScreenState();
}

class _TeamsFollowScreenState extends State<TeamsFollowScreen> {
  List<Map<String, dynamic>> _teams = [];
  final GameService _gameService = GameService();

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _teams = [
        {'id': 1, 'name': 'Спартак', 'city': 'Москва'},
        {'id': 2, 'name': 'Динамо', 'city': 'Санкт-Петербург'},
        {'id': 3, 'name': 'Зенит', 'city': 'Казань'},
        {'id': 4, 'name': 'Локомотив', 'city': 'Новосибирск'},
        {'id': 5, 'name': 'ЦСКА', 'city': 'Москва'},
        {'id': 6, 'name': 'Факел', 'city': 'Новый Уренгой'},
      ];
    });
  }

  void _toggleFollow(String teamName) {
    setState(() {
      if (_gameService.isFollowing(teamName)) {
        _gameService.unfollowTeam(teamName);
      } else {
        _gameService.followTeam(teamName);
      }
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
        title: const Text('Команды'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _teams.length,
        itemBuilder: (context, index) {
          final team = _teams[index];
          final isFollowed = _gameService.isFollowing(team['name']);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(team['name']),
              subtitle: Text(team['city']),
              trailing: ElevatedButton(
                onPressed: () => _toggleFollow(team['name']),
                style: ElevatedButton.styleFrom(backgroundColor: isFollowed ? Colors.green : Colors.blue),
                child: Text(isFollowed ? 'Отписаться' : 'Подписаться'),
              ),
            ),
          );
        },
      ),
    );
  }
}