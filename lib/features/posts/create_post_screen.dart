import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/services/post_service.dart';
import 'package:hire_me/widgets/create_post_form.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _isPublishing = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _softSkillsTagsController = TextEditingController();
  final TextEditingController _hardSkillsTagsController = TextEditingController();
  final Set<String> _selectedSoftSkills = <String>{};
  final Set<String> _selectedHardSkills = <String>{};
  String? _selectedDomain;

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _softSkillsTagsController.dispose();
    _hardSkillsTagsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      // Validation avant de passer à l'étape suivante
      if (_currentStep == 0) {
        if (_titleController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Le titre est requis'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (_contentController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Le contenu est requis'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _publishOffer() async {
    if (_isPublishing) return;

    setState(() {
      _isPublishing = true;
    });

    try {
      // Validation finale
      if (_titleController.text.trim().isEmpty) {
        throw Exception('Le titre est requis');
      }
      if (_contentController.text.trim().isEmpty) {
        throw Exception('Le contenu est requis');
      }

      // Parser les compétences personnalisées
      List<String> _parseTags(String tagsText) {
        return tagsText
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
      }

      final customSoftSkills = _parseTags(_softSkillsTagsController.text);
      final customHardSkills = _parseTags(_hardSkillsTagsController.text);

      // Combiner les compétences sélectionnées et les tags personnalisés
      // Limiter les soft skills à 5 maximum
      final allSoftSkills = [
        ..._selectedSoftSkills.toList(),
        ...customSoftSkills,
      ].toSet().toList().take(5).toList();

      final allHardSkills = [
        ..._selectedHardSkills.toList(),
        ...customHardSkills,
      ].toSet().toList();

      print('📝 Publication de l\'offre...');
      print('   Titre: ${_titleController.text.trim()}');
      print('   Domaine: $_selectedDomain');
      print('   Soft Skills: $allSoftSkills');
      print('   Hard Skills: $allHardSkills');

      final postId = await PostService.createPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        softSkills: allSoftSkills,
        hardSkills: allHardSkills,
        domain: _selectedDomain,
      );

      print('✅ Offre publiée avec succès ! ID: $postId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offre publiée avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // Attendre un peu avant de naviguer pour que l'utilisateur voie le message
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/profile');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Erreur lors de la publication de l\'offre: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la publication: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Fermer',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Logo1(height: 28, fit: BoxFit.contain),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/profile'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                'Étape ${_currentStep + 1}/$_totalSteps',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Column(
        children: <Widget>[
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                _BasicInfoStep(
                  titleController: _titleController,
                  contentController: _contentController,
                  selectedDomain: _selectedDomain,
                  onDomainChanged: (String? domain) {
                    setState(() {
                      _selectedDomain = domain;
                    });
                  },
                ),
                _SoftSkillsStep(
                  softSkillsTagsController: _softSkillsTagsController,
                  selectedSoftSkills: _selectedSoftSkills,
                  onSoftSkillToggled: (String skill, bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedSoftSkills.add(skill);
                      } else {
                        _selectedSoftSkills.remove(skill);
                      }
                    });
                  },
                ),
                _HardSkillsStep(
                  hardSkillsTagsController: _hardSkillsTagsController,
                  selectedHardSkills: _selectedHardSkills,
                  selectedDomain: _selectedDomain,
                  onHardSkillToggled: (String skill, bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedHardSkills.add(skill);
                      } else {
                        _selectedHardSkills.remove(skill);
                      }
                    });
                  },
                ),
                _PreviewStep(
                  titleController: _titleController,
                  contentController: _contentController,
                  softSkillsTagsController: _softSkillsTagsController,
                  hardSkillsTagsController: _hardSkillsTagsController,
                  selectedSoftSkills: _selectedSoftSkills,
                  selectedHardSkills: _selectedHardSkills,
                  selectedDomain: _selectedDomain,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Précédent'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _isPublishing
                        ? null
                        : (_currentStep == _totalSteps - 1 ? _publishOffer : _nextStep),
                    child: _isPublishing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentStep == _totalSteps - 1 ? 'Publier l\'offre' : 'Suivant'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Étape 1 : Informations de base
class _BasicInfoStep extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final String? selectedDomain;
  final void Function(String?) onDomainChanged;

  const _BasicInfoStep({
    required this.titleController,
    required this.contentController,
    required this.selectedDomain,
    required this.onDomainChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de base',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Remplissez les informations principales de votre offre',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Titre de l\'offre',
              hintText: 'Ex: Développeur Flutter Senior',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: contentController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Décrivez votre offre en détail...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: selectedDomain,
            decoration: const InputDecoration(
              labelText: 'Domaine',
              hintText: 'Sélectionnez le domaine de l\'offre',
              border: OutlineInputBorder(),
              helperText: 'Cela permettra de suggérer des compétences pertinentes',
            ),
            items: availableDomains.map((domain) {
              return DropdownMenuItem<String>(
                value: domain,
                child: Text(domain),
              );
            }).toList(),
            onChanged: onDomainChanged,
          ),
        ],
      ),
    );
  }
}

// Étape 2 : Soft Skills
class _SoftSkillsStep extends StatefulWidget {
  final TextEditingController softSkillsTagsController;
  final Set<String> selectedSoftSkills;
  final void Function(String, bool) onSoftSkillToggled;

  const _SoftSkillsStep({
    required this.softSkillsTagsController,
    required this.selectedSoftSkills,
    required this.onSoftSkillToggled,
  });

  @override
  State<_SoftSkillsStep> createState() => _SoftSkillsStepState();
}

