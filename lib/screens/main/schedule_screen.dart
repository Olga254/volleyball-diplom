import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/game_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  final GameService _gameService = GameService();

  // Данные о командах и их результатах (заглушка)
  final Map<String, List<Map<String, dynamic>>> _teamResults = {
    'Спартак': [
      {'date': '2024-09-01', 'opponent': 'Динамо', 'score': '3:1', 'winner': 'Спартак'},
      {'date': '2024-08-25', 'opponent': 'Зенит', 'score': '2:3', 'winner': 'Зенит'},
    ],
    'Динамо': [
      {'date': '2024-09-01', 'opponent': 'Спартак', 'score': '1:3', 'winner': 'Спартак'},
      {'date': '2024-08-20', 'opponent': 'Локомотив', 'score': '3:0', 'winner': 'Динамо'},
    ],
    'Зенит': [
      {'date': '2024-08-25', 'opponent': 'Спартак', 'score': '3:2', 'winner': 'Зенит'},
      {'date': '2024-08-18', 'opponent': 'Локомотив', 'score': '3:1', 'winner': 'Зенит'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final role = Provider.of<AuthProvider>(context, listen: false).userProfile?['role'] ?? 'игрок';
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      if (role == 'игрок') {
        _events = [
          {
            'title': 'Тренировка',
            'description': 'Общая физическая подготовка',
            'date': '2025-04-10',
            'time': '18:00-20:00',
            'location': 'Спортзал №1, Комаровская улица 34к1',
            'type': 'training',
            'ourTeam': 'Волейбольная команда',
            'opponent': null,
          },
          {
            'title': 'Матч с командой "Спартак"',
            'description': 'Товарищеская игра',
            'date': '2025-04-12',
            'time': '19:00-21:00',
            'location': 'Стадион "Локомотив", Ленина 15',
            'type': 'game',
            'ourTeam': 'Волейбольная команда',
            'opponent': 'Спартак',
          },
          {
            'title': 'Тренировка по тактике',
            'description': 'Отработка комбинаций',
            'date': '2025-04-15',
            'time': '17:00-19:00',
            'location': 'Спортзал №2, Мира 23',
            'type': 'training',
            'ourTeam': 'Волейбольная команда',
            'opponent': null,
          },
          {
            'title': 'Матч с командой "Динамо"',
            'description': 'Чемпионат города',
            'date': '2025-04-18',
            'time': '20:00-22:00',
            'location': 'Дворец спорта, Спортивная 1',
            'type': 'game',
            'ourTeam': 'Волейбольная команда',
            'opponent': 'Динамо',
          },
        ];
      } else if (role == 'любитель') {
        // Все доступные игры (для поиска) и записанные
        List<Map<String, dynamic>> allGames = [
          {
            'id': 1,
            'title': 'Вечерний волейбол',
            'date': '2025-04-10',
            'time': '18:00',
            'location': 'Спортзал "Центральный", Ленина 10',
            'players_needed': 4,
            'captain': 'Иван Петров',
            'type': 'game',
            'ourTeam': 'Сборная',
            'opponent': 'Любители',
          },
          {
            'id': 2,
            'title': 'Турнир выходного дня',
            'date': '2025-04-11',
            'time': '11:00',
            'location': 'Парк Победы, Пляжная зона',
            'players_needed': 6,
            'captain': 'Алексей Сидоров',
            'type': 'game',
            'ourTeam': 'Команда А',
            'opponent': 'Команда Б',
          },
          {
            'id': 3,
            'title': 'Игра на пляже',
            'date': '2025-04-13',
            'time': '16:00',
            'location': 'Пляж "Ласковый", Солнечная 5',
            'players_needed': 2,
            'captain': 'Мария Иванова',
            'type': 'game',
            'ourTeam': 'Пляжники',
            'opponent': 'Любители',
          },
        ];
        _events = allGames.where((game) => _gameService.isJoined(game['id'])).toList();
        // Добавим описания и формат, как у игрока
        _events = _events.map((e) {
          return {
            'title': e['title'],
            'description': 'Игра, на которую вы записались',
            'date': e['date'],
            'time': e['time'],
            'location': e['location'],
            'type': 'game',
            'ourTeam': e['ourTeam'],
            'opponent': e['opponent'],
          };
        }).toList();
      } else if (role == 'болельщик') {
        // Все возможные игры команд
        List<Map<String, dynamic>> allGames = [
          {'title': 'Матч "Спартак" - "Динамо"', 'date': '2025-04-13', 'time': '15:00-17:00', 'location': 'Дворец спорта, Спортивная 1', 'type': 'game', 'ourTeam': 'Спартак', 'opponent': 'Динамо'},
          {'title': 'Матч "Зенит" - "Локомотив"', 'date': '2025-04-14', 'time': '18:00-20:00', 'location': 'Стадион "Зенит", Футбольная 1', 'type': 'game', 'ourTeam': 'Зенит', 'opponent': 'Локомотив'},
          {'title': 'Матч "Динамо" - "Спартак"', 'date': '2025-04-16', 'time': '19:00-21:00', 'location': 'Дворец спорта', 'type': 'game', 'ourTeam': 'Динамо', 'opponent': 'Спартак'},
        ];
        // Показываем только игры команд, на которые подписан болельщик
        _events = allGames.where((game) => _gameService.isFollowing(game['ourTeam'])).toList();
      }
      _isLoading = false;
    });
  }

  void _showGameDetails(Map<String, dynamic> game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(game['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Дата: ${game['date']} ${game['time']}'),
            Text('Место: ${game['location']}'),
            const SizedBox(height: 16),
            const Text('Участники:', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              title: Text('Наша команда: ${game['ourTeam'] ?? 'Ваша команда'}'),
              onTap: () {
                // можно показать состав нашей команды
              },
            ),
            if (game['opponent'] != null)
              ListTile(
                title: Text('Команда соперника: ${game['opponent']}'),
                onTap: () => _showOpponentResults(game['opponent']),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
        ],
      ),
    );
  }

  void _showOpponentResults(String opponentTeam) {
    final results = _teamResults[opponentTeam] ?? [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Результаты команды "$opponentTeam"'),
        content: results.isEmpty
            ? const Text('Нет данных о результатах.')
            : SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: results.map((r) {
                    return ListTile(
                      title: Text('${r['date']} vs ${r['opponent']}'),
                      subtitle: Text('Счёт: ${r['score']}, Победитель: ${r['winner']}'),
                    );
                  }).toList(),
                ),
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
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
        title: const Text('Расписание'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSchedule,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final e = _events[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(e['type'] == 'game' ? Icons.sports_volleyball : Icons.fitness_center, color: Colors.blue),
                      title: Text(e['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e['description'] ?? ''),
                          Text('Дата: ${e['date']}'),
                          Text('Время: ${e['time']}'),
                          Text('Место: ${e['location']}'),
                        ],
                      ),
                      onTap: () => _showGameDetails(e),
                    ),
                  );
                },
              ),
            ),
    );
  }
}