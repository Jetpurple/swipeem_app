import 'package:flutter/material.dart';
import 'package:hire_me/services/test_data_service.dart';
import 'package:hire_me/services/admin_test_data_service.dart';
import 'package:hire_me/services/seed_data_service.dart';
import 'package:hire_me/features/admin/admin_dashboard_screen.dart';

class TestDataScreen extends StatefulWidget {
  const TestDataScreen({super.key});

  @override
  State<TestDataScreen> createState() => _TestDataScreenState();
}

class _TestDataScreenState extends State<TestDataScreen> {
  bool _isLoading = false;

  Future<void> _createTestData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await TestDataService.createAllTestData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données de test créées avec succès !'),
            backgroundColor: Colors.green,
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createAdminTestData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AdminTestDataService.createAllAdminTestData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données de test avec admin créées avec succès ! Vérifiez la console pour les identifiants.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
        
        // Afficher les identifiants dans une boîte de dialogue
        _showLoginCredentials();
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createLargeDataSet() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // D'abord s'assurer que les données de base existent
      if (!await SeedDataService.hasData()) {
        await SeedDataService.seedAllData();
      }
      
      // Ensuite générer le grand jeu de données
      await SeedDataService.seedLargeDataSet();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('100 candidats et 10 recruteurs générés avec succès !'),
            backgroundColor: Colors.green,
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLoginCredentials() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔐 Identifiants de Connexion'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mot de passe pour tous les comptes: password123', 
                   style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('👑 ADMIN:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('admin@hireme.com'),
              SizedBox(height: 8),
              Text('👥 CANDIDATS:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('marie.dupont@email.com'),
              Text('pierre.martin@email.com'),
              Text('sophie.bernard@email.com'),
              Text('thomas.leroy@email.com'),
              Text('laura.simon@email.com'),
              SizedBox(height: 8),
              Text('🏢 RECRUTEURS:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('jean.recruteur@techcorp.com'),
              Text('sarah.hr@startup.io'),
            ],
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

  Future<void> _createMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await TestDataService.createTestMessages();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Messages de test créés !'),
            backgroundColor: Colors.green,
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createJobOffers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await TestDataService.createTestJobOffers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Annonces d'emploi créées !"),
            backgroundColor: Colors.green,
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await TestDataService.createTestPosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Posts créés !'),
            backgroundColor: Colors.green,
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanTestData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await TestDataService.cleanTestData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données de test supprimées !'),
            backgroundColor: Colors.orange,
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Données de Test'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestion des Données de Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Créez des messages, annonces d'emploi et posts de test pour tester votre application.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Bouton principal - Créer toutes les données
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createTestData,
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_circle),
              label: Text(_isLoading ? 'Création en cours...' : 'Créer toutes les données'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 8),
            
            // Bouton pour créer les données avec admin
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createAdminTestData,
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.admin_panel_settings),
              label: Text(_isLoading ? 'Création en cours...' : 'Créer données avec Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 8),

            // Bouton pour générer 100 candidats
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createLargeDataSet,
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.groups),
              label: Text(_isLoading ? 'Génération en cours...' : 'Générer 100 candidats'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            // Boutons individuels
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createMessages,
                    icon: const Icon(Icons.message),
                    label: const Text('Messages'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createJobOffers,
                    icon: const Icon(Icons.work),
                    label: const Text('Emplois'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createPosts,
                    icon: const Icon(Icons.article),
                    label: const Text('Posts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _cleanTestData,
                    icon: const Icon(Icons.delete),
                    label: const Text('Nettoyer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Bouton pour accéder au tableau de bord admin
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const AdminDashboardScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.dashboard),
              label: const Text('Tableau de Bord Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Informations sur les données
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Données créées :',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('• 20 messages de test variés'),
                    const Text("• 10 annonces d'emploi réalistes"),
                    const Text('• 5 posts/annonces'),
                    const Text('• Matches entre utilisateurs'),
                    const SizedBox(height: 8),
                    Text(
                      "Note: Assurez-vous d'avoir des utilisateurs dans votre base de données avant de créer les données de test.",
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
}
