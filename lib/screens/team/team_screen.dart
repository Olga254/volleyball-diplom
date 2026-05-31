import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/team_service.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<Map<String, dynamic>> _teamMembers = [];
  bool _isLoading = true;
  final TeamService _teamService = TeamService();
  static const String _teamId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    setState(() => _isLoading = true);
    final members = await _teamService.getTeamMembers(_teamId);
    if (mounted) {
      setState(() {
        _teamMembers = members;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.userProfile?['role'] ?? 'игрок';
    final fanWantsGames = auth.fanWantsGames;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Команда'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/team/add-player').then((_) => _loadTeamMembers()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _teamMembers.isEmpty
              ? const Center(child: Text('В команде пока нет игроков. Добавьте первого!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _teamMembers.length,
                  itemBuilder: (context, index) {
                    final p = _teamMembers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(p['number']?.toString() ?? '?', style: const TextStyle(color: Colors.blue)),
                        ),
                        title: Text(p['full_name'] ?? 'Без имени'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Позиция: ${p['position'] ?? '—'}'),
                            Text('Телефон: ${p['phone'] ?? '—'}'),
                            Text('Email: ${p['email'] ?? '—'}'),
                            Text('Дата рождения: ${p['birth_date'] ?? '—'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editPlayer(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removePlayer(p['user_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: _buildBottomNavigationBar(role, fanWantsGames),
    );
  }

  Widget _buildBottomNavigationBar(String role, bool fanWantsGames) {
    List<BottomNavigationBarItem> items;
    if (role == 'игрок') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Новости'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Команда'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Расписание'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      ];
    } else if (role == 'любитель') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Новости'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск игр'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Расписание'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      ];
    } else if (role == 'болельщик') {
      if (fanWantsGames) {
        items = const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Новости'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск игр'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Расписание'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Команды'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ];
      } else {
        items = const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Новости'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Расписание'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Команды'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ];
      }
    } else if (role == 'admin') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Новости'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Расписание'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      ];
    } else if (role == 'captain') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Новости'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Расписание'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Команда'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      ];
    } else {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Новости'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      ];
    }

    final currentLocation = GoRouterState.of(context).uri.path;
    int currentIndex = 0;
    if (role == 'игрок') {
      if (currentLocation == '/home') {
        currentIndex = 0;
      } else if (currentLocation == '/team') {
        currentIndex = 1;
      } else if (currentLocation == '/schedule') {
        currentIndex = 2;
      } else if (currentLocation == '/profile') {
        currentIndex = 3;
      }
    } else if (role == 'любитель') {
      if (currentLocation == '/home') {
        currentIndex = 0;
      } else if (currentLocation == '/game-search') {
        currentIndex = 1;
      } else if (currentLocation == '/schedule') {
        currentIndex = 2;
      } else if (currentLocation == '/profile') {
        currentIndex = 3;
      }
    } else if (role == 'болельщик') {
      if (fanWantsGames) {
        if (currentLocation == '/home') {
          currentIndex = 0;
        } else if (currentLocation == '/game-search') {
          currentIndex = 1;
        } else if (currentLocation == '/schedule') {
          currentIndex = 2;
        } else if (currentLocation == '/teams-follow') {
          currentIndex = 3;
        } else if (currentLocation == '/profile') {
          currentIndex = 4;
        }
      } else {
        if (currentLocation == '/home') {
          currentIndex = 0;
        } else if (currentLocation == '/schedule') {
          currentIndex = 1;
        } else if (currentLocation == '/teams-follow') {
          currentIndex = 2;
        } else if (currentLocation == '/profile') {
          currentIndex = 3;
        }
      }
    } else if (role == 'admin') {
      if (currentLocation == '/home') {
        currentIndex = 0;
      } else if (currentLocation == '/schedule') {
        currentIndex = 1;
      } else if (currentLocation == '/profile') {
        currentIndex = 2;
      }
    } else if (role == 'captain') {
      if (currentLocation == '/home') {
        currentIndex = 0;
      } else if (currentLocation == '/schedule') {
        currentIndex = 1;
      } else if (currentLocation == '/team') {
        currentIndex = 2;
      } else if (currentLocation == '/profile') {
        currentIndex = 3;
      }
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTabTapped(index, context, role, fanWantsGames),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      items: items,
    );
  }

  void _onTabTapped(int index, BuildContext context, String role, bool fanWantsGames) {
    switch (role) {
      case 'игрок':
        if (index == 0) {
          context.go('/home');
        }
        if (index == 1) {
          context.go('/team');
        }
        if (index == 2) {
          context.go('/schedule');
        }
        if (index == 3) {
          context.go('/profile');
        }
        break;
      case 'любитель':
        if (index == 0) {
          context.go('/home');
        }
        if (index == 1) {
          context.go('/game-search');
        }
        if (index == 2) {
          context.go('/schedule');
        }
        if (index == 3) {
          context.go('/profile');
        }
        break;
      case 'болельщик':
        if (fanWantsGames) {
          if (index == 0) {
            context.go('/home');
          }
          if (index == 1) {
            context.go('/game-search');
          }
          if (index == 2) {
            context.go('/schedule');
          }
          if (index == 3) {
            context.go('/teams-follow');
          }
          if (index == 4) {
            context.go('/profile');
          }
        } else {
          if (index == 0) {
            context.go('/home');
          }
          if (index == 1) {
            context.go('/schedule');
          }
          if (index == 2) {
            context.go('/teams-follow');
          }
          if (index == 3) {
            context.go('/profile');
          }
        }
        break;
      case 'admin':
        if (index == 0) {
          context.go('/home');
        }
        if (index == 1) {
          context.go('/schedule');
        }
        if (index == 2) {
          context.go('/profile');
        }
        break;
      case 'captain':
        if (index == 0) {
          context.go('/home');
        }
        if (index == 1) {
          context.go('/schedule');
        }
        if (index == 2) {
          context.go('/team');
        }
        if (index == 3) {
          context.go('/profile');
        }
        break;
    }
  }

  void _editPlayer(Map<String, dynamic> player) {
    final nameCtrl = TextEditingController(text: player['full_name']);
    final phoneCtrl = TextEditingController(text: player['phone']);
    final positionCtrl = TextEditingController(text: player['position']);
    final numberCtrl = TextEditingController(text: (player['number'] ?? '').toString());
    final emailCtrl = TextEditingController(text: player['email']);
    final birthDateCtrl = TextEditingController(text: player['birth_date'] ?? '');
    final positions = ['Связующий', 'Защитник', 'Либеро', 'Диагональный', 'Доигровщик'];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Редактировать игрока'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'ФИО')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Телефон'), keyboardType: TextInputType.phone),
              DropdownButtonFormField<String>(
                initialValue: player['position'],
                items: positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => positionCtrl.text = v ?? '',
                decoration: const InputDecoration(labelText: 'Позиция'),
              ),
              TextField(controller: numberCtrl, decoration: const InputDecoration(labelText: 'Номер'), keyboardType: TextInputType.number),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), enabled: false),
              TextField(
                controller: birthDateCtrl,
                decoration: const InputDecoration(labelText: 'Дата рождения'),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: dialogContext,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    birthDateCtrl.text = date.toIso8601String().split('T')[0];
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              await _teamService.updatePlayerInTeam(
                userId: player['user_id'],
                fullName: nameCtrl.text,
                phone: phoneCtrl.text,
                position: positionCtrl.text,
                number: int.tryParse(numberCtrl.text) ?? 0,
                birthDate: birthDateCtrl.text,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              await _loadTeamMembers();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Данные обновлены')));
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _removePlayer(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удаление игрока'),
        content: const Text('Вы уверены?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _teamService.removePlayerFromTeam(_teamId, userId);
      await _loadTeamMembers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Игрок удалён')));
      }
    }
  }
}