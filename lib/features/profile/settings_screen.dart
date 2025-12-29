import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';
import 'package:hire_me/providers/theme_provider.dart';
import 'package:hire_me/services/auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
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
            // Icône d'engrenage en haut
            Container(
              padding: EdgeInsets.only(
                top: isTablet ? 30 : 20, 
                bottom: isTablet ? 40 : 30
              ),
              child: Icon(
                Icons.settings,
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
                  // Première section
                  _buildMenuSection(context, [
                    _buildMenuItem(context,
                      'COMPTE & SÉCURITÉ',
                      () => context.go('/settings/account-security'),
                    ),
                    _buildMenuItem(context,
                      'ABONNEMENT & FACTURATION',
                      () => context.go('/settings/subscription-billing'),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Deuxième section
                  _buildMenuSection(context, [
                    _buildMenuItem(context,
                      'NOTIFICATIONS',
                      () => context.go('/settings/notifications'),
                    ),
                    _buildMenuItem(context,
                      'LANGUE & RÉGION',
                      () => context.go('/settings/language-region'),
                    ),
                    _buildMenuItem(context,
                      'INTÉGRATION',
                      () => context.go('/settings/integration'),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Troisième section
                  _buildMenuSection(context, [
                    _buildThemeMenuItem(),
                    _buildMenuItem(context,
                      'APPARENCE & ACCESSIBILITÉ',
                      () => context.go('/settings/appearance-accessibility'),
                    ),
                    _buildMenuItem(context,
                      'PROFIL & VISIBILITÉ',
                      () => context.go('/edit-profile'),
                    ),
                    _buildMenuItem(context,
                      'CONFIDENTIALITÉ & RGPD',
                      () => context.go('/settings/privacy-gdpr'),
                    ),
                  ]),
                  
                  const SizedBox(height: 40),
                  
                  // Logo COSS
                  _buildCossLogo(context),
                  
                  const SizedBox(height: 30),
                  
                  // Boutons d'action
                  _buildActionButtons(context),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, List<Widget> items) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
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
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, VoidCallback onTap) {
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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

  Widget _buildCossLogo(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Column(
      children: [
        SizedBox(height: isTablet ? 8 : 4),
        Text(
          'Certificate of Soft Skills',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: Colors.black,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        // Stylized L shape
        Container(
          width: isTablet ? 50 : 40,
          height: isTablet ? 50 : 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF5271FF), 
              width: isTablet ? 4 : 3
            ),
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
          ),
          child: Center(
            child: Text(
              'L',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5271FF),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Column(
      children: [
        // Bouton Se déconnecter
        SizedBox(
          width: double.infinity,
          height: isTablet ? 60 : 50,
          child: ElevatedButton(
            onPressed: () => _showLogoutDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
            ),
            child: Text(
              'SE DÉCONNECTER',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        SizedBox(height: isTablet ? 16 : 12),
        
        // Bouton Supprimer mon compte
        SizedBox(
          width: double.infinity,
          height: isTablet ? 60 : 50,
          child: ElevatedButton(
            onPressed: () => _showDeleteAccountDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
            ),
            child: Text(
              'SUPPRIMER MON COMPTE',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
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

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Se déconnecter'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await AuthService.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de la déconnexion: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer mon compte'),
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

  Widget _buildThemeMenuItem() {
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(themeNotifierProvider);
        final themeNotifier = ref.read(themeNotifierProvider.notifier);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: ListTile(
            leading: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              themeMode == ThemeMode.dark ? 'Mode sombre' : 'Mode clair',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) => themeNotifier.toggleTheme(),
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
            onTap: themeNotifier.toggleTheme,
          ),
        );
      },
    );
  }
}
