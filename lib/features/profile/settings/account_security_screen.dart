import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class AccountSecurityScreen extends ConsumerWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // Icône de sécurité en haut
            Container(
              padding: EdgeInsets.only(
                top: isTablet ? 30 : 20, 
                bottom: isTablet ? 40 : 30
              ),
              child: Icon(
                Icons.security,
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
                  // Section Profil
                  _buildMenuSection(context, 'PROFIL', [
                    _buildMenuItem(context,
                      'Informations personnelles',
                      'Modifier nom, email, téléphone',
                      Icons.person,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Photo de profil',
                      'Changer votre photo',
                      Icons.camera_alt,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      "Vérification d'identité",
                      'Vérifier votre identité',
                      Icons.verified_user,
                      () => _showComingSoon(context),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Sécurité
                  _buildMenuSection(context, 'SÉCURITÉ', [
                    _buildMenuItem(context,
                      'Mot de passe',
                      'Changer votre mot de passe',
                      Icons.lock,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Authentification à deux facteurs',
                      'Activer 2FA pour plus de sécurité',
                      Icons.security,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Sessions actives',
                      'Gérer vos connexions',
                      Icons.devices,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Historique de connexion',
                      "Voir l'historique des connexions",
                      Icons.history,
                      () => _showComingSoon(context),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Compte
                  _buildMenuSection(context, 'COMPTE', [
                    _buildMenuItem(context,
                      'Type de compte',
                      'Candidat ou Recruteur',
                      Icons.account_circle,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Statut du compte',
                      'Actif, Suspendu, etc.',
                      Icons.info,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Supprimer le compte',
                      'Supprimer définitivement',
                      Icons.delete_forever,
                      () => _showDeleteAccountDialog(context),
                      isDestructive: true,
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

  Widget _buildMenuItem(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
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
              color: isDestructive ? Colors.red[300] : Colors.white,
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
                      color: isDestructive ? Colors.red[300] : Colors.white,
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDestructive ? Colors.red[200] : Colors.white70,
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDestructive ? Colors.red[300] : Colors.white,
              size: isTablet ? 28 : 24,
            ),
          ],
        ),
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

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer le compte'),
          content: const Text(
            'Cette action est irréversible. Toutes vos données seront définitivement supprimées.',
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
