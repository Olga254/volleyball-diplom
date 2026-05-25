import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/game_service.dart';
import '../amateur/amateur_create_game_screen.dart';
import '../amateur/amateur_application_screen.dart';

class GameSearchScreen extends StatefulWidget {
  const GameSearchScreen({super.key});

  @override
  State<GameSearchScreen> createState() => _GameSearchScreenState();
}

class _GameSearchScreenState extends State<GameSearchScreen> {
  List<Map<String, dynamic>> _games = [];
  bool _isLoading = true;
  final GameService _gameService = GameService();

  // Фильтры
  String? _filterSurface; // 'зал', 'пляж'
  String? _filterGender;  // 'женская', 'мужская', 'смешанная'
  String? _filterAge;     // 'U18', 'U21', 'Open'
  String? _filterLevel;   // 'Любитель', 'Продвинутый', 'PRO'

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    final allGames = _gameService.getAllGamesForAdmin();
    _games = allGames.where((g) => 
      g['created_by_type'] == 'amateur' || g['type'] == 'friendly'
    ).toList();
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredGames {
    return _games.where((game) {
      if (_filterSurface != null && game['surface'] != _filterSurface) return false;
      if (_filterGender != null && game['target_gender'] != _filterGender) return false;
      if (_filterAge != null && game['target_age'] != _filterAge) return false;
      if (_filterLevel != null && game['level'] != _filterLevel) return false;
      return true;
    }).toList();
  }

  Future<void> _showParticipantsList(Map<String, dynamic> game) async {
    final participants = await _gameService.getGameParticipants(game['id']);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Участники игры "${game['title']}"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (participants.isEmpty)
              const Text('Пока никто не записался')
            else
              ...participants.map((p) => ListTile(title: Text(p['full_name']), leading: const Icon(Icons.person))),
          ],
        ),
      ),
    );
  }

  void _toggleJoin(Map<String, dynamic> game) {
    final isJoined = game['joined'] ?? false;
    setState(() {
      if (isJoined) {
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
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.userProfile?['role'];
    final canCreateGame = role == 'любитель' || role == 'admin' || role == 'captain';
    final canCreateApplication = role == 'любитель';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск игр'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (canCreateGame)
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AmateurCreateGameScreen())),
              tooltip: 'Создать игру',
            ),
          if (canCreateApplication)
            IconButton(
              icon: const Icon(Icons.assignment),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AmateurApplicationScreen())),
              tooltip: 'Моя анкета',
            ),
        ],
      ),
      body: Column(
        children: [
          // Удалена строка поиска
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                FilterChip(label: const Text('Зал'), selected: _filterSurface == 'зал', onSelected: (s) => setState(() => _filterSurface = s ? 'зал' : null)),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Пляж'), selected: _filterSurface == 'пляж', onSelected: (s) => setState(() => _filterSurface = s ? 'пляж' : null)),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Женская'), selected: _filterGender == 'женская', onSelected: (s) => setState(() => _filterGender = s ? 'женская' : null)),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Мужская'), selected: _filterGender == 'мужская', onSelected: (s) => setState(() => _filterGender = s ? 'мужская' : null)),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Смешанная'), selected: _filterGender == 'смешанная', onSelected: (s) => setState(() => _filterGender = s ? 'смешанная' : null)),
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
                  onChanged: (v) => setState(() => _filterAge = v),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  hint: const Text('Уровень'),
                  value: _filterLevel,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Все')),
                    DropdownMenuItem(value: 'Любитель', child: Text('Любитель')),
                    DropdownMenuItem(value: 'Продвинутый', child: Text('Продвинутый')),
                    DropdownMenuItem(value: 'PRO', child: Text('PRO')),
                  ],
                  onChanged: (v) => setState(() => _filterLevel = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGames.isEmpty
                    ? const Center(child: Text('Нет доступных игр'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _filteredGames.length,
                        itemBuilder: (context, index) {
                          final game = _filteredGames[index];
                          final isPostponed = game['postponed'] != null && game['postponed'] != '';
                          final isJoined = game['joined'] ?? false;
                          final hasReferee = game['referee'] != null && game['referee']!.isNotEmpty;
                          final cost = game['cost'] ?? 'Бесплатно';
                          final level = game['level'] ?? 'Не указан';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(game['title'] ?? 'Любительская игра'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Дата: ${game['date']} ${game['time']}'),
                                      Text('Место: ${game['location']}', style: TextStyle(color: isPostponed ? Colors.red : null)),
                                      if (game['address'] != null) Text('Адрес: ${game['address']}'),
                                      Text('Стоимость: $cost'),
                                      if (game['target_gender'] != null) Text('Пол: ${game['target_gender']}'),
                                      if (game['target_age'] != null) Text('Возраст: ${game['target_age']}'),
                                      Text('Уровень: $level'),
                                      Text('Судья: ${hasReferee ? game['referee'] : 'нет'}'),
                                      Text('Организатор: ${game['created_by_name'] ?? 'Неизвестен'}'),
                                    ],
                                  ),
                                  trailing: isJoined
                                      ? OutlinedButton(onPressed: () => _toggleJoin(game), style: OutlinedButton.styleFrom(foregroundColor: Colors.red), child: const Text('Отказаться'))
                                      : ElevatedButton(onPressed: () => _toggleJoin(game), child: const Text('Записаться')),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _showParticipantsList(game),
                                        icon: const Icon(Icons.people),
                                        label: const Text('Кто идёт?'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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