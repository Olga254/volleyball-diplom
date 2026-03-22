import 'package:flutter/material.dart';
import '../../services/game_service.dart';

class GameSearchScreen extends StatefulWidget {
  const GameSearchScreen({super.key});

  @override
  State<GameSearchScreen> createState() => _GameSearchScreenState();
}

class _GameSearchScreenState extends State<GameSearchScreen> {
  List<Map<String, dynamic>> _allGames = [];
  List<Map<String, dynamic>> _filteredGames = [];
  bool _isLoading = true;
  final GameService _gameService = GameService();

  // Фильтры
  bool _filterBeach = false;
  bool _filterHome = false;
  bool _filterBoys = false;
  bool _filterGirls = false;
  String? _filterAge; // 'U18', 'U21', 'Open'

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _allGames = [
        {
          'id': 1,
          'title': 'Вечерний волейбол',
          'date': '2025-04-10',
          'time': '18:00',
          'location': 'Спортзал "Центральный", Ленина 10',
          'players_needed': 4,
          'captain': 'Иван Петров',
          'surface': 'зал',
          'gender': 'смешанный',
          'age': 'Open',
          'joined': _gameService.isJoined(1),
        },
        {
          'id': 2,
          'title': 'Турнир выходного дня',
          'date': '2025-04-11',
          'time': '11:00',
          'location': 'Парк Победы, Пляжная зона',
          'players_needed': 6,
          'captain': 'Алексей Сидоров',
          'surface': 'пляж',
          'gender': 'мальчики',
          'age': 'U18',
          'joined': _gameService.isJoined(2),
        },
        {
          'id': 3,
          'title': 'Игра на пляже',
          'date': '2025-04-13',
          'time': '16:00',
          'location': 'Пляж "Ласковый", Солнечная 5',
          'players_needed': 2,
          'captain': 'Мария Иванова',
          'surface': 'пляж',
          'gender': 'девочки',
          'age': 'U21',
          'joined': _gameService.isJoined(3),
        },
        {
          'id': 4,
          'title': 'Домашний турнир',
          'date': '2025-04-15',
          'time': '14:00',
          'location': 'Спорткомплекс "Дружба", Мира 1',
          'players_needed': 8,
          'captain': 'Дмитрий Козлов',
          'surface': 'зал',
          'gender': 'смешанный',
          'age': 'Open',
          'joined': _gameService.isJoined(4),
        },
        {
          'id': 5,
          'title': 'Пляжный кубок',
          'date': '2025-04-17',
          'time': '10:00',
          'location': 'Пляж "Солнечный", Пляжная 2',
          'players_needed': 4,
          'captain': 'Елена Смирнова',
          'surface': 'пляж',
          'gender': 'девочки',
          'age': 'U18',
          'joined': _gameService.isJoined(5),
        },
      ];
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    _filteredGames = _allGames.where((game) {
      if (_filterBeach && game['surface'] != 'пляж') return false;
      if (_filterHome && game['surface'] != 'зал') return false;
      if (_filterBoys && game['gender'] != 'мальчики') return false;
      if (_filterGirls && game['gender'] != 'девочки') return false;
      if (_filterAge != null && game['age'] != _filterAge) return false;
      return true;
    }).toList();
    setState(() {});
  }

  void _toggleJoin(Map<String, dynamic> game) {
    setState(() {
      if (game['joined']) {
        _gameService.leaveGame(game['id']);
        game['joined'] = false;
      } else {
        _gameService.joinGame(game['id']);
        game['joined'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(game['joined'] ? 'Вы записаны на игру' : 'Вы отказались от участия')),
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
        title: const Text('Поиск игр'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Фильтры
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Пляж'),
                        selected: _filterBeach,
                        onSelected: (selected) {
                          setState(() {
                            _filterBeach = selected;
                            if (selected) _filterHome = false;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Зал'),
                        selected: _filterHome,
                        onSelected: (selected) {
                          setState(() {
                            _filterHome = selected;
                            if (selected) _filterBeach = false;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Мальчики'),
                        selected: _filterBoys,
                        onSelected: (selected) {
                          setState(() {
                            _filterBoys = selected;
                            if (selected) _filterGirls = false;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Девочки'),
                        selected: _filterGirls,
                        onSelected: (selected) {
                          setState(() {
                            _filterGirls = selected;
                            if (selected) _filterBoys = false;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        hint: const Text('Возраст'),
                        value: _filterAge,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Все')),
                          DropdownMenuItem(value: 'U18', child: Text('U18')),
                          DropdownMenuItem(value: 'U21', child: Text('U21')),
                          DropdownMenuItem(value: 'Open', child: Text('Open')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterAge = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredGames.length,
                    itemBuilder: (context, index) {
                      final game = _filteredGames[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(game['title']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Дата: ${game['date']} ${game['time']}'),
                              Text('Место: ${game['location']}'),
                              Text('Капитан: ${game['captain']}'),
                              Text('Нужно игроков: ${game['players_needed']}'),
                              Text('Покрытие: ${game['surface']}, Пол: ${game['gender']}, Возраст: ${game['age']}'),
                            ],
                          ),
                          trailing: game['joined']
                              ? OutlinedButton(
                                  onPressed: () => _toggleJoin(game),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Отказаться'),
                                )
                              : ElevatedButton(
                                  onPressed: () => _toggleJoin(game),
                                  child: const Text('Записаться'),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}