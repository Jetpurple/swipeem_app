import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/providers/user_provider.dart';

class RecruiterJobOffersScreen extends ConsumerWidget {
  const RecruiterJobOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserIdProvider);
    
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Veuillez vous connecter')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Logo1(height: 100, fit: BoxFit.contain),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/create-post'),
            tooltip: 'Publier une nouvelle offre',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('authorUid', isEqualTo: uid)
            .where('authorIsRecruiter', isEqualTo: true)
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur lors du chargement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final jobOffers = snapshot.data?.docs ?? [];

          if (jobOffers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aucune offre publiée',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Commencez par publier votre première offre d'emploi",
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/create-post'),
                    icon: const Icon(Icons.add),
                    label: const Text('Publier une offre'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobOffers.length,
            itemBuilder: (context, index) {
              final job = jobOffers[index];
              final data = job.data()! as Map<String, dynamic>;
              
              // Adapter les données pour l'affichage
              final title = (data['title'] as String?) ?? 'Titre non défini';
              final content = (data['content'] as String?) ?? 'Description non définie';
              final domain = (data['domain'] as String?) ?? 'Domaine non spécifié';
              final softSkills = List<String>.from((data['softSkills'] as List?) ?? []);
              final hardSkills = List<String>.from((data['hardSkills'] as List?) ?? []);
              final isActive = (data['isActive'] as bool?) ?? true;
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              
              return _JobOfferCard(
                jobId: job.id,
                title: title,
                company: domain, // Utiliser le domaine comme "entreprise"
                location: '', // Pas de localisation dans posts
                salary: '', // Pas de salaire dans posts
                type: '', // Pas de type dans posts
                experience: '', // Pas d'expérience dans posts
                description: content,
                requirements: hardSkills, // Utiliser les hard skills comme exigences
                benefits: softSkills, // Utiliser les soft skills comme avantages
                isActive: isActive,
                postedAt: createdAt,
                onTap: () => _showJobDetails(context, data),
                onEdit: () => _editJob(context, job.id, data),
                onDelete: () => _deleteJob(context, job.id),
                onToggleStatus: () => _toggleJobStatus(context, job.id, isActive),
              );
            },
          );
        },
      ),
    );
  }

  void _showJobDetails(BuildContext context, Map<String, dynamic> job) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Titre
                Text(
                  (job['title'] as String?) ?? 'Titre non défini',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Domaine
                if ((job['domain'] as String?) != null)
                  Text(
                    job['domain'] as String,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Informations clés
                if ((job['domain'] as String?) != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.category,
                        label: job['domain'] as String,
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                // Compétences
                if ((job['hardSkills'] as List?)?.isNotEmpty ?? false) ...[
                  Text(
                    'Compétences techniques',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: ((job['hardSkills'] as List).take(5).map((skill) => Chip(
                      label: Text(skill.toString()),
                      labelStyle: const TextStyle(fontSize: 12),
                    ))).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                if ((job['softSkills'] as List?)?.isNotEmpty ?? false) ...[
                  Text(
                    'Compétences comportementales',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: ((job['softSkills'] as List).take(5).map((skill) => Chip(
                      label: Text(skill.toString()),
                      labelStyle: const TextStyle(fontSize: 12),
                    ))).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 24),
                
                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (job['content'] as String?) ?? 'Aucune description',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editJob(BuildContext context, String jobId, Map<String, dynamic> job) {
    // TODO: Implémenter l'édition d'offre
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Édition d'offre - À implémenter")),
    );
  }

  void _deleteJob(BuildContext context, String jobId) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer l'offre"),
        content: const Text("Êtes-vous sûr de vouloir supprimer cette offre d'emploi ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(jobId)
                    .delete();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Offre supprimée')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _toggleJobStatus(BuildContext context, String jobId, bool currentStatus) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(jobId)
        .update({'isActive': !currentStatus});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(currentStatus ? 'Offre désactivée' : 'Offre activée'),
      ),
    );
  }
}

class _JobOfferCard extends StatelessWidget {

  const _JobOfferCard({
    required this.jobId,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.experience,
    required this.description,
    required this.requirements,
    required this.benefits,
    required this.isActive,
    required this.onTap, required this.onEdit, required this.onDelete, required this.onToggleStatus, this.postedAt,
  });
  final String jobId;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String experience;
  final String description;
  final List<String> requirements;
  final List<String> benefits;
  final bool isActive;
  final DateTime? postedAt;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          company,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isActive ? 'Actif' : 'Inactif',
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (company.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        company,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              if (company.isNotEmpty) const SizedBox(height: 8),
              const SizedBox(height: 12),
              
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (postedAt != null)
                    Text(
                      'Publié le ${_formatDate(postedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isActive ? Icons.pause : Icons.play_arrow,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: onToggleStatus,
                        tooltip: isActive ? 'Désactiver' : 'Activer',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: onEdit,
                        tooltip: 'Modifier',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Supprimer',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {

  const _InfoChip({
    required this.icon,
    required this.label,
  });
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}
