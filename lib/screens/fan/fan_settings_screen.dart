import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class FanSettingsScreen extends StatefulWidget {
  const FanSettingsScreen({super.key});

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
      appBar: AppBar(title: const Text('Настройки болельщика'), leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Вы сами играете в волейбол?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Да, я играю'),
              value: _playsSelf,
              onChanged: (value) => setState(() => _playsSelf = value),
            ),
            if (_playsSelf) ...[
              const SizedBox(height: 16),
              const Text('Хотите искать игры для себя?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SwitchListTile(
                title: const Text('Да, искать игры'),
                value: _wantsGames,
                onChanged: (value) => setState(() => _wantsGames = value),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveSettings,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Сохранить'),
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
        // Безопасный выход: если можно pop, то pop, иначе go назад
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go('/profile');
        }
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