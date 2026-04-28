import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final SupabaseService _supabase = SupabaseService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.client.from('profiles').select();
      _users = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Ошибка загрузки пользователей: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Все пользователи'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(user['full_name']?.substring(0, 1) ?? '?')),
                    title: Text(user['full_name'] ?? 'Без имени'),
                    subtitle: Text('${user['email']} | Роль: ${user['role']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editUserRole(context, user),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _editUserRole(BuildContext context, Map<String, dynamic> user) {
    final roles = ['игрок', 'любитель', 'болельщик', 'captain'];
    String? selectedRole = user['role'];
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Изменить роль пользователя'),
        content: DropdownButtonFormField<String>(
          initialValue: selectedRole,
          items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (value) => selectedRole = value,
          decoration: const InputDecoration(labelText: 'Новая роль'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              if (selectedRole != null) {
                await _supabase.client.from('profiles').update({'role': selectedRole}).eq('id', user['id']);
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Роль обновлена')));
                  Navigator.pop(dialogContext);
                  _loadUsers();
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}