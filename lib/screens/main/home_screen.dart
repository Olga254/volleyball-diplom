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

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _news = [
        {
          'id': 1,
          'title': 'Начало нового сезона волейбола 2024',
          'content': 'Уважаемые игроки и болельщики! Рады сообщить, что с 15 сентября начинается новый сезон волейбольных соревнований.',
          'category': 'Новости лиги',
          'image_url': 'https://picsum.photos/id/1/400/200',
          'created_at': '2024-09-01T10:00:00Z',
        },
        {
          'id': 2,
          'title': 'Турнир выходного дня в Москве',
          'content': 'Приглашаем все команды на открытый турнир по волейболу, который состоится 7-8 сентября в спортивном комплексе "Олимпийский".',
          'category': 'Соревнования',
          'image_url': 'https://picsum.photos/id/2/400/200',
          'created_at': '2024-08-28T14:30:00Z',
        },
        {
          'id': 3,
          'title': 'Мастер-класс от профессиональных игроков',
          'content': '24 сентября состоится мастер-класс от игроков сборной России. Участие бесплатное.',
          'category': 'Обучение',
          'image_url': 'https://picsum.photos/id/3/400/200',
          'created_at': '2024-08-25T09:15:00Z',
        },
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<AuthProvider>(context).userProfile?['role'] ?? 'игрок';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/role'),
        ),
        title: const Text('Новости', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () => context.go('/notifications')),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') context.go('/profile');
              if (value == 'logout') _logout();
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
      bottomNavigationBar: _buildBottomNavigationBar(role),
    );
  }

  Widget _buildBottomNavigationBar(String role) {
    List<BottomNavigationBarItem> items;
    if (role == 'игрок') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главное'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Команда'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Расписание'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      ];
    } else if (role == 'любитель') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главное'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск игр'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Расписание'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      ];
    } else if (role == 'болельщик') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главное'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Расписание'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Команды'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      ];
    } else {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главное'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      ];
    }
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (role) {
          case 'игрок':
            if (index == 0) context.go('/home');
            if (index == 1) context.go('/team');
            if (index == 2) context.go('/schedule');
            if (index == 3) context.go('/profile');
            break;
          case 'любитель':
            if (index == 0) context.go('/home');
            if (index == 1) context.go('/game-search');
            if (index == 2) context.go('/schedule');
            if (index == 3) context.go('/profile');
            break;
          case 'болельщик':
            if (index == 0) context.go('/home');
            if (index == 1) context.go('/schedule');
            if (index == 2) context.go('/teams-follow');
            if (index == 3) context.go('/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: items,
    );
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
            child: Image.network(news['image_url'], height: 150, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 150, color: Colors.grey[200], child: const Icon(Icons.image, size: 50, color: Colors.grey))),
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
      if (diff.inDays == 0) return 'Сегодня';
      if (diff.inDays == 1) return 'Вчера';
      if (diff.inDays < 7) return '${diff.inDays} дня назад';
      return '${date.day}.${date.month}.${date.year}';
    } catch (_) {
      return dateString;
    }
  }

  Future<void> _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).signOut();
    if (mounted) context.go('/role');
  }
}