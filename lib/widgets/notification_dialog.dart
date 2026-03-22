import 'package:flutter/material.dart';

class NotificationDialog extends StatelessWidget {
  final Map<String, dynamic>? notification;

  const NotificationDialog({super.key, this.notification});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(notification?['title'] ?? 'Уведомление'),
      content: Text(notification?['message'] ?? ''),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}