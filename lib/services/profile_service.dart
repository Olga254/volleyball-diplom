import 'supabase_service.dart';

class ProfileService {
  final SupabaseService _supabase = SupabaseService();

  Future<void> updateProfileAfterRole({
    required String userId,
    String? position,
    String? teamName,
    String? experience,
  }) async {
    final data = <String, dynamic>{};
    if (position != null) data['position'] = position;
    if (teamName != null) data['team_name'] = teamName;
    if (experience != null) data['experience'] = experience;
    await _supabase.client.from('profiles').update(data).eq('id', userId);
  }
}