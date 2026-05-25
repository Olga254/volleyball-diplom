import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class ApplicationService {
  final SupabaseService _supabase = SupabaseService();
  static final ApplicationService _instance = ApplicationService._internal();
  factory ApplicationService() => _instance;
  ApplicationService._internal();

  // Создание заявки (любитель)
  Future<void> createApplication({
    required String userId,
    required String position,
    required String experience,
    required String gameType,
  }) async {
    try {
      await _supabase.client.from('player_applications').insert({
        'user_id': userId,
        'position': position,
        'experience': experience,
        'game_type': gameType,
        'status': 'active',
      });
    } catch (e) {
      debugPrint('Ошибка создания заявки: $e');
    }
  }

  // Получить активные заявки
  Future<List<Map<String, dynamic>>> getActiveApplications() async {
    try {
      final res = await _supabase.client
          .from('player_applications')
          .select('*, profiles(full_name, phone, email)')
          .eq('status', 'active');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('Ошибка загрузки заявок: $e');
      return [];
    }
  }

  // Пригласить игрока на игру
  Future<void> invitePlayerToGame(String gameId, String userId) async {
    try {
      await _supabase.client.from('game_invitations').insert({
        'game_id': gameId,
        'user_id': userId,
        'status': 'pending',
      });
      await _supabase.client
          .from('player_applications')
          .update({'status': 'invited'})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Ошибка приглашения: $e');
    }
  }

  // Ответ на приглашение
  Future<void> respondToInvitation(String invitationId, bool accept) async {
    final status = accept ? 'accepted' : 'declined';
    await _supabase.client
        .from('game_invitations')
        .update({'status': status, 'responded_at': DateTime.now().toIso8601String()})
        .eq('id', invitationId);
    if (accept) {
      final inv = await _supabase.client
          .from('game_invitations')
          .select('user_id')
          .eq('id', invitationId)
          .single();
      await _supabase.client
          .from('player_applications')
          .update({'status': 'accepted'})
          .eq('user_id', inv['user_id']);
    }
  }

  // Количество приглашений (исправленный метод – без CountOption)
  Future<int> getInvitationsCount(String userId) async {
    try {
      final res = await _supabase.client
          .from('game_invitations')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'pending');
      return res.length;
    } catch (e) {
      debugPrint('Ошибка подсчёта приглашений: $e');
      return 0;
    }
  }

  // Список приглашений пользователя
  Future<List<Map<String, dynamic>>> getUserInvitations(String userId) async {
    try {
      final res = await _supabase.client
          .from('game_invitations')
          .select('*, games(title, date, time, location)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('Ошибка загрузки приглашений: $e');
      return [];
    }
  }
}