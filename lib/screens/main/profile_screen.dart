import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userProfile;
    final role = user?['role'] ?? 'игрок';

    String displayName;
    if (user?['email'] == 'player@mock.com') {
      displayName = 'Иван Петров';
    } else if (user?['email'] == 'amateur@mock.com') {
      displayName = 'Алексей Смирнов';
    } else if (user?['email'] == 'fan@mock.com') {
      displayName = 'Мария Иванова';
    } else {
      displayName = user?['full_name'] ?? 'Пользователь';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: Icon(_showSettings ? Icons.close : Icons.settings),
            onPressed: () => setState(() => _showSettings = !_showSettings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).primaryColor.withAlpha(25),
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                  const SizedBox(height: 16),
                  Text(displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(user?['email'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Chip(label: Text(_capitalize(role)), backgroundColor: Theme.of(context).primaryColor, labelStyle: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            if (!_showSettings) ...[
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(children: [Icon(Icons.notifications_active), SizedBox(width: 16), Text('Уведомления', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Посмотреть все уведомления'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/notifications'),
              ),
            ],
            if (_showSettings) ...[
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(children: [Icon(Icons.settings), SizedBox(width: 16), Text('Настройки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Тема приложения'),
                trailing: Switch(
                  value: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
                  onChanged: (_) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                ),
                onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Изменить имя'),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditNameDialog(context, authProvider),
              ),
              if (role == 'игрок' || role == 'любитель')
                ListTile(
                  leading: const Icon(Icons.switch_account),
                  title: const Text('Сменить роль'),
                  subtitle: Text(role == 'игрок' ? 'Стать любителем' : 'Стать игроком'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _changeRole(authProvider, role),
                ),
              if (role == 'игрок')
                ListTile(
                  leading: const Icon(Icons.sports_volleyball),
                  title: const Text('Изменить позицию'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showEditPositionDialog(context, authProvider, user?['position'] ?? ''),
                ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Изменить телефон'),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditPhoneDialog(context, authProvider, user?['phone'] ?? ''),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Выйти', style: TextStyle(color: Colors.red)),
                onTap: _logout,
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, AuthProvider authProvider) {
    final controller = TextEditingController(text: authProvider.userProfile?['full_name'] ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Изменить имя'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Новое имя')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await authProvider.updateProfile({'full_name': controller.text});
                // Используем dialogContext вместо внешнего context
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Имя обновлено')));
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showEditPositionDialog(BuildContext context, AuthProvider authProvider, String currentPosition) {
    final positions = ['Защитник', 'Связующий', 'Либеро', 'Диагональный', 'Доигровщик'];
    String? selected = currentPosition.isNotEmpty ? currentPosition : null;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Изменить позицию'),
          content: DropdownButtonFormField<String>(
            initialValue: selected,
            items: positions.map((pos) => DropdownMenuItem(value: pos, child: Text(pos))).toList(),
            onChanged: (value) => setStateDialog(() => selected = value),
            decoration: const InputDecoration(labelText: 'Позиция'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                if (selected != null) {
                  await authProvider.updateProfile({'position': selected});
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Позиция обновлена')));
                  }
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPhoneDialog(BuildContext context, AuthProvider authProvider, String currentPhone) {
    final controller = TextEditingController(text: currentPhone);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Изменить телефон'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Новый телефон'), keyboardType: TextInputType.phone),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await authProvider.updateProfile({'phone': controller.text});
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Телефон обновлён')));
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeRole(AuthProvider authProvider, String currentRole) async {
    final newRole = currentRole == 'игрок' ? 'любитель' : 'игрок';
    await authProvider.updateRole(newRole);
    // Используем mounted (State.context) после проверки
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Роль изменена на ${_capitalize(newRole)}')));
      context.go('/home');
    }
  }

  Future<void> _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).signOut();
    if (mounted) context.go('/role');
  }

  String _capitalize(String text) => text.isNotEmpty ? '${text[0].toUpperCase()}${text.substring(1)}' : text;
}