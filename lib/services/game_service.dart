import 'supabase_service.dart';

class GameService {
  final SupabaseService _supabase = SupabaseService();

  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  Future<List<Map<String, dynamic>>> getAllGames() async {
    final res = await _supabase.client.from('games').select('*');
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getAllGamesForSearch() async {
    final res = await _supabase.client
        .from('games')
        .select('*')
        .eq('created_by_type', 'amateur');
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getGamesForTeam(String teamId) async {
    final res = await _supabase.client
        .from('games')
        .select('*')
        .or('home_team_id.eq.$teamId,away_team_id.eq.$teamId');
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getMyGames(String? userId) async {
    if (userId == null) return [];
    final participants = await _supabase.client
        .from('game_participants')
        .select('game_id')
        .eq('user_id', userId);
    final gameIds = participants.map((p) => p['game_id'] as String).toList();
    if (gameIds.isEmpty) return [];
    final res = await _supabase.client
        .from('games')
        .select('*')
        .inFilter('id', gameIds);
    return List<Map<String, dynamic>>.from(res).map((g) => {...g, 'isJoined': true}).toList();
  }

  Future<List<Map<String, dynamic>>> getGamesByUserSubscriptions(String? userId) async {
    if (userId == null) return [];
    final follows = await _supabase.client
        .from('team_follows')
        .select('team_id')
        .eq('user_id', userId);
    final teamIds = follows.map((f) => f['team_id'] as String).toList();
    if (teamIds.isEmpty) return [];
    final res = await _supabase.client
        .from('games')
        .select('*')
        .inFilter('home_team_id', teamIds)
        .or('away_team_id.in.(${teamIds.join(',')})');
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> updateGame(Map<String, dynamic> updatedGame) async {
    await _supabase.client.from('games').update(updatedGame).eq('id', updatedGame['id']);
  }

  // createGame возвращает String (UUID)
  Future<String> createGame(Map<String, dynamic> newGame) async {
    final res = await _supabase.client.from('games').insert(newGame).select('id');
    if (res.isNotEmpty) {
      return res.first['id'] as String;
    }
    throw Exception('Не удалось создать игру');
  }

  // joinGame принимает String
  Future<void> joinGame(String gameId) async {
    final userId = _supabase.client.auth.currentUser?.id;
    if (userId != null) {
      final existing = await _supabase.client
          .from('game_participants')
          .select('id')
          .eq('game_id', gameId)
          .eq('user_id', userId)
          .maybeSingle();
      if (existing == null) {
        await _supabase.client.from('game_participants').insert({
          'game_id': gameId,
          'user_id': userId,
        });
      }
    }
  }

  // leaveGame принимает String
  Future<void> leaveGame(String gameId) async {
    final userId = _supabase.client.auth.currentUser?.id;
    if (userId != null) {
      await _supabase.client
          .from('game_participants')
          .delete()
          .eq('game_id', gameId)
          .eq('user_id', userId);
    }
  }

  Future<void> followTeam(String userId, String teamId) async {
    final existing = await _supabase.client
        .from('team_follows')
        .select('id')
        .eq('user_id', userId)
        .eq('team_id', teamId)
        .maybeSingle();
    if (existing == null) {
      await _supabase.client.from('team_follows').insert({
        'user_id': userId,
        'team_id': teamId,
      });
    }
  }

  Future<void> unfollowTeam(String userId, String teamId) async {
    await _supabase.client
        .from('team_follows')
        .delete()
        .eq('user_id', userId)
        .eq('team_id', teamId);
  }

  Future<List<Map<String, dynamic>>> getAllTeams() async {
    final res = await _supabase.client.from('teams').select('*');
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getFollowedTeams(String? userId) async {
    if (userId == null) return [];
    final res = await _supabase.client
        .from('team_follows')
        .select('team_id, teams(*)')
        .eq('user_id', userId);
    return res.map((e) => e['teams'] as Map<String, dynamic>).toList();
  }
}