import 'package:flutter/material.dart';
import '../../services/game_service.dart';
import '../../services/notification_service.dart';

class AdminGamesScreen extends StatefulWidget {
  const AdminGamesScreen({super.key});

  @override
  State<AdminGamesScreen> createState() => _AdminGamesScreenState();
}

class _AdminGamesScreenState extends State<AdminGamesScreen> {
  final GameService _gameService = GameService();
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _games = _gameService.getAllGamesForAdmin();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление играми'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _games.length,
              itemBuilder: (context, index) {
                final game = _games[index];
                final isPostponed = game['postponed'] != null && game['postponed'] != '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.sports_volleyball, color: Colors.blue),
                        title: Text('${game['homeTeam']} vs ${game['awayTeam']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Дата: ${game['date']} ${game['time']}'),
                            Text('Место: ${game['location']}', style: TextStyle(color: isPostponed ? Colors.red : null)),
                            if (game['score'] != null && game['score']!.isNotEmpty)
                              Text('Счёт: ${game['score']}'),
                            if (isPostponed)
                              Text('Перенос: ${game['postponed']}', style: const TextStyle(color: Colors.red)),
                            Text('Судья: ${game['referee']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editGame(context, game),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _editGame(BuildContext context, Map<String, dynamic> game) {
    final formKey = GlobalKey<FormState>();
    final dateController = TextEditingController(text: game['date']);
    final timeController = TextEditingController(text: game['time']);
    final locationController = TextEditingController(text: game['location']);
    final homeScoreController = TextEditingController(text: (game['score']?.split(':')[0] ?? ''));
    final awayScoreController = TextEditingController(text: (game['score']?.split(':')[1] ?? ''));
    final refereeController = TextEditingController(text: game['referee'] ?? '');
    String? postponedType = game['postponed'] != null ? (game['postponed'] == 'неопределённый срок' ? 'undefined' : 'date') : null;
    DateTime? postponedDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Редактировать игру'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: dateController, decoration: const InputDecoration(labelText: 'Дата (ГГГГ-ММ-ДД)'), validator: (v) => v!.isEmpty ? 'Введите дату' : null),
                  TextFormField(controller: timeController, decoration: const InputDecoration(labelText: 'Время (ЧЧ:ММ)'), validator: (v) => v!.isEmpty ? 'Введите время' : null),
                  TextFormField(controller: locationController, decoration: const InputDecoration(labelText: 'Адрес'), validator: (v) => v!.isEmpty ? 'Введите адрес' : null),
                  Row(children: [
                    Expanded(child: TextFormField(controller: homeScoreController, decoration: const InputDecoration(labelText: 'Счёт хозяев'))),
                    const SizedBox(width: 8),
                    const Text(':'),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: awayScoreController, decoration: const InputDecoration(labelText: 'Счёт гостей'))),
                  ]),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: postponedType,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Нет переноса')),
                      DropdownMenuItem(value: 'date', child: Text('Перенос на дату')),
                      DropdownMenuItem(value: 'undefined', child: Text('Перенос на неопределённый срок')),
                    ],
                    onChanged: (value) => setStateDialog(() {
                      postponedType = value;
                      if (value != 'date') postponedDate = null;
                    }),
                    decoration: const InputDecoration(labelText: 'Перенос игры'),
                  ),
                  if (postponedType == 'date')
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                        if (picked != null) {
                          setStateDialog(() {
                            postponedDate = picked;
                          });
                        }
                      },
                      child: Text(postponedDate == null ? 'Выбрать дату переноса' : 'Перенос: ${postponedDate!.toIso8601String().split('T')[0]}'),
                    ),
                  TextFormField(controller: refereeController, decoration: const InputDecoration(labelText: 'Судья (ФИО)')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final score = '${homeScoreController.text}:${awayScoreController.text}';
                  String? postponedText;
                  if (postponedType == 'date' && postponedDate != null) {
                    postponedText = postponedDate!.toIso8601String().split('T')[0];
                  } else if (postponedType == 'undefined') {
                    postponedText = 'неопределённый срок';
                  }
                  final updatedGame = Map<String, dynamic>.from(game);
                  updatedGame['date'] = dateController.text;
                  updatedGame['time'] = timeController.text;
                  updatedGame['location'] = locationController.text;
                  updatedGame['score'] = score;
                  updatedGame['postponed'] = postponedText;
                  updatedGame['referee'] = refereeController.text;
                  await _gameService.updateGame(updatedGame);
                  await _notificationService.notifyGameChanged(updatedGame, 'изменена');
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    _loadGames();
                    ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Игра обновлена, уведомления отправлены')));
                  }
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}