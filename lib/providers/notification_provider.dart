import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hire_me/services/notification_service.dart';

// Provider pour le service de notifications
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provider pour obtenir le token FCM
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  return NotificationService.getToken();
});

// Provider pour envoyer une notification de test
final testNotificationProvider = FutureProvider<void>((ref) async {
  await NotificationService.sendTestNotification();
});
