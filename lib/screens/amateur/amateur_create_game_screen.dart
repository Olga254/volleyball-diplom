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
  String? _surfaceType;
  String? _targetGender;
  String? _targetAge;
  String? _level;
  bool _isLoading = false;

  final GameService _gameService = GameService();
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать игру'), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Название игры'), validator: (v) => v!.isEmpty ? 'Введите название' : null),
              TextFormField(controller: _dateController, decoration: const InputDecoration(labelText: 'Дата (ГГГГ-ММ-ДД)', suffixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: _selectDate, validator: (v) => v!.isEmpty ? 'Выберите дату' : null),
              TextFormField(controller: _timeController, decoration: const InputDecoration(labelText: 'Время', suffixIcon: Icon(Icons.access_time)), readOnly: true, onTap: _selectTime, validator: (v) => v!.isEmpty ? 'Выберите время' : null),
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
              ),
              TextFormField(controller: _refereeController, decoration: const InputDecoration(labelText: 'Судья (ФИО) (если есть)')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _createGame,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: _isLoading ? const CircularProgressIndicator() : const Text('Создать игру'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      _dateController.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      _timeController.text = picked.format(context);
    }
  }

  Future<void> _createGame() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final newGame = {
          'title': _titleController.text,
          'date': _dateController.text,
          'start_time': _timeController.text,
          'location': _locationController.text,
          'address': _addressController.text,
          'surface': _surfaceType,
          'max_players': int.tryParse(_maxPlayersController.text),
          'cost': _costController.text,
          'target_gender': _targetGender,
          'target_age': _targetAge,
          'level': _level,
          'referee': _refereeController.text,
          'created_by_type': 'amateur',
          'created_by': auth.currentUser?.id,
        };
        final gameId = await _gameService.createGame(newGame);
        await _gameService.joinGame(gameId);
        await _notificationService.notifyNewGame(newGame);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Игра создана! Вы записаны на неё.')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}