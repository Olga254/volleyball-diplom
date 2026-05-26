import 'supabase_service.dart';

class InvitationService {
  final SupabaseService _supabase = SupabaseService();

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final res = await _supabase.client.rpc('find_user_by_email', params: {'p_email': email}).maybeSingle();
    return res;
  }

  Future<void> inviteToGame({required int gameId, required String inviterId, required String inviteeId}) async {
    await _supabase.client.from('game_invitations').insert({
      'game_id': gameId,
      'inviter_id': inviterId,
      'invitee_id': inviteeId,
      'status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> getReceivedInvitations(String userId) async {
    final res = await _supabase.client
        .from('game_invitations')
        .select('*, games(title, date, start_time, location)')
        .eq('invitee_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getSentInvitations(String userId) async {
    final res = await _supabase.client
        .from('game_invitations')
        .select('*, games(title, date, start_time, location)')
        .eq('inviter_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getAcceptedParticipants(int gameId) async {
    final res = await _supabase.client
        .from('game_invitations')
        .select('invitee_id, profiles(full_name)')
        .eq('game_id', gameId)
        .eq('status', 'accepted');
    return res.map((r) => r['profiles'] as Map<String, dynamic>).toList();
  }

  Future<void> respondToInvitation(String invitationId, bool accept) async {
    final status = accept ? 'accepted' : 'declined';
    await _supabase.client
        .from('game_invitations')
        .update({'status': status})
        .eq('id', invitationId);
  }

  Future<List<Map<String, dynamic>>> getActiveApplications() async {
    final res = await _supabase.client
        .from('player_applications')
        .select('*, profiles(full_name, phone, email)')
        .eq('status', 'active');
    return List<Map<String, dynamic>>.from(res);
  }
}