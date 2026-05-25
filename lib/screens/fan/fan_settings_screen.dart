import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class FanSettingsScreen extends StatefulWidget {
  const FanSettingsScreen({super.key});

  static Future<void> showFirstTimeDialog(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.userProfile;
    // Если уже есть ответы, не показываем
    if (user?['fan_plays_self'] != null && user?['fan_wants_games'] != null) return;
    bool playsSelf = false;
    bool wantsGames = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Добро пожаловать, болельщик!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Вы сами играете в волейбол?'),
              SwitchListTile(
                title: const Text('Да, я играю'),
                value: playsSelf,
                onChanged: (v) => setStateDialog(() { playsSelf = v; if (!v) wantsGames = false; }),
              ),
              if (playsSelf)
                SwitchListTile(
                  title: const Text('Хочу искать игры для себя'),
                  value: wantsGames,
                  onChanged: (v) => setStateDialog(() => wantsGames = v),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await auth.updateFanSettings(playsSelf, wantsGames);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<FanSettingsScreen> createState() => _FanSettingsScreenState();
}

class _FanSettingsScreenState extends State<FanSettingsScreen> {
  bool _playsSelf = false;
  bool _wantsGames = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _playsSelf = auth.userProfile?['fan_plays_self'] == true;
    _wantsGames = auth.userProfile?['fan_wants_games'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки болельщика')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Вы сами играете в волейбол?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Да, я играю сам'),
              value: _playsSelf,
              onChanged: (value) {
                setState(() => _playsSelf = value);
                if (!value) setState(() => _wantsGames = false);
              },
            ),
            if (_playsSelf) ...[
              const SizedBox(height: 16),
              const Text('Хотите искать игры для себя?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SwitchListTile(
                title: const Text('Да, искать игры'),
                value: _wantsGames,
                onChanged: (value) => setState(() => _wantsGames = value),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveSettings,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.updateFanSettings(_playsSelf, _wantsGames);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Настройки сохранены')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}