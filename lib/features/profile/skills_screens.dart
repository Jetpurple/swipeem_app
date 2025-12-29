import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/services/firebase_user_service.dart';
import 'package:hire_me/services/storage_service.dart';

class SoftSkillsScreen extends ConsumerWidget {
  const SoftSkillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Veuillez vous connecter')), 
          );
        }

        final uid = user.uid;
        final photoUrl = user.profileImageUrl;
        final raw = user.softSkills;
        final items = raw.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        
        // Si pas de compétences, afficher un message et un bouton pour initialiser
        if (items.isEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              title: const Logo1(height: 100, fit: BoxFit.contain),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.psychology,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune soft skill définie',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Initialisez vos compétences pour commencer',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseUserService.initializeDefaultSkills(uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Compétences initialisées !')),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Initialiser mes compétences'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return _SkillsList(
          title: 'MES SOFT SKILLS',
          items: items,
          photoUrl: photoUrl,
          onSave: () async {
            await FirebaseUserService.updateSoftSkills(uid, items);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Soft skills enregistrés')),
              );
            }
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }
}

class HardSkillsScreen extends ConsumerWidget {
  const HardSkillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Veuillez vous connecter')), 
          );
        }

        final uid = user.uid;
        final photoUrl = user.profileImageUrl;
        final raw = user.hardSkills;
        final items = raw.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        
        // Si pas de compétences, afficher un message et un bouton pour initialiser
        if (items.isEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              title: const Logo1(height: 100, fit: BoxFit.contain),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.code,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune hard skill définie',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Initialisez vos compétences pour commencer',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseUserService.initializeDefaultSkills(uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Compétences initialisées !')),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Initialiser mes compétences'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return _SkillsList(
          title: 'MES HARD SKILLS',
          items: items,
          photoUrl: photoUrl,
          onSave: () async {
            await FirebaseUserService.updateHardSkills(uid, items);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hard skills enregistrés')),
              );
            }
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }
}

class _SkillsList extends StatelessWidget {
  const _SkillsList({required this.title, required this.items, this.photoUrl, this.onSave});
  final String title;
  final List<Map<String, dynamic>> items;
  final String? photoUrl;
  final Future<void> Function()? onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        title: const Logo1(height: 100, fit: BoxFit.contain),
        centerTitle: true,
        actions: <Widget>[
          if (onSave != null)
            IconButton(
              icon: Icon(Icons.save, color: Theme.of(context).colorScheme.primary),
              onPressed: onSave,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // Profile avatar
          Center(
            child: CircleAvatar(
              key: ValueKey(photoUrl ?? 'no-photo'),
              radius: 44,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Builder(
                builder: (_) {
                  final imageProvider = StorageService.resolveProfileImage(photoUrl);
                  return CircleAvatar(
                    radius: 42,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    backgroundImage: imageProvider,
                    child: imageProvider == null
                        ? Icon(
                            Icons.person,
                            size: 44,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Skills list
          ..._buildSkillsByCategory(context, items),
        ],
      ),
    );
  }

  List<Widget> _buildSkillsByCategory(BuildContext context, List<Map<String, dynamic>> items) {
    final categories = <String, List<Map<String, dynamic>>>{};

    for (final item in items) {
      final category = item['category'] as String? ?? 'Compétences';
      categories.putIfAbsent(category, () => <Map<String, dynamic>>[]);
      categories[category]!.add(item);
    }

    final widgets = <Widget>[];

    for (final entry in categories.entries) {
      if (entry.key != 'Compétences') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              entry.key,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }

      for (final item in entry.value) {
        widgets.add(_buildSkillItem(context, item));
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  Widget _buildSkillItem(BuildContext context, Map<String, dynamic> item) {
    final score = item['score'] as int;
    final suffix = item['suffix'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List<Widget>.generate(5, (int i) {
                    final filled = i < score;
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        filled ? Icons.star : Icons.star_border,
                        color: filled
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          if (suffix != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  suffix,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.keyboard_arrow_up,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
