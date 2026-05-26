import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/game_service.dart';

class TeamsFollowScreen extends StatefulWidget {
  const TeamsFollowScreen({super.key});

  @override
  State<TeamsFollowScreen> createState() => _TeamsFollowScreenState();
}

class _TeamsFollowScreenState extends State<TeamsFollowScreen> {
  List<Map<String, dynamic>> _allTeams = [];
  List<Map<String, dynamic>> _followedTeams = [];
  bool _isLoading = true;
  final GameService _gameService = GameService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    _allTeams = await _gameService.getAllTeams();
    _followedTeams = await _gameService.getFollowedTeams(userId);
    setState(() => _isLoading = false);
  }

  void _toggleFollow(String teamId) async {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId == null) {
      return;
    }
    final isFollowed = _followedTeams.any((t) => t['id'] == teamId);
    if (isFollowed) {
      await _gameService.unfollowTeam(userId, teamId);
    } else {
      await _gameService.followTeam(userId, teamId);
    }
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.userProfile?['role'] ?? 'болельщик';
    final fanWantsGames = auth.fanWantsGames;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allTeams.length,
              itemBuilder: (context, index) {
                final t = _allTeams[index];
                final isFollowed = _followedTeams.any((ft) => ft['id'] == t['id']);
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(t['name']),
                    subtitle: Text(t['description'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => context.push('/team-profile/${t['id']}'),
                          child: const Text('Подробнее'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _toggleFollow(t['id']),
                          style: ElevatedButton.styleFrom(backgroundColor: isFollowed ? Colors.green : Colors.blue),
                          child: Text(isFollowed ? 'Отписаться' : 'Подписаться'),
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
}