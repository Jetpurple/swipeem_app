import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class IntegrationScreen extends ConsumerStatefulWidget {
  const IntegrationScreen({super.key});

  @override
  ConsumerState<IntegrationScreen> createState() => _IntegrationScreenState();
}

class _IntegrationScreenState extends ConsumerState<IntegrationScreen> {
  // États des intégrations
  bool _linkedinConnected = false;
  bool _googleConnected = false;
  bool _calendarConnected = false;
  bool _slackConnected = false;
  bool _githubConnected = false;
  bool _dropboxConnected = false;
  bool _onedriveConnected = false;
  bool _zoomConnected = false;
  bool _teamsConnected = false;

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
            // Icône d'intégration en haut
            Container(
              padding: EdgeInsets.only(
                top: isTablet ? 30 : 20, 
                bottom: isTablet ? 40 : 30
              ),
              child: Icon(
                Icons.integration_instructions,
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
                  // Section Réseaux sociaux
                  _buildMenuSection(context, 'RÉSEAUX SOCIAUX', [
                    _buildIntegrationItem(
                      context,
                      'LinkedIn',
                      'Connecter votre profil LinkedIn',
                      Icons.work,
                      _linkedinConnected,
                      () => _toggleIntegration('linkedin'),
                    ),
                    _buildIntegrationItem(
                      context,
                      'Google',
                      'Connecter votre compte Google',
                      Icons.account_circle,
                      _googleConnected,
                      () => _toggleIntegration('google'),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Productivité
                  _buildMenuSection(context, 'PRODUCTIVITÉ', [
                    _buildIntegrationItem(
                      context,
                      'Google Calendar',
                      'Synchroniser votre calendrier',
                      Icons.calendar_today,
                      _calendarConnected,
                      () => _toggleIntegration('calendar'),
                    ),
                    _buildIntegrationItem(
                      context,
                      'Slack',
                      'Intégrer avec Slack',
                      Icons.chat,
                      _slackConnected,
                      () => _toggleIntegration('slack'),
                    ),
                    _buildIntegrationItem(
                      context,
                      'Microsoft Teams',
                      'Connecter avec Teams',
                      Icons.groups,
                      _teamsConnected,
                      () => _toggleIntegration('teams'),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Développement
                  _buildMenuSection(context, 'DÉVELOPPEMENT', [
                    _buildIntegrationItem(
                      context,
                      'GitHub',
                      'Connecter votre profil GitHub',
                      Icons.code,
                      _githubConnected,
                      () => _toggleIntegration('github'),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Stockage
                  _buildMenuSection(context, 'STOCKAGE CLOUD', [
                    _buildIntegrationItem(
                      context,
                      'Dropbox',
                      'Synchroniser avec Dropbox',
                      Icons.cloud,
                      _dropboxConnected,
                      () => _toggleIntegration('dropbox'),
                    ),
                    _buildIntegrationItem(
                      context,
                      'OneDrive',
                      'Connecter OneDrive',
                      Icons.cloud_done,
                      _onedriveConnected,
                      () => _toggleIntegration('onedrive'),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Communication
                  _buildMenuSection(context, 'COMMUNICATION', [
                    _buildIntegrationItem(
                      context,
                      'Zoom',
                      'Intégrer avec Zoom',
                      Icons.videocam,
                      _zoomConnected,
                      () => _toggleIntegration('zoom'),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Gestion
                  _buildMenuSection(context, 'GESTION', [
                    _buildMenuItem(context,
                      'Voir toutes les intégrations',
                      'Gérer toutes vos connexions',
                      Icons.settings,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Autorisations',
                      'Gérer les permissions des applications',
                      Icons.security,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Déconnecter tout',
                      'Déconnecter toutes les intégrations',
                      Icons.logout,
                      () => _showDisconnectAllDialog(context),
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

  Widget _buildIntegrationItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isConnected,
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
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.white30,
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
              child: Icon(
                icon,
                color: isConnected ? Colors.white : Colors.white70,
                size: isTablet ? 28 : 24,
              ),
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
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 8,
                vertical: isTablet ? 6 : 4,
              ),
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.white30,
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
              child: Text(
                isConnected ? 'CONNECTÉ' : 'CONNECTER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 12 : 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

  void _toggleIntegration(String integration) {
    setState(() {
      switch (integration) {
        case 'linkedin':
          _linkedinConnected = !_linkedinConnected;
        case 'google':
          _googleConnected = !_googleConnected;
        case 'calendar':
          _calendarConnected = !_calendarConnected;
        case 'slack':
          _slackConnected = !_slackConnected;
        case 'github':
          _githubConnected = !_githubConnected;
        case 'dropbox':
          _dropboxConnected = !_dropboxConnected;
        case 'onedrive':
          _onedriveConnected = !_onedriveConnected;
        case 'zoom':
          _zoomConnected = !_zoomConnected;
        case 'teams':
          _teamsConnected = !_teamsConnected;
      }
    });
    
    final action = _getIntegrationState(integration) ? 'connecté' : 'déconnecté';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getIntegrationName(integration)} $action'),
        backgroundColor: const Color(0xFF5271FF),
      ),
    );
  }

  bool _getIntegrationState(String integration) {
    switch (integration) {
      case 'linkedin': return _linkedinConnected;
      case 'google': return _googleConnected;
      case 'calendar': return _calendarConnected;
      case 'slack': return _slackConnected;
      case 'github': return _githubConnected;
      case 'dropbox': return _dropboxConnected;
      case 'onedrive': return _onedriveConnected;
      case 'zoom': return _zoomConnected;
      case 'teams': return _teamsConnected;
      default: return false;
    }
  }

  String _getIntegrationName(String integration) {
    switch (integration) {
      case 'linkedin': return 'LinkedIn';
      case 'google': return 'Google';
      case 'calendar': return 'Google Calendar';
      case 'slack': return 'Slack';
      case 'github': return 'GitHub';
      case 'dropbox': return 'Dropbox';
      case 'onedrive': return 'OneDrive';
      case 'zoom': return 'Zoom';
      case 'teams': return 'Microsoft Teams';
      default: return 'Intégration';
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

  void _showDisconnectAllDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnecter toutes les intégrations'),
          content: const Text(
            'Êtes-vous sûr de vouloir déconnecter toutes vos intégrations ? Vous devrez les reconnecter pour continuer à les utiliser.',
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
                  _linkedinConnected = false;
                  _googleConnected = false;
                  _calendarConnected = false;
                  _slackConnected = false;
                  _githubConnected = false;
                  _dropboxConnected = false;
                  _onedriveConnected = false;
                  _zoomConnected = false;
                  _teamsConnected = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toutes les intégrations ont été déconnectées'),
                    backgroundColor: Color(0xFF5271FF),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Déconnecter tout'),
            ),
          ],
        );
      },
    );
  }
}
