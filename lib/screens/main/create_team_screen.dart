import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/auth_provider.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  String? _surfaceType;
  String? _gender;
  String? _ageGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать команду')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Название команды'), validator: (v) => v!.isEmpty ? 'Введите название' : null),
              TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'Город')),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Адрес')),
              DropdownButtonFormField<String>(
                initialValue: _surfaceType,
                decoration: const InputDecoration(labelText: 'Покрытие'),
                items: ['зал', 'пляж'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _surfaceType = v),
              ),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Пол'),
                items: ['мальчики', 'девочки', 'смешанный'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _gender = v),
              ),
              DropdownButtonFormField<String>(
                initialValue: _ageGroup,
                decoration: const InputDecoration(labelText: 'Возрастная группа'),
                items: ['U18', 'U21', 'Open'].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                onChanged: (v) => setState(() => _ageGroup = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createTeam,
                child: const Text('Создать'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createTeam() async {
    if (_formKey.currentState!.validate()) {
      final teamData = {
        'name': _nameController.text,
        'city': _cityController.text,
        'address': _addressController.text,
        'surface_type': _surfaceType,
        'gender': _gender,
        'age_group': _ageGroup,
        'created_by': Provider.of<AuthProvider>(context, listen: false).currentUser?.id,
      };
      await Provider.of<TeamProvider>(context, listen: false).createTeam(teamData);
      if (mounted) Navigator.pop(context);
    }
  }
}