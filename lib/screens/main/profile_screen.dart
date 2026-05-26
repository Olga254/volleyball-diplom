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
    final fanWantsGames = authProvider.fanWantsGames;
    final displayName = user?['full_name'] ?? 'Пользователь';

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
      body: _showSettings
          ? _buildSettingsView(authProvider, role, user)
          : _buildProfileView(displayName, user, role),
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

  Widget _buildProfileView(String displayName, Map<String, dynamic>? user, String role) {
    return SingleChildScrollView(
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
          const Padding(padding: EdgeInsets.all(16), child: Row(children: [Icon(Icons.notifications_active), SizedBox(width: 16), Text('Уведомления', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))])),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Посмотреть все уведомления'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView(AuthProvider authProvider, String role, Map<String, dynamic>? user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.all(16), child: Row(children: [Icon(Icons.settings), SizedBox(width: 16), Text('Настройки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))])),
          ListTile(leading: const Icon(Icons.brightness_6), title: const Text('Тема приложения'), trailing: Switch(value: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark, onChanged: (_) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme()), onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme()),
          ListTile(leading: const Icon(Icons.person), title: const Text('Изменить имя'), trailing: const Icon(Icons.edit), onTap: () => _showEditNameDialog(context, authProvider)),
          if (role == 'игрок' || role == 'любитель')
            ListTile(leading: const Icon(Icons.switch_account), title: const Text('Сменить роль'), subtitle: Text(role == 'игрок' ? 'Стать любителем' : 'Стать игроком'), trailing: const Icon(Icons.arrow_forward_ios), onTap: () => _changeRole(authProvider, role)),
          if (role == 'игрок')
            ListTile(leading: const Icon(Icons.sports_volleyball), title: const Text('Изменить позицию'), trailing: const Icon(Icons.edit), onTap: () => _showEditPositionDialog(context, authProvider, user?['position'] ?? '')),
          ListTile(leading: const Icon(Icons.phone), title: const Text('Изменить телефон'), trailing: const Icon(Icons.edit), onTap: () => _showEditPhoneDialog(context, authProvider, user?['phone'] ?? '')),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Выйти', style: TextStyle(color: Colors.red)), onTap: _logout),
        ],
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Роль изменена на ${_capitalize(newRole)}')));
      Navigator.pop(context);
    }
  }

  Future<void> _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).signOut();
    if (mounted) {
      context.go('/authorization');
    }
  }

  String _capitalize(String text) => text.isNotEmpty ? '${text[0].toUpperCase()}${text.substring(1)}' : text;
}