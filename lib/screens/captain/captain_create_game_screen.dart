import 'package:flutter/material.dart';
import '../../services/game_service.dart';
import '../../services/notification_service.dart';

class CaptainCreateGameScreen extends StatefulWidget {
  const CaptainCreateGameScreen({super.key});

  @override
  State<CaptainCreateGameScreen> createState() => _CaptainCreateGameScreenState();
}

class _CaptainCreateGameScreenState extends State<CaptainCreateGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homeTeamController = TextEditingController(text: 'Любители');
  final _awayTeamController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _refereeController = TextEditingController();

  final GameService _gameService = GameService();
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать игру (капитан-любитель)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _homeTeamController, decoration: const InputDecoration(labelText: 'Хозяева'), enabled: false),
              TextFormField(controller: _awayTeamController, decoration: const InputDecoration(labelText: 'Гости'), validator: (v) => v!.isEmpty ? 'Введите команду гостей' : null),
              TextFormField(controller: _dateController, decoration: const InputDecoration(labelText: 'Дата (ГГГГ-ММ-ДД)'), validator: (v) => v!.isEmpty ? 'Введите дату' : null),
              TextFormField(controller: _timeController, decoration: const InputDecoration(labelText: 'Время (ЧЧ:ММ)'), validator: (v) => v!.isEmpty ? 'Введите время' : null),
              TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Место проведения'), validator: (v) => v!.isEmpty ? 'Введите адрес' : null),
              TextFormField(controller: _refereeController, decoration: const InputDecoration(labelText: 'Судья (ФИО)'), validator: (v) => v!.isEmpty ? 'Введите судью' : null),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createGame,
                child: const Text('Создать игру'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createGame() async {
    if (_formKey.currentState!.validate()) {
      final newGame = {
        'title': '${_homeTeamController.text} - ${_awayTeamController.text}',
        'home_team_id': null,
        'away_team_id': null,
        'date': _dateController.text,
        'start_time': _timeController.text,
        'location': _locationController.text,
        'referee': _refereeController.text,
        'created_by_type': 'captain',
      };
      await _gameService.createGame(newGame);
      await _notificationService.sendNotificationToAll(
        title: 'Новая игра',
        message: 'Создана игра: ${newGame['title']} на ${newGame['date']}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Игра создана, уведомления отправлены')));
        Navigator.pop(context);
      }
    }
  }
}