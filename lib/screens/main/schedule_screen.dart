import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/game_service.dart';
import '../team/team_profile_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> _myGames = [];
  List<Map<String, dynamic>> _teamGames = [];
  bool _isLoading = true;
  final GameService _gameService = GameService();
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentUserRole = authProvider.userProfile?['role'] ?? 'игрок';

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      final allGames = _gameService.getAllGames();
      final role = _currentUserRole;

      if (role == 'игрок') {
        _teamGames = allGames;
        _myGames = [];
      } else if (role == 'любитель') {
        _myGames = allGames.where((g) => _gameService.isJoined(g['id'])).toList();
        _teamGames = [];
      } else if (role == 'болельщик') {
        _myGames = allGames.where((g) => _gameService.isJoined(g['id'])).toList();
        _teamGames = allGames.where((g) => _gameService.isFollowing(g['homeTeam']) || _gameService.isFollowing(g['awayTeam'])).toList();
      } else {
        _teamGames = allGames;
        _myGames = [];
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPlayer = _currentUserRole == 'игрок';
    final displayGames = isPlayer ? _teamGames : (_myGames.isNotEmpty ? _myGames : _teamGames);
    final title = isPlayer ? 'Расписание команды' : 'Расписание';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSchedule,
              child: displayGames.isEmpty
                  ? const Center(child: Text('Нет игр для отображения'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayGames.length,
                      itemBuilder: (context, index) => _buildGameCard(displayGames[index]),
                    ),
            ),
    );
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    final isPostponed = game['postponed'] != null && game['postponed'] != '';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        title: Text('${game['homeTeam'] ?? '?'} - ${game['awayTeam'] ?? '?'}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📅 ${game['date']} ${game['time']}'),
            Text('📍 ${game['location']}', style: TextStyle(color: isPostponed ? Colors.red : null)),
            if (game['address'] != null) Text('🏠 ${game['address']}'),
            Text('👨‍⚖️ Судья: ${game['referee'] ?? 'не назначен'}'),
            if (isPostponed) Text('⚠️ Перенос: ${game['postponed']}', style: const TextStyle(color: Colors.red)),
          ],
        ),
        trailing: game['score'] != null ? Chip(label: Text(game['score']), backgroundColor: Colors.green[100]) : null,
        onTap: () => _showGameDetails(game),
      ),
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
            if (game['address'] != null) Text('Адрес: ${game['address']}'),
            Text('Счёт: ${game['score'] ?? 'не указан'}'),
            if (game['postponed'] != null) Text('Перенос: ${game['postponed']}', style: const TextStyle(color: Colors.red)),
            Text('Судья: ${game['referee'] ?? 'не назначен'}'),
            const SizedBox(height: 8),
            if (game['homeTeam'] != null)
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TeamProfileScreen(teamName: game['homeTeam']))),
                child: const Text('Профиль команды хозяев'),
              ),
            if (game['awayTeam'] != null)
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TeamProfileScreen(teamName: game['awayTeam']))),
                child: const Text('Профиль команды гостей'),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Закрыть')),
        ],
      ),
    );
  }
}