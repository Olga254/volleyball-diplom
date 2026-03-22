import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _jerseyNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  File? _playerPhoto;
  String? _selectedPosition;
  bool _isLoading = false;

  final List<String> _positions = ['Защитник', 'Связующий', 'Либеро', 'Диагональный', 'Доигровщик'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/team/edit'),
        ),
        title: const Text('Добавить игрока'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (picked != null) setState(() => _playerPhoto = File(picked.path));
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _playerPhoto != null ? FileImage(_playerPhoto!) : const NetworkImage('https://via.placeholder.com/100') as ImageProvider,
                    child: _playerPhoto == null ? const Icon(Icons.person_add, size: 40, color: Colors.grey) : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(child: Text('Добавить фото', style: TextStyle(color: Colors.blue))),
              const SizedBox(height: 30),
              TextFormField(controller: _fullNameController, decoration: const InputDecoration(labelText: 'Полное имя', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)), validator: (v) => v!.isEmpty ? 'Введите имя' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _jerseyNumberController, decoration: const InputDecoration(labelText: 'Номер на майке', border: OutlineInputBorder(), prefixIcon: Icon(Icons.confirmation_number)), keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Введите номер';
                  final n = int.tryParse(v);
                  if (n == null || n < 1 || n > 99) return 'Число от 1 до 99';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedPosition,
                decoration: const InputDecoration(labelText: 'Позиция', border: OutlineInputBorder(), prefixIcon: Icon(Icons.sports_volleyball)),
                items: _positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _selectedPosition = v),
                validator: (v) => v == null ? 'Выберите позицию' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Телефон', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _addPlayer,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.green),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Добавить игрока', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: () => context.pop(), child: const Text('Отмена')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPlayer() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Игрок добавлен'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
      setState(() => _isLoading = false);
    }
  }
}