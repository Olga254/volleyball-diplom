import 'package:flutter/material.dart';
import '../../services/game_service.dart';

class TeamProfileScreen extends StatefulWidget {
  final String teamName;
  const TeamProfileScreen({super.key, required this.teamName});

  @override
  State<TeamProfileScreen> createState() => _TeamProfileScreenState();
}

class _TeamProfileScreenState extends State<TeamProfileScreen> {
  Map<String, dynamic>? _team;
  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    // В реальном приложении данные из Supabase
    _team = {
      'name': widget.teamName,
      'city': 'Москва',
      'address': 'ул. Спортивная, 10',
      'surface': 'зал',
      'gender': 'смешанный',
      'age_group': 'Open',
      'description': 'Команда ${widget.teamName}',
    };
    _players = [
      {'full_name': 'Игрок 1', 'position': 'Связующий', 'number': 1},
      {'full_name': 'Игрок 2', 'position': 'Защитник', 'number': 2},
    ];
    _games = GameService().getGamesForTeam(widget.teamName);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.teamName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Город: ${_team?['city'] ?? ''}'),
                        Text('Адрес: ${_team?['address'] ?? ''}'),
                        Text('Покрытие: ${_team?['surface'] ?? ''}'),
                        Text('Пол: ${_team?['gender'] ?? ''}'),
                        Text('Возраст: ${_team?['age_group'] ?? ''}'),
                        if (_team?['description'] != null) Text('Описание: ${_team!['description']}'),
                      ],
                    ),
                  ),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Состав'),
                      Tab(text: 'Игры'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPlayersList(),
                        _buildGamesList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlayersList() {
    return ListView.builder(
      itemCount: _players.length,
      itemBuilder: (context, index) {
        final p = _players[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(child: Text(p['number'].toString())),
            title: Text(p['full_name']),
            subtitle: Text(p['position']),
          ),
        );
      },
    );
  }

  Widget _buildGamesList() {
    return ListView.builder(
      itemCount: _games.length,
      itemBuilder: (context, index) {
        final g = _games[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text('${g['homeTeam']} - ${g['awayTeam']}'),
            subtitle: Text('${g['date']} ${g['time']}\nСчёт: ${g['score'] ?? 'не указан'}'),
          ),
        );
      },
    );
  }
}