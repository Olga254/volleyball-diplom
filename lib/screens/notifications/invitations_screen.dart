import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/application_service.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  List<Map<String, dynamic>> _invitations = [];
  bool _isLoading = true;
  final ApplicationService _appService = ApplicationService();

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    setState(() => _isLoading = true);
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId != null) {
      _invitations = await _appService.getUserInvitations(userId);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _respond(String invitationId, bool accept) async {
    await _appService.respondToInvitation(invitationId, accept);
    _loadInvitations();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(accept ? 'Вы приняли приглашение' : 'Вы отказались')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Приглашения на игры')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invitations.isEmpty
              ? const Center(child: Text('Нет приглашений'))
              : ListView.builder(
                  itemCount: _invitations.length,
                  itemBuilder: (context, index) {
                    final inv = _invitations[index];
                    final game = inv['games'] as Map<String, dynamic>?;
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(game?['title'] ?? 'Игра'),
                        subtitle: Text('${game?['date']} ${game?['time']}\n${game?['location']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _respond(inv['id'], true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _respond(inv['id'], false),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}