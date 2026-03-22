import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<Map<String, dynamic>> _teamMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _teamMembers = [
        {'full_name': 'Иванов Иван', 'birth_date': '1995-05-15', 'number': 1, 'position': 'Связующий'},
        {'full_name': 'Петров Петр', 'birth_date': '1992-03-20', 'number': 2, 'position': 'Защитник'},
        {'full_name': 'Сидоров Сидор', 'birth_date': '1990-01-10', 'number': 3, 'position': 'Либеро'},
        {'full_name': 'Кузнецов Алексей', 'birth_date': '1998-07-22', 'number': 4, 'position': 'Диагональный'},
        {'full_name': 'Морозов Дмитрий', 'birth_date': '1994-12-01', 'number': 5, 'position': 'Доигровщик'},
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userProfile;
    final isCaptain = user?['role'] == 'капитан';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Команда'),
        actions: [
          if (isCaptain)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/team/edit'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _teamMembers.length,
              itemBuilder: (context, index) {
                final player = _teamMembers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(player['number'].toString(), style: const TextStyle(color: Colors.blue)),
                    ),
                    title: Text(player['full_name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Позиция: ${player['position']}'),
                        Text('Дата рождения: ${player['birth_date']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}