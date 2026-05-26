import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class TeamService {
  final SupabaseService _supabase = SupabaseService();
  static final TeamService _instance = TeamService._internal();
  factory TeamService() => _instance;
  TeamService._internal();

  Future<List<Map<String, dynamic>>> getTeamMembers(String teamId) async {
    try {
      final res = await _supabase.client
          .from('team_members')
          .select('user_id, role_in_team, profiles(full_name, phone, email, position, number, experience, birth_date)')
          .eq('team_id', teamId);
      return List<Map<String, dynamic>>.from(res).map((member) {
        final profile = member['profiles'] as Map<String, dynamic>? ?? {};
        return {
          'user_id': member['user_id'],
          'full_name': profile['full_name'],
          'phone': profile['phone'],
          'email': profile['email'],
          'position': profile['position'],
          'number': profile['number'],
          'experience': profile['experience'],
          'birth_date': profile['birth_date'],
          'role_in_team': member['role_in_team'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Ошибка загрузки состава: $e');
      return [];
    }
  }

  Future<void> addPlayerToTeam({
    required String teamId,
    required String fullName,
    required String phone,
    required String position,
    required int number,
    required String email,
    required String password,
    required String experience,
    required String birthDate,
    required String createdBy,
  }) async {
    try {
      final userId = await _supabase.client.rpc(
        'create_user_and_profile',
        params: {
          'p_email': email,
          'p_password': password,
          'p_full_name': fullName,
          'p_phone': phone,
          'p_position': position,
        },
      );
      await _supabase.client
          .from('profiles')
          .update({
            'experience': experience,
            'number': number,
            'birth_date': birthDate,
          })
          .eq('id', userId);
      await _supabase.client.from('team_members').insert({
        'team_id': teamId,
        'user_id': userId,
        'role_in_team': 'игрок',
      });
    } catch (e) {
      debugPrint('Ошибка добавления игрока: $e');
      rethrow;
    }
  }

  Future<void> removePlayerFromTeam(String teamId, String userId) async {
    try {
      await _supabase.client
          .from('team_members')
          .delete()
          .eq('team_id', teamId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Ошибка удаления игрока: $e');
      rethrow;
    }
  }

  Future<void> updatePlayerInTeam({
    required String userId,
    required String fullName,
    required String phone,
    required String position,
    required int number,
    required String birthDate,
  }) async {
    try {
      await _supabase.client
          .from('profiles')
          .update({
            'full_name': fullName,
            'phone': phone,
            'position': position,
            'number': number,
            'birth_date': birthDate,
          })
          .eq('id', userId);
    } catch (e) {
      debugPrint('Ошибка обновления игрока: $e');
      rethrow;
    }
  }
}