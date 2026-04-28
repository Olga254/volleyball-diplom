import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор роли'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/authorization'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Выберите вашу роль',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _buildRoleButton(
              context,
              'Игрок',
              'Вы состоите в команде',
              Icons.sports_volleyball,
              Colors.blue,
            ),
            const SizedBox(height: 20),
            _buildRoleButton(
              context,
              'Любитель',
              'Ищете игры для участия',
              Icons.person,
              Colors.green,
            ),
            const SizedBox(height: 20),
            _buildRoleButton(
              context,
              'Болельщик',
              'Следите за командами',
              Icons.people,
              Colors.orange,
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Тестовый вход (без регистрации)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildTestUserButton(
              context,
              'Игрок',
              Icons.sports_volleyball,
              Colors.blue.shade100,
              'игрок',
              'Тестовый игрок',
              'player@example.com',
              'Нападающий',
              'Игрок с 2015 года, амплуа — нападающий',
            ),
            const SizedBox(height: 10),
            _buildTestUserButton(
              context,
              'Любитель',
              Icons.person,
              Colors.green.shade100,
              'любитель',
              'Тестовый любитель',
              'amateur@example.com',
              'Связующий',
              'Играю в волейбол 3 года, ищу команду',
            ),
            const SizedBox(height: 10),
            _buildTestUserButton(
              context,
              'Болельщик',
              Icons.people,
              Colors.orange.shade100,
              'болельщик',
              'Тестовый болельщик',
              'fan@example.com',
              'Активный болельщик',
              'Болею за сборную с 2010 года',
            ),
            const SizedBox(height: 10),
            _buildTestUserButton(
              context,
              'Администратор',
              Icons.admin_panel_settings,
              Colors.purple.shade100,
              'admin',
              'Администратор',
              'admin@example.com',
              'Системный администратор',
              'Управление приложением',
            ),
            const SizedBox(height: 10),
            _buildTestUserButton(
              context,
              'Капитан',
              Icons.groups,
              Colors.teal.shade100,
              'captain',
              'Капитан команды',
              'captain@example.com',
              'Капитан',
              'Капитан команды "Любители", опыт 8 лет',
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => context.go('/authorization'),
              child: const Text('Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () {
        Provider.of<AuthProvider>(context, listen: false).setRole(title.toLowerCase());
        context.go('/registration');
      },
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildTestUserButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String role,
    String fullName,
    String email,
    String position,
    String experience,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.signInAsMock(role, fullName, email, position, experience);
        context.go('/home');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}