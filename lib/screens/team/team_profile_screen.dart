import 'package:flutter/material.dart';
import '../../services/game_service.dart';
import '../../services/team_service.dart';

class TeamProfileScreen extends StatefulWidget {
  final String teamId;
  const TeamProfileScreen({super.key, required this.teamId});

  @override
  State<TeamProfileScreen> createState() => _TeamProfileScreenState();
}

class _TeamProfileScreenState extends State<TeamProfileScreen> {
  Map<String, dynamic>? _team;
  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> _games = [];
  bool _isLoading = true;
  final GameService _gameService = GameService();
  final TeamService _teamService = TeamService();

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    setState(() => _isLoading = true);
    final teams = await _gameService.getAllTeams();
    _team = teams.firstWhere((t) => t['id'] == widget.teamId, orElse: () => {});
    _players = await _teamService.getTeamMembers(widget.teamId);
    _games = await _gameService.getGamesForTeam(widget.teamId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_team?['name'] ?? 'Команда'),
        leading: const BackButton(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Информация', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Город: ${_team?['city'] ?? '—'}'),
                          Text('Адрес зала: ${_team?['address'] ?? '—'}'),
                          Text('Тренер: ${_extractCoach(_team?['description'])}'),
                          Text('Капитан: ${_getCaptainName() ?? '—'}'),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Состав команды', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _players.length,
                    itemBuilder: (context, index) {
                      final p = _players[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(child: Text(p['number']?.toString() ?? '?')),
                          title: Text(p['full_name'] ?? 'Без имени'),
                          subtitle: Text('Позиция: ${p['position'] ?? '—'}'),
                        ),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Игры', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _games.length,
                    itemBuilder: (context, index) {
                      final g = _games[index];
                      final isPostponed = g['postponed'] != null && g['postponed'] != '';
                      final isPast = DateTime.parse(g['date'] ?? '2000-01-01').isBefore(DateTime.now());
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(g['title'] ?? '${g['homeTeam']} - ${g['awayTeam']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Дата: ${g['date'] ?? ''} ${g['start_time'] ?? ''}'),
                              Text('Место: ${g['location'] ?? ''}'),
                              if (g['score'] != null) Text('Счёт: ${g['score']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (isPostponed) Text('Перенос: ${g['postponed']}', style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                          trailing: isPast && g['score'] != null
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : (isPostponed ? const Icon(Icons.warning, color: Colors.orange) : const Icon(Icons.schedule, color: Colors.blue)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  String _extractCoach(String? description) {
    if (description == null) return '—';
    if (description.contains('Тренер:')) {
      return description.split('Тренер:')[1].split(',')[0].trim();
    }
    return '—';
  }

  String? _getCaptainName() {
    final captain = _players.firstWhere((p) => p['role_in_team'] == 'капитан', orElse: () => {});
    return captain['full_name'];
  }
}