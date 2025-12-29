import 'package:flutter/material.dart';
import 'package:hire_me/services/admin_service.dart';
import 'package:hire_me/models/user_model.dart';
import 'package:hire_me/features/admin/test_data_screen.dart';
import 'package:hire_me/features/admin/admin_post_management_screen.dart';
import 'package:hire_me/features/admin/admin_message_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  bool _isAdmin = false;
  UserModel? _currentUser;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final isAdmin = await AdminService.isCurrentUserAdmin();
      final currentUser = await AdminService.getCurrentUser();
      final stats = await AdminService.getAdminStats();

      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
          _currentUser = currentUser;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // TEMPORAIRE: Désactivé pour permettre l'accès aux données de test
    // if (!_isAdmin) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: const Text('Accès Refusé'),
    //       backgroundColor: Colors.red,
    //       foregroundColor: Colors.white,
    //     ),
    //     body: const Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Icon(
    //             Icons.block,
    //             size: 64,
    //             color: Colors.red,
    //           ),
    //           SizedBox(height: 16),
    //           Text(
    //             'Accès Administrateur Requis',
    //             style: TextStyle(
    //               fontSize: 24,
    //               fontWeight: FontWeight.bold,
    //               color: Colors.red,
    //             ),
    //           ),
    //           SizedBox(height: 8),
    //           Text(
    //             'Vous n\\'avez pas les droits administrateur pour accéder à cette page.',
    //             textAlign: TextAlign.center,
    //             style: TextStyle(fontSize: 16),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Admin'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAdminStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec informations utilisateur
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        _currentUser?.initials ?? 'A',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenue, ${_currentUser?.fullName ?? 'Admin'}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Administrateur de la plateforme',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.orange,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Statistiques
            Text(
              'Statistiques de la Plateforme',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  context,
                  'Utilisateurs',
                  _stats['users']?.toString() ?? '0',
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  'Posts',
                  _stats['posts']?.toString() ?? '0',
                  Icons.article,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  'Messages',
                  _stats['messages']?.toString() ?? '0',
                  Icons.message,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  'Matches',
                  _stats['matches']?.toString() ?? '0',
                  Icons.favorite,
                  Colors.pink,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Actions rapides
            Text(
              'Actions Rapides',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildActionCard(
                  context,
                  'Gérer les Posts',
                  'Créer, modifier et supprimer des posts',
                  Icons.article,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const AdminPostManagementScreen(),
                    ),
                  ),
                ),
                _buildActionCard(
                  context,
                  'Gérer les Messages',
                  'Créer des messages entre utilisateurs',
                  Icons.message,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const AdminMessageManagementScreen(),
                    ),
                  ),
                ),
                _buildActionCard(
                  context,
                  'Données de Test',
                  'Créer et gérer les données de test',
                  Icons.science,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const TestDataScreen(),
                    ),
                  ),
                ),
                _buildActionCard(
                  context,
                  'Utilisateurs',
                  'Voir et gérer les utilisateurs',
                  Icons.people,
                  Colors.orange,
                  () => _showUsersDialog(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Informations système
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations Système',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('• Accès administrateur activé'),
                    Text('• Gestion des posts et messages'),
                    Text('• Création de données de test'),
                    Text('• Surveillance des statistiques'),
                    const SizedBox(height: 8),
                    Text(
                      'Dernière mise à jour: ${DateTime.now().toString().split('.')[0]}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUsersDialog() async {
    try {
      final users = await AdminService.getAllUsers();
      
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Utilisateurs de la Plateforme'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.initials),
                    ),
                    title: Text(user.fullName),
                    subtitle: Text(user.email),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(
                              user.isRecruiter ? 'R' : 'C',
                              style: const TextStyle(fontSize: 10),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
