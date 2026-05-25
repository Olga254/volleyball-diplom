import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/application_service.dart';

class AmateurApplicationScreen extends StatefulWidget {
  const AmateurApplicationScreen({super.key});

  @override
  State<AmateurApplicationScreen> createState() => _AmateurApplicationScreenState();
}

class _AmateurApplicationScreenState extends State<AmateurApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _positionController = TextEditingController();
  final _experienceController = TextEditingController();
  String? _gameType;
  bool _isLoading = false;

  final ApplicationService _appService = ApplicationService();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Анкета игрока (ищу команду)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _positionController, decoration: const InputDecoration(labelText: 'Ваша позиция'), validator: (v) => v!.isEmpty ? 'Введите позицию' : null),
              TextFormField(controller: _experienceController, decoration: const InputDecoration(labelText: 'Стаж игры (лет)'), validator: (v) => v!.isEmpty ? 'Введите стаж' : null),
              DropdownButtonFormField<String>(
                initialValue: _gameType,
                items: const [DropdownMenuItem(value: 'классика', child: Text('Классический волейбол')), DropdownMenuItem(value: 'пляж', child: Text('Пляжный волейбол'))],
                onChanged: (v) => setState(() => _gameType = v),
                decoration: const InputDecoration(labelText: 'Тип игры'),
                validator: (v) => v == null ? 'Выберите тип' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _submitApplication(auth.currentUser?.id),
                child: _isLoading ? const CircularProgressIndicator() : const Text('Отправить анкету'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitApplication(String? userId) async {
    if (userId == null) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await _appService.createApplication(
        userId: userId,
        position: _positionController.text,
        experience: _experienceController.text,
        gameType: _gameType!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Анкета отправлена')));
        Navigator.pop(context);
      }
      setState(() => _isLoading = false);
    }
  }
}