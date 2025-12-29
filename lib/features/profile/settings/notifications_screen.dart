import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // États des notifications
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _matchNotifications = true;
  bool _messageNotifications = true;
  bool _jobNotifications = true;
  bool _marketingNotifications = false;
  bool _securityNotifications = true;
  bool _weeklyDigest = true;
  bool _quietHours = false;
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '08:00';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: Logo1(
          height: isTablet ? 120 : 100, 
          fit: BoxFit.contain
        ),
        centerTitle: true,
        actions: const [
          ThemeToggleIconButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Icône de notifications en haut
            Container(
              padding: EdgeInsets.only(
                top: isTablet ? 30 : 20, 
                bottom: isTablet ? 40 : 30
              ),
              child: Icon(
                Icons.notifications,
                size: isTablet ? 80 : 60,
                color: const Color(0xFF5271FF),
              ),
            ),
            
            // Sections de menu
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 40 : 20,
              ),
              child: Column(
                children: [
                  // Section Types de notifications
                  _buildMenuSection(context, 'TYPES DE NOTIFICATIONS', [
                    _buildNotificationSwitch(
                      context,
                      'Notifications push',
                      'Recevoir des notifications sur votre appareil',
                      Icons.phone_android,
                      _pushNotifications,
                      (value) => setState(() => _pushNotifications = value),
                    ),
                    _buildNotificationSwitch(
                      context,
                      'Notifications email',
                      'Recevoir des notifications par email',
                      Icons.email,
                      _emailNotifications,
                      (value) => setState(() => _emailNotifications = value),
                    ),
                    _buildNotificationSwitch(
                      context,
                      'Notifications SMS',
                      'Recevoir des notifications par SMS',
                      Icons.sms,
                      _smsNotifications,
                      (value) => setState(() => _smsNotifications = value),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Contenu des notifications
                  _buildMenuSection(context, 'CONTENU DES NOTIFICATIONS', [
                    _buildNotificationSwitch(
                      context,
                      'Nouveaux matchs',
                      'Être notifié des nouveaux matchs',
                      Icons.favorite,
                      _matchNotifications,
                      (value) => setState(() => _matchNotifications = value),
                    ),
                    _buildNotificationSwitch(
                      context,
                      'Nouveaux messages',
                      'Être notifié des nouveaux messages',
                      Icons.message,
                      _messageNotifications,
                      (value) => setState(() => _messageNotifications = value),
                    ),
                    _buildNotificationSwitch(
                      context,
                      "Nouvelles offres d'emploi",
                      'Être notifié des nouvelles offres',
                      Icons.work,
                      _jobNotifications,
                      (value) => setState(() => _jobNotifications = value),
                    ),
                    _buildNotificationSwitch(
                      context,
                      'Marketing & Promotions',
                      'Recevoir des offres promotionnelles',
                      Icons.local_offer,
                      _marketingNotifications,
                      (value) => setState(() => _marketingNotifications = value),
                    ),
                    _buildNotificationSwitch(
                      context,
                      'Sécurité du compte',
                      'Notifications importantes de sécurité',
                      Icons.security,
                      _securityNotifications,
                      (value) => setState(() => _securityNotifications = value),
                    ),
                    _buildNotificationSwitch(
                      context,
                      'Résumé hebdomadaire',
                      'Recevoir un résumé de votre activité',
                      Icons.calendar_today,
                      _weeklyDigest,
                      (value) => setState(() => _weeklyDigest = value),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Heures silencieuses
                  _buildMenuSection(context, 'HEURES SILENCIEUSES', [
                    _buildNotificationSwitch(
                      context,
                      'Activer les heures silencieuses',
                      'Désactiver les notifications pendant certaines heures',
                      Icons.bedtime,
                      _quietHours,
                      (value) => setState(() => _quietHours = value),
                    ),
                    if (_quietHours) ...[
                      _buildTimeSelector(
                        context,
                        'Début',
                        _quietHoursStart,
                        (value) => setState(() => _quietHoursStart = value),
                      ),
                      _buildTimeSelector(
                        context,
                        'Fin',
                        _quietHoursEnd,
                        (value) => setState(() => _quietHoursEnd = value),
                      ),
                    ],
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Gestion
                  _buildMenuSection(context, 'GESTION', [
                    _buildMenuItem(context,
                      'Tester les notifications',
                      'Envoyer une notification de test',
                      Icons.send,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Historique des notifications',
                      "Voir l'historique des notifications",
                      Icons.history,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Réinitialiser les préférences',
                      'Remettre les paramètres par défaut',
                      Icons.restore,
                      () => _showResetDialog(context),
                    ),
                  ]),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isTablet ? 8 : 4,
            bottom: isTablet ? 12 : 8,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF5271FF),
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
          child: Column(
            children: items
                .expand((item) => [
                      item,
                      if (item != items.last)
                        const Divider(
                          color: Colors.white,
                          height: 1,
                          thickness: 0.5,
                        ),
                    ])
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSwitch(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20, 
        vertical: isTablet ? 20 : 16
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isTablet ? 28 : 24,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white70,
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white30,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    String label,
    String currentTime,
    ValueChanged<String> onChanged,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return InkWell(
      onTap: () => _selectTime(context, currentTime, onChanged),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20, 
          vertical: isTablet ? 20 : 16
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Text(
                '$label: $currentTime',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData icon,
    VoidCallback onTap,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20, 
          vertical: isTablet ? 20 : 16
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, String currentTime, ValueChanged<String> onChanged) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(currentTime.split(':')[0]),
        minute: int.parse(currentTime.split(':')[1]),
      ),
    );
    
    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onChanged(formattedTime);
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir !'),
        backgroundColor: Color(0xFF5271FF),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Réinitialiser les préférences'),
          content: const Text(
            'Êtes-vous sûr de vouloir remettre les paramètres de notifications par défaut ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _pushNotifications = true;
                  _emailNotifications = true;
                  _smsNotifications = false;
                  _matchNotifications = true;
                  _messageNotifications = true;
                  _jobNotifications = true;
                  _marketingNotifications = false;
                  _securityNotifications = true;
                  _weeklyDigest = true;
                  _quietHours = false;
                  _quietHoursStart = '22:00';
                  _quietHoursEnd = '08:00';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Préférences réinitialisées'),
                    backgroundColor: Color(0xFF5271FF),
                  ),
                );
              },
              child: const Text('Réinitialiser'),
            ),
          ],
        );
      },
    );
  }
}
