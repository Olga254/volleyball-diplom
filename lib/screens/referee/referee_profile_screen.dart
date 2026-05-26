import 'package:flutter/material.dart';
import '../../services/game_service.dart';

class RefereeProfileScreen extends StatelessWidget {
  final String refereeName;
  const RefereeProfileScreen({super.key, required this.refereeName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: GameService().getAllGames(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Профиль судьи'), leading: const BackButton()),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final games = snapshot.data!.where((g) => g['referee'] == refereeName).toList();
        final rating = games.isNotEmpty ? (games.where((g) => g['score'] != null).length / games.length).toStringAsFixed(1) : '0.0';
        return Scaffold(
          appBar: AppBar(title: Text('Профиль судьи: $refereeName'), leading: const BackButton()),
          body: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: ListTile(
                  title: Text(refereeName),
                  subtitle: Text('Рейтинг: $rating / 5.0'),
                  leading: const Icon(Icons.people, size: 40),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Проведённые игры', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final g = games[index];
                    return ListTile(
                      title: Text(g['title'] ?? 'Игра'),
                      subtitle: Text('${g['date']} | Счёт: ${g['score'] ?? 'нет'}'),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}