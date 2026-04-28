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
      'location': 'Спорткомплекс "Динамо", ул. Ленина, 15',
      'score': '3:1',
      'postponed': null,
      'referee': 'Сергей Васильев',
    },
    {
      'id': 2,
      'title': 'Спартак - Зенит',
      'homeTeam': 'Спартак',
      'awayTeam': 'Зенит',
      'date': '2025-04-12',
      'time': '16:00',
      'location': 'Стадион "Зенит", пр. Победы, 2',
      'score': null,
      'postponed': 'неопределённый срок',
      'referee': 'Анна Козлова',
    },
    {
      'id': 3,
      'title': 'Любители - Динамо',
      'homeTeam': 'Любители',
      'awayTeam': 'Динамо',
      'date': '2025-04-20',
      'time': '15:00',
      'location': 'Дворец спорта, ул. Мира, 8',
      'score': null,
      'postponed': null,
      'referee': 'Игорь Смирнов',
    },
  ];

  List<Map<String, dynamic>> getAllGames() => List.from(_allGames);
  List<Map<String, dynamic>> getAllGamesForAdmin() => List.from(_allGames);

  Future<void> updateGame(Map<String, dynamic> updatedGame) async {
    final index = _allGames.indexWhere((g) => g['id'] == updatedGame['id']);
    if (index != -1) {
      _allGames[index] = updatedGame;
    }
  }

  Future<void> createGame(Map<String, dynamic> newGame) async {
    newGame['id'] = _allGames.length + 1;
    _allGames.add(newGame);
  }

  void joinGame(int gameId) {
    if (!joinedGameIds.contains(gameId)) joinedGameIds.add(gameId);
  }

  void leaveGame(int gameId) {
    joinedGameIds.remove(gameId);
  }

  bool isJoined(int gameId) => joinedGameIds.contains(gameId);

  void followTeam(String teamName) {
    if (!followedTeamNames.contains(teamName)) followedTeamNames.add(teamName);
  }

  void unfollowTeam(String teamName) {
    followedTeamNames.remove(teamName);
  }

  bool isFollowing(String teamName) => followedTeamNames.contains(teamName);

  List<Map<String, dynamic>> getGamesForTeam(String teamName) {
    return _allGames.where((game) => game['homeTeam'] == teamName || game['awayTeam'] == teamName).toList();
  }
}