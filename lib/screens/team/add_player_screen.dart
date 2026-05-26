import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/team_service.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _positionController = TextEditingController();
  final _numberController = TextEditingController();
  final _experienceController = TextEditingController();
  final _birthDateController = TextEditingController();
  bool _isLoading = false;

  final TeamService _teamService = TeamService();
  static const String _teamId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  final List<String> _positions = ['Связующий', 'Защитник', 'Либеро', 'Диагональный', 'Доигровщик'];

  Future<void> _selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _birthDateController.text = picked.toIso8601String().split('T')[0];
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _positionController.dispose();
    _numberController.dispose();
    _experienceController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить игрока'), leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _fullNameController, decoration: const InputDecoration(labelText: 'ФИО'), validator: (v) => v!.isEmpty ? 'Введите ФИО' : null),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Телефон'), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Введите телефон' : null),
              DropdownButtonFormField<String>(
                initialValue: null,
                items: _positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => _positionController.text = v ?? '',
                decoration: const InputDecoration(labelText: 'Позиция'),
                validator: (v) => v == null ? 'Выберите позицию' : null,
              ),
              TextFormField(controller: _numberController, decoration: const InputDecoration(labelText: 'Номер'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Введите номер' : null),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Введите email' : null),
              TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Пароль'), obscureText: true, validator: (v) => v!.isEmpty ? 'Введите пароль' : null),
              TextFormField(controller: _experienceController, decoration: const InputDecoration(labelText: 'Опыт (лет)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Введите опыт' : null),
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(labelText: 'Дата рождения', suffixIcon: Icon(Icons.calendar_today)),
                readOnly: true,
                onTap: () => _selectBirthDate(context),
                validator: (v) => v!.isEmpty ? 'Выберите дату рождения' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _addPlayer,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPlayer() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        await _teamService.addPlayerToTeam(
          teamId: _teamId,
          fullName: _fullNameController.text,
          phone: _phoneController.text,
          position: _positionController.text,
          number: int.tryParse(_numberController.text) ?? 0,
          email: _emailController.text,
          password: _passwordController.text,
          experience: _experienceController.text,
          birthDate: _birthDateController.text,
          createdBy: auth.currentUser!.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Игрок добавлен')));
          Navigator.pop(context, true);
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