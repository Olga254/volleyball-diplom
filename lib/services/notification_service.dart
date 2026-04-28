import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class NotificationService {
  final SupabaseService _supabase = SupabaseService();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> sendNotificationToAll({
    required String title,
    required String message,
    String? userId,
  }) async {
    try {
      if (userId == null) {
        final users = await _supabase.client.from('profiles').select('id');
        for (var user in users) {
          await _supabase.client.from('notifications').insert({
            'user_id': user['id'],
            'title': title,
            'message': message,
            'is_read': false,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      } else {
        await _supabase.client.from('notifications').insert({
          'user_id': userId,
          'title': title,
          'message': message,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Ошибка отправки уведомления: $e');
    }
  }

  Future<void> notifyGameChanged(Map<String, dynamic> game, String changeType) async {
    const title = 'Изменение в расписании';
    final message = 'Игра "${game['title']}" была $changeType. Проверьте обновления.';
    await sendNotificationToAll(title: title, message: message);
  }
}