class _SoftSkillsStepState extends State<_SoftSkillsStep> {
  List<String> _parseTags(String tagsText) {
    return tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final customSoftSkills = _parseTags(widget.softSkillsTagsController.text);
    final totalSoftSkills = widget.selectedSoftSkills.length + customSoftSkills.length;
    final canSelectMore = totalSoftSkills < 5;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soft Skills recherchés',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez ou ajoutez les compétences comportementales recherchées (maximum 5, non obligatoire)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (totalSoftSkills > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${totalSoftSkills}/5 soft skills sélectionnés',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          TextFormField(
            controller: widget.softSkillsTagsController,
            decoration: InputDecoration(
              labelText: 'Soft Skills personnalisés (séparés par des virgules)',
              border: const OutlineInputBorder(),
              hintText: 'Ex: Gestion d\'équipe, Résilience',
              helperText: canSelectMore
                  ? 'Vous pouvez aussi sélectionner depuis la liste ci-dessous'
                  : 'Limite de 5 soft skills atteinte',
              enabled: canSelectMore,
            ),
            onChanged: (value) {
              setState(() {
                // Mise à jour pour recalculer le compteur
              });
            },
          ),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableSoftSkills.map((skill) {
                    final isSelected = widget.selectedSoftSkills.contains(skill);
                    return FilterChip(
                      label: Text(skill),
                      selected: isSelected,
                      onSelected: canSelectMore || isSelected
                          ? (selected) {
                              widget.onSoftSkillToggled(skill, selected);
                              setState(() {
                                // Mise à jour pour recalculer le compteur
                              });
                            }
                          : null,
                      disabledColor: Colors.grey.shade300,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Étape 3 : Hard Skills
class _HardSkillsStep extends StatelessWidget {
  final TextEditingController hardSkillsTagsController;
  final Set<String> selectedHardSkills;
  final String? selectedDomain;
  final void Function(String, bool) onHardSkillToggled;

  const _HardSkillsStep({
    required this.hardSkillsTagsController,
    required this.selectedHardSkills,
    required this.selectedDomain,
    required this.onHardSkillToggled,
  });

  @override
  Widget build(BuildContext context) {
    final domainHardSkills = selectedDomain != null 
        ? getDomainHardSkills()[selectedDomain] ?? []
        : <String>[];
    
    // Combiner les hard skills suggérés et tous les hard skills disponibles
    final suggestedSkills = domainHardSkills.toSet();
    final allSkills = availableHardSkills.toSet();
    
    // Séparer les compétences suggérées (qui sont dans availableHardSkills) et les autres
    final suggestedSkillsList = allSkills.where((skill) => suggestedSkills.contains(skill)).toList();
    // Ajouter aussi les compétences suggérées qui ne sont pas dans availableHardSkills
    final additionalSuggestedSkills = suggestedSkills.where((skill) => !allSkills.contains(skill)).toList();
    final allSuggestedSkills = [...suggestedSkillsList, ...additionalSuggestedSkills];
    
    final otherSkillsList = allSkills.where((skill) => !suggestedSkills.contains(skill)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hard Skills recherchés',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez ou ajoutez les compétences techniques recherchées',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (selectedDomain != null && allSuggestedSkills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Suggestions pour le domaine "$selectedDomain"',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          TextFormField(
            controller: hardSkillsTagsController,
            decoration: const InputDecoration(
              labelText: 'Hard Skills personnalisés (séparés par des virgules)',
              border: OutlineInputBorder(),
              hintText: 'Ex: Vue.js, Next.js, Tailwind CSS',
              helperText: 'Vous pouvez aussi sélectionner depuis la liste ci-dessous',
            ),
          ),
          if (allSuggestedSkills.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Compétences suggérées',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allSuggestedSkills.map((skill) {
                      final isSelected = selectedHardSkills.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: isSelected,
                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        onSelected: (selected) => onHardSkillToggled(skill, selected),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
          if (otherSkillsList.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              allSuggestedSkills.isNotEmpty ? 'Autres compétences' : 'Toutes les compétences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: otherSkillsList.map((skill) {
                      final isSelected = selectedHardSkills.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: isSelected,
                        onSelected: (selected) => onHardSkillToggled(skill, selected),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Étape 4 : Aperçu
class _PreviewStep extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController softSkillsTagsController;
  final TextEditingController hardSkillsTagsController;
  final Set<String> selectedSoftSkills;
  final Set<String> selectedHardSkills;
  final String? selectedDomain;

  const _PreviewStep({
    required this.titleController,
    required this.contentController,
    required this.softSkillsTagsController,
    required this.hardSkillsTagsController,
    required this.selectedSoftSkills,
    required this.selectedHardSkills,
    required this.selectedDomain,
  });

  List<String> _parseTags(String tagsText) {
    return tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final customSoftSkills = _parseTags(softSkillsTagsController.text);
    final customHardSkills = _parseTags(hardSkillsTagsController.text);
    
    final allSoftSkills = [
      ...selectedSoftSkills.toList(),
      ...customSoftSkills,
    ].toSet().toList().take(5).toList();
    
    final allHardSkills = [
      ...selectedHardSkills.toList(),
      ...customHardSkills,
    ].toSet().toList();

    final title = titleController.text;
    final content = contentController.text;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aperçu de l\'offre',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vérifiez les informations avant de publier',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          // Domaine
          if (selectedDomain != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Domaine',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(selectedDomain!),
                      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (selectedDomain != null) const SizedBox(height: 16),
          // Titre
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Titre',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title.isEmpty ? '(Non renseigné)' : title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.isEmpty ? '(Non renseigné)' : content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Soft Skills
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soft Skills recherchés',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (allSoftSkills.isEmpty)
                    Text(
                      '(Aucun soft skill sélectionné)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allSoftSkills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Hard Skills
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hard Skills recherchés',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (allHardSkills.isEmpty)
                    Text(
                      '(Aucun hard skill sélectionné)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allHardSkills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

