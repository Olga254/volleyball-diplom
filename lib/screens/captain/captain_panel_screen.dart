import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/game_service.dart';
import '../../services/team_service.dart';

class CaptainPanelScreen extends StatefulWidget {
  const CaptainPanelScreen({super.key});

  @override
  State<CaptainPanelScreen> createState() => _CaptainPanelScreenState();
}

class _CaptainPanelScreenState extends State<CaptainPanelScreen> {
  final GameService _gameService = GameService();
  final TeamService _teamService = TeamService();

  List<Map<String, dynamic>> _otherTeams = [];
  List<Map<String, dynamic>> _myTeamPlayers = [];
  List<Map<String, dynamic>> _myTeamGames = [];
  String? _myTeamId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _otherTeams = await _gameService.getAllTeams();
    _myTeamId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    _myTeamPlayers = await _teamService.getTeamMembers(_myTeamId!);
    _myTeamGames = await _gameService.getGamesForTeam(_myTeamId!);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Панель капитана'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Моя команда'),
              Tab(text: 'Другие команды'),
              Tab(text: 'Игры'),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _myTeamTab(),
                  _otherTeamsTab(),
                  _gamesTab(),
                ],
              ),
      ),
    );
  }

  Widget _myTeamTab() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Состав команды', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _myTeamPlayers.length,
            itemBuilder: (context, index) {
              final player = _myTeamPlayers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(child: Text(player['number']?.toString() ?? '?')),
                  title: Text(player['full_name']),
                  subtitle: Text('Позиция: ${player['position']}'),
                ),
              );
            },
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.push('/team/add-player').then((_) => _loadData()),
          icon: const Icon(Icons.person_add),
          label: const Text('Добавить игрока'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _otherTeamsTab() {
    return ListView.builder(
      itemCount: _otherTeams.length,
      itemBuilder: (context, index) {
        final team = _otherTeams[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(team['name']),
            subtitle: Text(team['description'] ?? ''),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showTeamPlayers(team['id']),
          ),
        );
      },
    );
  }

  void _showTeamPlayers(String teamId) async {
    final players = await _teamService.getTeamMembers(teamId);
    if (mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Состав команды'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: players.length,
              itemBuilder: (context, index) {
                final p = players[index];
                return ListTile(
                  title: Text(p['full_name']),
                  subtitle: Text('Позиция: ${p['position']}'),
                  trailing: Text('№${p['number'] ?? '?'}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Закрыть')),
          ],
        ),
      );
    }
  }

  Widget _gamesTab() {
    return ListView.builder(
      itemCount: _myTeamGames.length,
      itemBuilder: (context, index) {
        final game = _myTeamGames[index];
        final isPostponed = game['postponed'] != null && game['postponed'] != '';
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(game['title'] ?? 'Игра'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Дата: ${game['date']} ${game['start_time']}'),
                Text('Адрес: ${game['location']}'),
                if (game['score'] != null) Text('Счёт: ${game['score']}'),
                if (isPostponed) Text('Перенос: ${game['postponed']}', style: const TextStyle(color: Colors.red)),
                Text('Судья: ${game['referee']}'),
              ],
            ),
            trailing: const Icon(Icons.info_outline),
            onTap: () => _showGameDetails(game),
          ),
        );
      },
    );
  }

  void _showGameDetails(Map<String, dynamic> game) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(game['title'] ?? 'Игра'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Дата: ${game['date']} ${game['start_time']}'),
            Text('Место: ${game['location']}'),
            Text('Счёт: ${game['score'] ?? 'не указан'}'),
            if (game['postponed'] != null) Text('Перенос: ${game['postponed']}', style: const TextStyle(color: Colors.red)),
            Text('Судья: ${game['referee']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Закрыть')),
        ],
      ),
    );
  }
}