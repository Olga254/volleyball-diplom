import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/game_service.dart';
import '../../services/notification_service.dart';

class AmateurCreateGameScreen extends StatefulWidget {
  const AmateurCreateGameScreen({super.key});

  @override
  State<AmateurCreateGameScreen> createState() => _AmateurCreateGameScreenState();
}

class _AmateurCreateGameScreenState extends State<AmateurCreateGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _maxPlayersController = TextEditingController();
  final _costController = TextEditingController();
  final _refereeController = TextEditingController();
  final _organizerController = TextEditingController();
  String? _surfaceType;
  String? _targetGender;
  String? _targetAge;
  String? _level; // Любитель, Продвинутый, PRO
  bool _hasReferee = true;

  final GameService _gameService = GameService();
  final NotificationService _notificationService = NotificationService();

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _maxPlayersController.dispose();
    _costController.dispose();
    _refereeController.dispose();
    _organizerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    _organizerController.text = auth.userProfile?['full_name'] ?? 'Любитель';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать игру'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Название игры'), validator: (v) => v!.isEmpty ? 'Введите название' : null),
              TextFormField(controller: _organizerController, decoration: const InputDecoration(labelText: 'Организатор'), enabled: false),
              TextFormField(controller: _dateController, decoration: const InputDecoration(labelText: 'Дата (ГГГГ-ММ-ДД)'), validator: (v) => v!.isEmpty ? 'Введите дату' : null),
              TextFormField(controller: _timeController, decoration: const InputDecoration(labelText: 'Время (ЧЧ:ММ)'), validator: (v) => v!.isEmpty ? 'Введите время' : null),
              TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Место (название)'), validator: (v) => v!.isEmpty ? 'Введите место' : null),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Адрес'), validator: (v) => v!.isEmpty ? 'Введите адрес' : null),
              
              DropdownButtonFormField<String>(
                initialValue: _surfaceType,
                items: const [DropdownMenuItem(value: 'зал', child: Text('Зал')), DropdownMenuItem(value: 'пляж', child: Text('Пляж'))],
                onChanged: (v) => setState(() => _surfaceType = v),
                decoration: const InputDecoration(labelText: 'Покрытие'),
                validator: (v) => v == null ? 'Выберите покрытие' : null,
              ),
              
              TextFormField(controller: _maxPlayersController, decoration: const InputDecoration(labelText: 'Количество человек'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Введите количество' : null),
              
              TextFormField(controller: _costController, decoration: const InputDecoration(labelText: 'Стоимость (например, 500 руб. или Бесплатно)')),
              
              DropdownButtonFormField<String>(
                initialValue: _targetGender,
                items: const [DropdownMenuItem(value: 'женская', child: Text('Женская')), DropdownMenuItem(value: 'мужская', child: Text('Мужская')), DropdownMenuItem(value: 'смешанная', child: Text('Смешанная'))],
                onChanged: (v) => setState(() => _targetGender = v),
                decoration: const InputDecoration(labelText: 'Пол игроков'),
              ),
              
              DropdownButtonFormField<String>(
                initialValue: _targetAge,
                items: const [DropdownMenuItem(value: 'U18', child: Text('U18')), DropdownMenuItem(value: 'U21', child: Text('U21')), DropdownMenuItem(value: 'Open', child: Text('Open'))],
                onChanged: (v) => setState(() => _targetAge = v),
                decoration: const InputDecoration(labelText: 'Возрастная группа'),
              ),
              
              DropdownButtonFormField<String>(
                initialValue: _level,
                items: const [DropdownMenuItem(value: 'Любитель', child: Text('Любитель')), DropdownMenuItem(value: 'Продвинутый', child: Text('Продвинутый')), DropdownMenuItem(value: 'PRO', child: Text('PRO'))],
                onChanged: (v) => setState(() => _level = v),
                decoration: const InputDecoration(labelText: 'Уровень игроков'),
                validator: (v) => v == null ? 'Выберите уровень' : null,
              ),
              
              SwitchListTile(
                title: const Text('Есть судья'),
                value: _hasReferee,
                onChanged: (v) => setState(() => _hasReferee = v),
              ),
              
              if (_hasReferee)
                TextFormField(controller: _refereeController, decoration: const InputDecoration(labelText: 'Судья (ФИО)'), validator: (v) => v!.isEmpty ? 'Введите судью' : null),
              
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _createGame,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
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
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final newGame = {
        'id': 0,
        'title': _titleController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'location': _locationController.text,
        'address': _addressController.text,
        'surface': _surfaceType,
        'score': '',
        'postponed': null,
        'referee': _hasReferee ? _refereeController.text : null,
        'max_players': int.tryParse(_maxPlayersController.text),
        'cost': _costController.text,
        'target_gender': _targetGender,
        'target_age': _targetAge,
        'level': _level,
        'created_by_type': 'amateur',
        'created_by': auth.currentUser?.id,
        'created_by_name': _organizerController.text,
      };
      await _gameService.createGame(newGame);
      await _notificationService.notifyNewGame(newGame);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Игра создана, уведомления отправлены')));
        Navigator.pop(context);
      }
    }
  }
}