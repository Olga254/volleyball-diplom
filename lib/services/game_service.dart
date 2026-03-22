class GameService {
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  // Список ID игр, на которые записался любитель
  List<int> joinedGameIds = [];

  // Список названий команд, на которые подписан болельщик
  List<String> followedTeamNames = [];

  // Метод для записи на игру
  void joinGame(int gameId) {
    if (!joinedGameIds.contains(gameId)) {
      joinedGameIds.add(gameId);
    }
  }

  // Метод для отмены записи
  void leaveGame(int gameId) {
    joinedGameIds.remove(gameId);
  }

  // Метод для подписки на команду
  void followTeam(String teamName) {
    if (!followedTeamNames.contains(teamName)) {
      followedTeamNames.add(teamName);
    }
  }

  // Метод для отписки от команды
  void unfollowTeam(String teamName) {
    followedTeamNames.remove(teamName);
  }

  // Проверка, записан ли любитель на игру
  bool isJoined(int gameId) => joinedGameIds.contains(gameId);

  // Проверка, подписан ли болельщик на команду
  bool isFollowing(String teamName) => followedTeamNames.contains(teamName);
}