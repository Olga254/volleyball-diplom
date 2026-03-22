import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class NotificationProvider with ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => _notifications;

  Future<void> fetchNotifications() async {
    final userId = _supabase.client.auth.currentUser!.id;
    final response = await _supabase.client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    _notifications = List<Map<String, dynamic>>.from(response);
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    await _supabase.client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
    await fetchNotifications();
  }
}