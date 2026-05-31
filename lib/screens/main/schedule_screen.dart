import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/game_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _myGames = [];
  List<Map<String, dynamic>> _subscriptionGames = [];
  bool _isLoading = true;
  final GameService _gameService = GameService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final role = auth.userProfile?['role'];
    final userId = auth.currentUser?.id;
    final fanWantsGames = auth.fanWantsGames;

    if (role == 'любитель') {
      _myGames = await _gameService.getMyGames(userId);
      _subscriptionGames = [];
      _setupTabController(hasMyGames: _myGames.isNotEmpty, hasSubscriptions: false);
    } else if (role == 'болельщик') {
      _myGames = fanWantsGames ? await _gameService.getMyGames(userId) : [];
      _subscriptionGames = await _gameService.getGamesByUserSubscriptions(userId);
      _setupTabController(hasMyGames: _myGames.isNotEmpty, hasSubscriptions: _subscriptionGames.isNotEmpty);
    } else if (role == 'игрок') {
      const teamId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
      _subscriptionGames = await _gameService.getGamesForTeam(teamId);
      _myGames = [];
      _setupTabController(hasMyGames: false, hasSubscriptions: _subscriptionGames.isNotEmpty);
    } else {
      _subscriptionGames = await _gameService.getAllGames();
      _myGames = [];
      _setupTabController(hasMyGames: false, hasSubscriptions: _subscriptionGames.isNotEmpty);
    }

    setState(() => _isLoading = false);
  }

  void _setupTabController({required bool hasMyGames, required bool hasSubscriptions}) {
    final length = (hasMyGames ? 1 : 0) + (hasSubscriptions ? 1 : 0);
    final newLength = length > 0 ? length : 1;
    if (_tabController.length != newLength) {
      _tabController.dispose();
      _tabController = TabController(length: newLength, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.userProfile?['role'];
    final fanWantsGames = auth.fanWantsGames;

    Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final hasMyGames = (role == 'любитель' && _myGames.isNotEmpty) ||
          (role == 'болельщик' && fanWantsGames && _myGames.isNotEmpty);
      final hasSubscriptions = (role == 'болельщик' && _subscriptionGames.isNotEmpty) ||
          (role == 'игрок' && _subscriptionGames.isNotEmpty) ||
          ((role == 'admin' || role == 'captain') && _subscriptionGames.isNotEmpty);

      if (role == 'любитель' && _myGames.isEmpty) {
        body = const Center(child: Text('Вы ещё не записаны ни на одну игру'));
      } else if (role == 'болельщик' && !hasMyGames && !hasSubscriptions) {
        body = const Center(child: Text('Нет игр для отображения. Подпишитесь на команды или настройте "Игры для себя".'));
      } else {
        List<Widget> tabs = [];
        List<Widget> tabViews = [];
        if (hasMyGames) {
          tabs.add(const Tab(text: 'Игры для себя'));
          tabViews.add(_buildGamesList(_myGames, isMyGames: true));
        }
        if (hasSubscriptions) {
          String label;
          if (role == 'игрок') {
            label = 'Игры команды';
          } else if (role == 'болельщик') {
            label = 'Подписки';
          } else {
            label = 'Все игры';
          }
          tabs.add(Tab(text: label));
          tabViews.add(_buildGamesList(_subscriptionGames, isMyGames: false));
        }
        if (tabs.isEmpty) {
          body = const Center(child: Text('Нет игр'));
        } else if (tabs.length == 1) {
          body = tabViews.first;
        } else {
          body = Column(
            children: [
              TabBar(controller: _tabController, tabs: tabs),
              Expanded(child: TabBarView(controller: _tabController, children: tabViews)),
            ],
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Расписание')),
      body: body,
      bottomNavigationBar: _buildBottomNavigationBar(role ?? 'игрок', fanWantsGames),
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

  Widget _buildGamesList(List<Map<String, dynamic>> games, {required bool isMyGames}) {
    if (games.isEmpty) {
      return const Center(child: Text('Нет игр'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final g = games[index];
        final isPostponed = g['postponed'] != null && g['postponed'] != '';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(g['title'] ?? 'Игра', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📅 ${g['date'] ?? 'Дата не указана'} ${g['start_time'] ?? ''}'),
                Text('📍 ${g['location'] ?? ''}', style: TextStyle(color: isPostponed ? Colors.red : null)),
                Text('👨‍⚖️ Судья: ${g['referee'] ?? 'не назначен'}'),
                if (isPostponed) Text('⚠️ Перенос: ${g['postponed']}', style: const TextStyle(color: Colors.red)),
              ],
            ),
            trailing: isMyGames && g['isJoined'] == true ? const Icon(Icons.check_circle, color: Colors.green) : null,
            onTap: () => _showGameDetails(g),
          ),
        );
      },
    );
  }

  void _showGameDetails(Map<String, dynamic> game) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(game['title'] ?? 'Игра'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Дата: ${game['date'] ?? ''} ${game['start_time'] ?? ''}'),
            Text('Место: ${game['location'] ?? ''}'),
            if (game['address'] != null) Text('Адрес: ${game['address']}'),
            Text('Счёт: ${game['score'] ?? 'не указан'}'),
            if (game['postponed'] != null) Text('Перенос: ${game['postponed']}', style: const TextStyle(color: Colors.red)),
            Text('Судья: ${game['referee'] ?? 'не назначен'}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Закрыть')),
        ],
      ),
    );
  }
}