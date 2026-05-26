import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/invitation_service.dart';
import '../../services/game_service.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  List<Map<String, dynamic>> _receivedInvitations = [];
  List<Map<String, dynamic>> _sentInvitations = [];
  bool _isLoading = true;
  final InvitationService _invitationService = InvitationService();
  final GameService _gameService = GameService();

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId == null) return;
    _receivedInvitations = await _invitationService.getReceivedInvitations(userId);
    _sentInvitations = await _invitationService.getSentInvitations(userId);
    setState(() => _isLoading = false);
  }

  Future<void> _respond(String invitationId, bool accept) async {
    await _invitationService.respondToInvitation(invitationId, accept);
    if (accept) {
      final inv = _receivedInvitations.firstWhere((i) => i['id'] == invitationId);
      await _gameService.joinGame(inv['game_id']);
    }
    _loadInvitations();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(accept ? 'Вы приняли приглашение' : 'Вы отказались')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Приглашения'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(tabs: [
            Tab(text: 'Мне'),
            Tab(text: 'Мои приглашения'),
          ]),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildInvitationsList(_receivedInvitations, isReceived: true),
                  _buildInvitationsList(_sentInvitations, isReceived: false),
                ],
              ),
      ),
    );
  }

  Widget _buildInvitationsList(List<Map<String, dynamic>> invitations, {required bool isReceived}) {
    if (invitations.isEmpty) {
      return const Center(child: Text('Нет приглашений'));
    }
    return ListView.builder(
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        final inv = invitations[index];
        final game = inv['games'] as Map<String, dynamic>? ?? {};
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(game['title'] ?? 'Игра'),
            subtitle: Text('${game['date']} ${game['start_time']}\n${game['location']}'),
            trailing: isReceived && inv['status'] == 'pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _respond(inv['id'], true)),
                      IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _respond(inv['id'], false)),
                    ],
                  )
                : Chip(label: Text(inv['status'])),
          ),
        );
      },
    );
  }
}