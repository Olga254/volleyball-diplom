class GameService {
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  List<int> joinedGameIds = [];
  List<String> followedTeamNames = [];

  final List<Map<String, dynamic>> _allGames = [
    {
      'id': 1,
      'title': 'Любители - Спартак',
      'homeTeam': 'Любители',
      'awayTeam': 'Спартак',
      'date': '2025-04-10',
      'time': '18:00',
      'location': 'Спорткомплекс "Динамо"',
      'address': 'ул. Ленина, 15',
      'surface': 'зал',
      'score': '3:1',
      'postponed': null,
      'referee': 'Сергей Васильев',
      'max_players': 12,
      'cost': 'Бесплатно',
      'target_gender': 'смешанная',
      'target_age': 'Open',
      'created_by_type': 'captain',
      'created_by_name': 'Капитан',
      'type': 'game',
    },
    {
      'id': 2,
      'title': 'Спартак - Зенит',
      'homeTeam': 'Спартак',
      'awayTeam': 'Зенит',
      'date': '2025-04-12',
      'time': '16:00',
      'location': 'Стадион "Зенит"',
      'address': 'пр. Победы, 2',
      'surface': 'пляж',
      'score': null,
      'postponed': 'неопределённый срок',
      'referee': 'Анна Козлова',
      'max_players': 10,
      'cost': '500 руб.',
      'target_gender': 'мужская',
      'target_age': 'U18',
      'created_by_type': 'admin',
      'created_by_name': 'Администратор',
      'type': 'game',
    },
    {
      'id': 3,
      'title': 'Любители - Динамо',
      'homeTeam': 'Любители',
      'awayTeam': 'Динамо',
      'date': '2025-04-20',
      'time': '15:00',
      'location': 'Дворец спорта',
      'address': 'ул. Мира, 8',
      'surface': 'зал',
      'score': null,
      'postponed': null,
      'referee': 'Игорь Смирнов',
      'max_players': 14,
      'cost': '300 руб.',
      'target_gender': 'смешанная',
      'target_age': 'Open',
      'created_by_type': 'amateur',
      'created_by_name': 'Любитель',
      'type': 'friendly',
    },
    {
      'id': 4,
      'title': 'Вечерний волейбол',
      'homeTeam': 'Сборная',
      'awayTeam': 'Любители',
      'date': '2025-04-25',
      'time': '19:00',
      'location': 'Спортзал "Центральный"',
      'address': 'ул. Спортивная, 10',
      'surface': 'зал',
      'score': null,
      'postponed': null,
      'referee': null,
      'max_players': 8,
      'cost': 'Бесплатно',
      'target_gender': 'смешанная',
      'target_age': 'Open',
      'created_by_type': 'amateur',
      'created_by_name': 'Петр Иванов',
      'type': 'friendly',
    },
  ];

  List<Map<String, dynamic>> getAllGames() => List.from(_allGames);
  List<Map<String, dynamic>> getAllGamesForAdmin() => List.from(_allGames);

  Future<void> updateGame(Map<String, dynamic> updatedGame) async {
    final index = _allGames.indexWhere((g) => g['id'] == updatedGame['id']);
    if (index != -1) _allGames[index] = updatedGame;
  }

  Future<void> createGame(Map<String, dynamic> newGame) async {
    newGame['id'] = _allGames.length + 1;
    _allGames.add(newGame);
  }

  void joinGame(int gameId) { if (!joinedGameIds.contains(gameId)) joinedGameIds.add(gameId); }
  void leaveGame(int gameId) { joinedGameIds.remove(gameId); }
  bool isJoined(int gameId) => joinedGameIds.contains(gameId);

  void followTeam(String teamName) { if (!followedTeamNames.contains(teamName)) followedTeamNames.add(teamName); }
  void unfollowTeam(String teamName) { followedTeamNames.remove(teamName); }
  bool isFollowing(String teamName) => followedTeamNames.contains(teamName);

  List<Map<String, dynamic>> getGamesForTeam(String teamName) {
    return _allGames.where((g) => g['homeTeam'] == teamName || g['awayTeam'] == teamName).toList();
  }

  Future<List<Map<String, dynamic>>> getGameParticipants(int gameId) async {
    // Заглушка – в реальном проекте запрос к Supabase
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'full_name': 'Иван Иванов'},
      {'full_name': 'Петр Петров'},
      {'full_name': 'Мария Сидорова'},
    ];
  }
}