import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _news = [];
  bool _isLoading = true;
  final List<String> _volleyballImages = [
    'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=400',
    'https://images.unsplash.com/photo-1592656094267-764a45160876?w=400',
    'https://images.unsplash.com/photo-1574623452334-1e0ac2b3ccb4?w=400',
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _news = [
        {
          'id': 1,
          'title': 'Начало нового сезона волейбола 2025',
          'content': 'Уважаемые игроки и болельщики! Рады сообщить, что с 15 сентября начинается новый сезон.',
          'category': 'Новости лиги',
          'image_url': _volleyballImages[0],
          'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        },
        {
          'id': 2,
          'title': 'Турнир выходного дня в Москве',
          'content': 'Приглашаем все команды на открытый турнир по волейболу 7-8 сентября.',
          'category': 'Соревнования',
          'image_url': _volleyballImages[1],
          'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        },
        {
          'id': 3,
          'title': 'Мастер-класс от профессионалов',
          'content': '24 сентября мастер-класс от игроков сборной России. Вход свободный.',
          'category': 'Обучение',
          'image_url': _volleyballImages[2],
          'created_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        },
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.userProfile?['role'] ?? 'игрок';
    final fanWantsGames = auth.fanWantsGames;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новости', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/notifications'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                context.push('/profile');
              }
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Row(children: [Icon(Icons.person), SizedBox(width: 8), Text('Профиль')])),
              const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('Выйти', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNews,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _news.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _buildNewsCard(_news[index]),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(role, fanWantsGames),
      floatingActionButton: role == 'admin'
          ? FloatingActionButton(
              onPressed: () => context.push('/admin'),
              child: const Icon(Icons.admin_panel_settings),
            )
          : role == 'captain'
              ? FloatingActionButton(
                  onPressed: () => context.push('/captain'),
                  child: const Icon(Icons.groups),
                )
              : null,
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

  Widget _buildNewsCard(Map<String, dynamic> news) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            child: Image.network(
              news['image_url'],
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 150,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(news['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(news['content'], maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withAlpha(30), borderRadius: BorderRadius.circular(4)),
                      child: Text(news['category'] ?? 'Новости', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12)),
                    ),
                    Text(_formatDate(news['created_at']), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) {
        return 'Сегодня';
      }
      if (diff.inDays == 1) {
        return 'Вчера';
      }
      if (diff.inDays < 7) {
        return '${diff.inDays} дня назад';
      }
      return '${date.day}.${date.month}.${date.year}';
    } catch (_) {
      return dateString;
    }
  }

  Future<void> _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).signOut();
    if (mounted) {
      context.go('/authorization');
    }
  }
}