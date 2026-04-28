import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/game_service.dart';

class CaptainPanelScreen extends StatefulWidget {
  const CaptainPanelScreen({super.key});

  @override
  State<CaptainPanelScreen> createState() => _CaptainPanelScreenState();
}

class _CaptainPanelScreenState extends State<CaptainPanelScreen> {
  final GameService _gameService = GameService();
  List<Map<String, dynamic>> _otherTeams = [];
  List<Map<String, dynamic>> _myTeamPlayers = [];
  final String _myTeamName = 'Любители';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _otherTeams = [
      {'name': 'Спартак', 'city': 'Москва'},
      {'name': 'Динамо', 'city': 'Санкт-Петербург'},
      {'name': 'Зенит', 'city': 'Казань'},
    ];
    _myTeamPlayers = [
      {'full_name': 'Сидоров Дмитрий', 'position': 'Капитан', 'number': 1},
      {'full_name': 'Николаев Сергей', 'position': 'Нападающий', 'number': 2},
    ];
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
        body: TabBarView(
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
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
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
                        leading: CircleAvatar(child: Text(player['number'].toString())),
                        title: Text(player['full_name'] as String),
                        subtitle: Text(player['position'] as String),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _addPlayerToTeam(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Добавить игрока'),
              ),
              const SizedBox(height: 20),
            ],
          );
  }

  Widget _otherTeamsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _otherTeams.length,
            itemBuilder: (context, index) {
              final team = _otherTeams[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(team['name'] as String),
                  subtitle: Text(team['city'] as String),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showTeamPlayers(team['name'] as String),
                ),
              );
            },
          );
  }

  void _showTeamPlayers(String teamName) {
    final players = [
      {'full_name': 'Игрок 1', 'position': 'Либеро', 'number': 5},
    ];
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Состав команды $teamName'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: players.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(players[index]['full_name'] as String),
              subtitle: Text(players[index]['position'] as String),
              trailing: Text('№${players[index]['number']}'),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Закрыть')),
        ],
      ),
    );
  }

  Widget _gamesTab() {
    final myTeamGames = _gameService.getGamesForTeam(_myTeamName);
    return ListView.builder(
      itemCount: myTeamGames.length,
      itemBuilder: (context, index) {
        final game = myTeamGames[index];
        final isPostponed = game['postponed'] != null && game['postponed'] != '';
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text('${game['homeTeam']} - ${game['awayTeam']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Дата: ${game['date']} ${game['time']}'),
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
        title: Text('${game['homeTeam']} vs ${game['awayTeam']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Дата: ${game['date']} ${game['time']}'),
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

  void _addPlayerToTeam(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final positionController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Добавить игрока'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'ФИО'), validator: (v) => v!.isEmpty ? 'Введите имя' : null),
              TextFormField(controller: numberController, decoration: const InputDecoration(labelText: 'Номер'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Введите номер' : null),
              TextFormField(controller: positionController, decoration: const InputDecoration(labelText: 'Позиция'), validator: (v) => v!.isEmpty ? 'Введите позицию' : null),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _myTeamPlayers.add({
                    'full_name': nameController.text,
                    'number': int.parse(numberController.text),
                    'position': positionController.text,
                  });
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Игрок добавлен')));
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}