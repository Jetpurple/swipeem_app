import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  // Initialiser le service de notifications
  static Future<void> initialize() async {
    // Demander les permissions
    await _requestPermissions();

    // Configurer les notifications locales
    await _initializeLocalNotifications();

    // Configurer les handlers de messages
    _setupMessageHandlers();
  }

  // Demander les permissions de notification
  static Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notifications autorisées');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('Notifications provisoires autorisées');
    } else {
      print('Notifications refusées');
    }
  }

  // Initialiser les notifications locales
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Configurer les handlers de messages
  static void _setupMessageHandlers() {
    // Message reçu en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Message reçu en premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Notification tapée
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // Handler pour les messages en arrière-plan
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Message reçu en arrière-plan: ${message.messageId}');
  }

  // Handler pour les messages en premier plan
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Message reçu en premier plan: ${message.messageId}');
    
    // Afficher une notification locale
    await _showLocalNotification(message);
  }

  // Handler pour les notifications tapées
  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Notification tapée: ${message.messageId}');
    // Ici on pourrait naviguer vers le chat correspondant
  }

  // Afficher une notification locale
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      const androidDetails = AndroidNotificationDetails(
        'hire_me_messages',
        'Messages Swipe Em',
        channelDescription: 'Notifications pour les nouveaux messages',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        notification.title ?? 'Nouveau message',
        notification.body ?? 'Vous avez reçu un nouveau message',
        details,
        payload: data['matchId'] as String?,
      );
    }
  }

  // Handler pour les notifications locales tapées
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification locale tapée: ${response.payload}');
    // Ici on pourrait naviguer vers le chat correspondant
  }

  // Obtenir le token FCM
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  // S'abonner à un topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Abonné au topic: $topic');
    } catch (e) {
      print("Erreur lors de l'abonnement au topic: $e");
    }
  }

  // Se désabonner d'un topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Désabonné du topic: $topic');
    } catch (e) {
      print('Erreur lors du désabonnement du topic: $e');
    }
  }

  // Envoyer une notification de test
  static Future<void> sendTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'hire_me_test',
      'Test Notifications',
      channelDescription: 'Notifications de test',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      0,
      'Test Notification',
      'Ceci est une notification de test',
      details,
    );
  }

  // Créer une notification personnalisée pour un message
  static Future<void> showMessageNotification({
    required String title,
    required String body,
    required String matchId,
    String? senderName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'hire_me_messages',
      'Messages Swipe Em',
      channelDescription: 'Notifications pour les nouveaux messages',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      matchId.hashCode,
      title,
      body,
      details,
      payload: matchId,
    );
  }

  // Mettre à jour le token FCM de l'utilisateur
  static Future<void> updateUserToken() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final token = await getToken();
      if (token != null) {
        // Ici on pourrait sauvegarder le token dans Firestore
        // pour permettre l'envoi de notifications push
        print('Token FCM: $token');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du token: $e');
    }
  }
}
