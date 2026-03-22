import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class TeamProvider with ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  List<Map<String, dynamic>> _teams = [];
  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _teamMembers = [];
  List<Map<String, dynamic>> _invitations = [];
  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _games = [];
  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _gameResults = [];

  List<Map<String, dynamic>> get teams => _teams;
  List<Map<String, dynamic>> get teamMembers => _teamMembers;
  List<Map<String, dynamic>> get invitations => _invitations;
  List<Map<String, dynamic>> get games => _games;
  List<Map<String, dynamic>> get gameResults => _gameResults;

  Future<void> fetchTeams() async {
    final response = await _supabase.client
        .from('teams')
        .select('*, team_members(user_id, role_in_team)');
    _teams = List<Map<String, dynamic>>.from(response);
    notifyListeners();
  }

  Future<void> createTeam(Map<String, dynamic> teamData) async {
    await _supabase.client.from('teams').insert(teamData);
    await fetchTeams();
  }

  Future<void> inviteUser(String teamId, String inviteeId) async {
    final userId = _supabase.client.auth.currentUser!.id;
    await _supabase.client.from('team_invitations').insert({
      'team_id': teamId,
      'inviter_id': userId,
      'invitee_id': inviteeId,
    });
  }

  Future<void> respondToInvitation(String invitationId, bool accept) async {
    final status = accept ? 'accepted' : 'declined';
    await _supabase.client
        .from('team_invitations')
        .update({'status': status, 'responded_at': DateTime.now().toIso8601String()})
        .eq('id', invitationId);
    if (accept) {
      final inv = await _supabase.client
          .from('team_invitations')
          .select('team_id, invitee_id')
          .eq('id', invitationId)
          .single();
      await _supabase.client.from('team_members').insert({
        'team_id': inv['team_id'],
        'user_id': inv['invitee_id'],
        'role_in_team': 'игрок',
      });
    }
    await fetchInvitations();
  }

  Future<void> fetchInvitations() async {
    final userId = _supabase.client.auth.currentUser!.id;
    final response = await _supabase.client
        .from('team_invitations')
        .select('*, teams(name)')
        .eq('invitee_id', userId)
        .eq('status', 'pending');
    _invitations = List<Map<String, dynamic>>.from(response);
    notifyListeners();
  }
}