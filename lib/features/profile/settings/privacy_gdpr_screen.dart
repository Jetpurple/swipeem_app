import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class PrivacyGdprScreen extends ConsumerStatefulWidget {
  const PrivacyGdprScreen({super.key});

  @override
  ConsumerState<PrivacyGdprScreen> createState() => _PrivacyGdprScreenState();
}

class _PrivacyGdprScreenState extends ConsumerState<PrivacyGdprScreen> {
  // États des paramètres de confidentialité
  bool _dataCollection = true;
  bool _analytics = true;
  bool _marketing = false;
  bool _personalizedAds = false;
  bool _locationTracking = false;
  bool _cameraAccess = true;
  bool _microphoneAccess = false;
  bool _contactsAccess = false;
  bool _calendarAccess = false;
  String _dataRetention = '2 ans';
  bool _dataPortability = true;
  bool _rightToBeForgotten = true;

  final List<String> _dataRetentionOptions = [
    '6 mois',
    '1 an',
    '2 ans',
    '5 ans',
    'Indéfiniment',
  ];

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
            // Icône de confidentialité en haut
            Container(
              padding: EdgeInsets.only(
                top: isTablet ? 30 : 20, 
                bottom: isTablet ? 40 : 30
              ),
              child: Icon(
                Icons.privacy_tip,
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
                  // Section Collecte de données
                  _buildMenuSection(context, 'COLLECTE DE DONNÉES', [
                    _buildPrivacySwitch(
                      context,
                      'Collecte de données',
                      'Autoriser la collecte de données personnelles',
                      Icons.data_usage,
                      _dataCollection,
                      (value) => setState(() => _dataCollection = value),
                    ),
                    _buildPrivacySwitch(
                      context,
                      'Analytiques',
                      "Partager des données pour améliorer l'app",
                      Icons.analytics,
                      _analytics,
                      (value) => setState(() => _analytics = value),
                    ),
                    _buildPrivacySwitch(
                      context,
                      'Marketing',
                      'Recevoir des communications marketing',
                      Icons.campaign,
                      _marketing,
                      (value) => setState(() => _marketing = value),
                    ),
                    _buildPrivacySwitch(
                      context,
                      'Publicités personnalisées',
                      'Recevoir des publicités adaptées à vos intérêts',
                      Icons.ads_click,
                      _personalizedAds,
                      (value) => setState(() => _personalizedAds = value),
                    ),
                    _buildPrivacySwitch(
                      context,
                      'Géolocalisation',
                      'Partager votre position',
                      Icons.location_on,
                      _locationTracking,
                      (value) => setState(() => _locationTracking = value),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Permissions
                  _buildMenuSection(context, 'PERMISSIONS', [
                    _buildPrivacySwitch(
                      context,
                      'Caméra',
                      'Accès à la caméra pour les photos de profil',
                      Icons.camera_alt,
                      _cameraAccess,
                      (value) => setState(() => _cameraAccess = value),
                    ),
                    _buildPrivacySwitch(
                      context,
                      'Microphone',
                      'Accès au microphone pour les appels',
                      Icons.mic,
                      _microphoneAccess,
                      (value) => setState(() => _microphoneAccess = value),
                    ),
                    _buildPrivacySwitch(
                      context,
                      'Contacts',
                      'Accès aux contacts pour les invitations',
                      Icons.contacts,
                      _contactsAccess,
                      (value) => setState(() => _contactsAccess = value),
                    ),
                    _buildPrivacySwitch(
                      context,
                      'Calendrier',
                      'Accès au calendrier pour planifier des entretiens',
                      Icons.calendar_today,
                      _calendarAccess,
                      (value) => setState(() => _calendarAccess = value),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section RGPD
                  _buildMenuSection(context, 'DROITS RGPD', [
                    _buildMenuItem(context,
                      'Conservation des données',
                      _dataRetention,
                      Icons.schedule,
                      () => _showDataRetentionSelector(context),
                    ),
                    _buildPrivacySwitch(
                      context,
                      'Portabilité des données',
                      'Exporter vos données personnelles',
                      Icons.download,
                      _dataPortability,
                      (value) => setState(() => _dataPortability = value),
                    ),
                    _buildPrivacySwitch(
                      context,
                      "Droit à l'oubli",
                      'Demander la suppression de vos données',
                      Icons.delete_forever,
                      _rightToBeForgotten,
                      (value) => setState(() => _rightToBeForgotten = value),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Gestion des données
                  _buildMenuSection(context, 'GESTION DES DONNÉES', [
                    _buildMenuItem(context,
                      'Télécharger mes données',
                      'Obtenir une copie de vos données',
                      Icons.download,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Supprimer mes données',
                      'Supprimer définitivement vos données',
                      Icons.delete,
                      () => _showDeleteDataDialog(context),
                    ),
                    _buildMenuItem(context,
                      'Historique des données',
                      "Voir l'historique de vos données",
                      Icons.history,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Cookies et tracking',
                      'Gérer les cookies et le tracking',
                      Icons.cookie,
                      () => _showComingSoon(context),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Politiques
                  _buildMenuSection(context, 'POLITIQUES', [
                    _buildMenuItem(context,
                      'Politique de confidentialité',
                      'Lire notre politique de confidentialité',
                      Icons.description,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      "Conditions d'utilisation",
                      "Lire nos conditions d'utilisation",
                      Icons.article,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Politique des cookies',
                      'En savoir plus sur les cookies',
                      Icons.cookie,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Contact DPO',
                      'Contacter le délégué à la protection des données',
                      Icons.contact_mail,
                      () => _showComingSoon(context),
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

  Widget _buildPrivacySwitch(
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
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
            SizedBox(width: isTablet ? 8 : 6),
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

  void _showDataRetentionSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildSelectorBottomSheet(
        context,
        'Conservation des données',
        _dataRetentionOptions,
        _dataRetention,
        (value) => setState(() => _dataRetention = value),
      ),
    );
  }

  Widget _buildSelectorBottomSheet(
    BuildContext context,
    String title,
    List<String> options,
    String currentValue,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...options.map((option) => ListTile(
            title: Text(option),
            trailing: option == currentValue ? const Icon(Icons.check, color: Color(0xFF5271FF)) : null,
            onTap: () {
              onChanged(option);
              Navigator.pop(context);
            },
          )),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir !'),
        backgroundColor: Color(0xFF5271FF),
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer mes données'),
          content: const Text(
            'Cette action supprimera définitivement toutes vos données personnelles. Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showComingSoon(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
