import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/game_service.dart';
import '../../services/invitation_service.dart';
import '../amateur/game_details_screen.dart';

class GameSearchScreen extends StatefulWidget {
  const GameSearchScreen({super.key});

  @override
  State<GameSearchScreen> createState() => _GameSearchScreenState();
}

class _GameSearchScreenState extends State<GameSearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _games = [];
  bool _isLoadingGames = true;
  final GameService _gameService = GameService();
  final InvitationService _invitationService = InvitationService();
  String? _currentUserId;
  String? _filterSurface;
  String? _filterGender;
  String? _filterAge;
  String? _filterLevel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUser();
    _loadGames();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    _currentUserId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
  }

  Future<void> _loadGames() async {
    setState(() => _isLoadingGames = true);
    final allGames = await _gameService.getAllGamesForSearch();
    final myGames = await _gameService.getMyGames(_currentUserId);
    final myGameIds = myGames.map((g) => g['id'] as String).toList();
    for (var game in allGames) {
      game['isJoined'] = myGameIds.contains(game['id']);
    }
    _games = allGames;
    setState(() => _isLoadingGames = false);
  }

  List<Map<String, dynamic>> get _filteredGames {
    return _games.where((game) {
      if (_filterSurface != null && game['surface'] != _filterSurface) return false;
      if (_filterGender != null && game['target_gender'] != _filterGender) return false;
      if (_filterAge != null && game['target_age'] != _filterAge) return false;
      if (_filterLevel != null && game['level'] != _filterLevel) return false;
      return true;
    }).toList();
  }

  Future<void> _toggleJoin(Map<String, dynamic> game) async {
    final newState = !(game['isJoined'] as bool);
    setState(() => game['isJoined'] = newState);
    try {
      if (newState) {
        await _gameService.joinGame(game['id'] as String);
      } else {
        await _gameService.leaveGame(game['id'] as String);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newState ? 'Вы записаны на игру' : 'Вы отказались')),
        );
      }
    } catch (e) {
      setState(() => game['isJoined'] = !newState);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.userProfile?['role'] ?? 'игрок';
    final fanWantsGames = auth.fanWantsGames;
    final canCreateGame = (role == 'любитель') || (role == 'admin');

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canCreateGame)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => context.push('/amateur/create-game'),
                    tooltip: 'Создать игру',
                  ),
                if (role == 'любитель')
                  IconButton(
                    icon: const Icon(Icons.assignment),
                    onPressed: () => context.push('/amateur/application'),
                    tooltip: 'Моя анкета',
                  ),
                IconButton(
                  icon: const Icon(Icons.mail),
                  onPressed: () => context.push('/invitations'),
                  tooltip: 'Приглашения',
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Поиск игр'),
              Tab(text: 'Анкеты игроков'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGamesTab(),
                _buildApplicationsTab(),
              ],
            ),
          ),
        ],
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
      if (currentLocation == '/home') { currentIndex = 0; }
      else if (currentLocation == '/team') { currentIndex = 1; }
      else if (currentLocation == '/schedule') { currentIndex = 2; }
      else if (currentLocation == '/profile') { currentIndex = 3; }
    } else if (role == 'любитель') {
      if (currentLocation == '/home') { currentIndex = 0; }
      else if (currentLocation == '/game-search') { currentIndex = 1; }
      else if (currentLocation == '/schedule') { currentIndex = 2; }
      else if (currentLocation == '/profile') { currentIndex = 3; }
    } else if (role == 'болельщик') {
      if (fanWantsGames) {
        if (currentLocation == '/home') { currentIndex = 0; }
        else if (currentLocation == '/game-search') { currentIndex = 1; }
        else if (currentLocation == '/schedule') { currentIndex = 2; }
        else if (currentLocation == '/teams-follow') { currentIndex = 3; }
        else if (currentLocation == '/profile') { currentIndex = 4; }
      } else {
        if (currentLocation == '/home') { currentIndex = 0; }
        else if (currentLocation == '/schedule') { currentIndex = 1; }
        else if (currentLocation == '/teams-follow') { currentIndex = 2; }
        else if (currentLocation == '/profile') { currentIndex = 3; }
      }
    } else if (role == 'admin') {
      if (currentLocation == '/home') { currentIndex = 0; }
      else if (currentLocation == '/schedule') { currentIndex = 1; }
      else if (currentLocation == '/profile') { currentIndex = 2; }
    } else if (role == 'captain') {
      if (currentLocation == '/home') { currentIndex = 0; }
      else if (currentLocation == '/schedule') { currentIndex = 1; }
      else if (currentLocation == '/team') { currentIndex = 2; }
      else if (currentLocation == '/profile') { currentIndex = 3; }
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
        if (index == 0) { context.go('/home'); }
        if (index == 1) { context.go('/team'); }
        if (index == 2) { context.go('/schedule'); }
        if (index == 3) { context.go('/profile'); }
        break;
      case 'любитель':
        if (index == 0) { context.go('/home'); }
        if (index == 1) { context.go('/game-search'); }
        if (index == 2) { context.go('/schedule'); }
        if (index == 3) { context.go('/profile'); }
        break;
      case 'болельщик':
        if (fanWantsGames) {
          if (index == 0) { context.go('/home'); }
          if (index == 1) { context.go('/game-search'); }
          if (index == 2) { context.go('/schedule'); }
          if (index == 3) { context.go('/teams-follow'); }
          if (index == 4) { context.go('/profile'); }
        } else {
          if (index == 0) { context.go('/home'); }
          if (index == 1) { context.go('/schedule'); }
          if (index == 2) { context.go('/teams-follow'); }
          if (index == 3) { context.go('/profile'); }
        }
        break;
      case 'admin':
        if (index == 0) { context.go('/home'); }
        if (index == 1) { context.go('/schedule'); }
        if (index == 2) { context.go('/profile'); }
        break;
      case 'captain':
        if (index == 0) { context.go('/home'); }
        if (index == 1) { context.go('/schedule'); }
        if (index == 2) { context.go('/team'); }
        if (index == 3) { context.go('/profile'); }
        break;
    }
  }

  Widget _buildGamesTab() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              FilterChip(label: const Text('Зал'), selected: _filterSurface == 'зал', onSelected: (s) => setState(() => _filterSurface = s ? 'зал' : null)),
              const SizedBox(width: 8),
              FilterChip(label: const Text('Пляж'), selected: _filterSurface == 'пляж', onSelected: (s) => setState(() => _filterSurface = s ? 'пляж' : null)),
              const SizedBox(width: 8),
              FilterChip(label: const Text('Женская'), selected: _filterGender == 'женская', onSelected: (s) => setState(() => _filterGender = s ? 'женская' : null)),
              const SizedBox(width: 8),
              FilterChip(label: const Text('Мужская'), selected: _filterGender == 'мужская', onSelected: (s) => setState(() => _filterGender = s ? 'мужская' : null)),
              const SizedBox(width: 8),
              FilterChip(label: const Text('Смешанная'), selected: _filterGender == 'смешанная', onSelected: (s) => setState(() => _filterGender = s ? 'смешанная' : null)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                hint: const Text('Возраст'),
                value: _filterAge,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Все')),
                  DropdownMenuItem(value: 'U18', child: Text('U18')),
                  DropdownMenuItem(value: 'U21', child: Text('U21')),
                  DropdownMenuItem(value: 'Open', child: Text('Open')),
                ],
                onChanged: (v) => setState(() => _filterAge = v),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                hint: const Text('Уровень'),
                value: _filterLevel,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Все')),
                  DropdownMenuItem(value: 'Любитель', child: Text('Любитель')),
                  DropdownMenuItem(value: 'Продвинутый', child: Text('Продвинутый')),
                  DropdownMenuItem(value: 'PRO', child: Text('PRO')),
                ],
                onChanged: (v) => setState(() => _filterLevel = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingGames
              ? const Center(child: CircularProgressIndicator())
              : _filteredGames.isEmpty
                  ? const Center(child: Text('Нет доступных игр'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredGames.length,
                      itemBuilder: (context, index) {
                        final g = _filteredGames[index];
                        final isJoined = g['isJoined'] == true;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => GameDetailsScreen(game: g)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(g['title'] ?? 'Игра'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('📅 ${g['date']} ${g['start_time']}'),
                                      Text('📍 ${g['location']}'),
                                      if (g['address'] != null) Text('🏠 ${g['address']}'),
                                      Text('💰 Стоимость: ${g['cost'] ?? 'Бесплатно'}'),
                                      if (g['target_gender'] != null) Text('👫 Пол: ${g['target_gender']}'),
                                      if (g['target_age'] != null) Text('🎂 Возраст: ${g['target_age']}'),
                                      Text('👨‍⚖️ Судья: ${g['referee'] ?? 'нет'}'),
                                    ],
                                  ),
                                  trailing: isJoined
                                      ? OutlinedButton(
                                          onPressed: () => _toggleJoin(g),
                                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                          child: const Text('Отказаться'),
                                        )
                                      : ElevatedButton(
                                          onPressed: () => _toggleJoin(g),
                                          child: const Text('Записаться'),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildApplicationsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _invitationService.getActiveApplications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Нет активных анкет'));
        }
        final applications = snapshot.data!;
        return ListView.builder(
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final app = applications[index];
            final player = app['profiles'] as Map<String, dynamic>?;
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(player?['full_name'] ?? 'Игрок'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Позиция: ${app['position']}'),
                    Text('Опыт: ${app['experience']}'),
                    Text('Тип: ${app['game_type']}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Функция приглашения в разработке')),
                    );
                  },
                  child: const Text('Пригласить'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}