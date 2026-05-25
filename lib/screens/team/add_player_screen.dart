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
  final _positionController = TextEditingController();
  final _numberController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final TeamService _teamService = TeamService();
  static const String _teamId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _numberController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить игрока')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _fullNameController, decoration: const InputDecoration(labelText: 'ФИО'), validator: (v) => v!.isEmpty ? 'Введите ФИО' : null),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Телефон'), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Введите телефон' : null),
              TextFormField(controller: _positionController, decoration: const InputDecoration(labelText: 'Позиция'), validator: (v) => v!.isEmpty ? 'Введите позицию' : null),
              TextFormField(controller: _numberController, decoration: const InputDecoration(labelText: 'Номер на поле'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Введите номер' : null),
              TextFormField(controller: _ageController, decoration: const InputDecoration(labelText: 'Возраст (лет)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Введите возраст' : null),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Введите email' : null),
              TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Пароль'), obscureText: true, validator: (v) => v!.isEmpty ? 'Введите пароль' : null),
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
          age: int.tryParse(_ageController.text) ?? 18,
          email: _emailController.text,
          password: _passwordController.text,
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