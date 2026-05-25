import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';

class RoleDetailsScreen extends StatefulWidget {
  const RoleDetailsScreen({super.key});

  @override
  State<RoleDetailsScreen> createState() => _RoleDetailsScreenState();
}

class _RoleDetailsScreenState extends State<RoleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPosition;
  final _teamNameController = TextEditingController();
  final _experienceController = TextEditingController();
  final List<String> _positions = ['Защитник', 'Связующий', 'Либеро', 'Диагональный', 'Доигровщик'];

  @override
  void dispose() {
    _teamNameController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.selectedRole ?? 'игрок';

    return Scaffold(
      appBar: AppBar(title: Text('Данные $role')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (role == 'игрок' || role == 'любитель')
                DropdownButtonFormField<String>(
                  initialValue: _selectedPosition,
                  decoration: const InputDecoration(labelText: 'Позиция'),
                  items: _positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setState(() => _selectedPosition = v),
                  validator: (v) => v == null ? 'Выберите позицию' : null,
                ),
              if (role == 'игрок')
                TextFormField(controller: _teamNameController, decoration: const InputDecoration(labelText: 'Название команды'), validator: (v) => v!.isEmpty ? 'Введите название' : null),
              if (role == 'игрок' || role == 'любитель')
                TextFormField(controller: _experienceController, decoration: const InputDecoration(labelText: 'Опыт (лет)'), validator: (v) => v!.isEmpty ? 'Введите опыт' : null),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Сохранить и продолжить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await ProfileService().updateProfileAfterRole(
        userId: authProvider.currentUser!.id,
        position: _selectedPosition,
        teamName: _teamNameController.text.isNotEmpty ? _teamNameController.text : null,
        experience: _experienceController.text.isNotEmpty ? _experienceController.text : null,
      );
      if (mounted) context.go('/home');
    }
  }
}