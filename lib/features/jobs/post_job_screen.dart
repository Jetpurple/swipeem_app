import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/services/firebase_job_service.dart';

// Liste de suggestions de localisations
const List<String> _locationSuggestions = [
  // France - Grandes villes
  'Paris, France',
  'Lyon, France',
  'Marseille, France',
  'Toulouse, France',
  'Nice, France',
  'Nantes, France',
  'Strasbourg, France',
  'Montpellier, France',
  'Bordeaux, France',
  'Lille, France',
  'Rennes, France',
  'Reims, France',
  'Saint-Étienne, France',
  'Toulon, France',
  'Le Havre, France',
  'Grenoble, France',
  'Dijon, France',
  'Angers, France',
  'Nîmes, France',
  'Villeurbanne, France',
  'Saint-Denis, France',
  'Aix-en-Provence, France',
  'Clermont-Ferrand, France',
  'Brest, France',
  'Limoges, France',
  'Tours, France',
  'Amiens, France',
  'Perpignan, France',
  'Metz, France',
  'Besançon, France',
  // Île-de-France
  'Nanterre, France',
  'Créteil, France',
  'Versailles, France',
  'Boulogne-Billancourt, France',
  'Argenteuil, France',
  'Montreuil, France',
  'Saint-Denis, France',
  'Aubervilliers, France',
  'Asnières-sur-Seine, France',
  'Colombes, France',
  // Télétravail
  'Télétravail',
  'Télétravail (France)',
  'Télétravail (International)',
  'Hybride (France)',
  // International
  'Londres, Royaume-Uni',
  'Bruxelles, Belgique',
  'Genève, Suisse',
  'Zurich, Suisse',
  'Barcelone, Espagne',
  'Madrid, Espagne',
  'Amsterdam, Pays-Bas',
  'Berlin, Allemagne',
  'Munich, Allemagne',
  'Vienne, Autriche',
  'Lisbonne, Portugal',
  'Rome, Italie',
  'Milan, Italie',
  'Dublin, Irlande',
  'Copenhague, Danemark',
  'Stockholm, Suède',
  'Oslo, Norvège',
  'Helsinki, Finlande',
  'New York, États-Unis',
  'San Francisco, États-Unis',
  'Toronto, Canada',
  'Montréal, Canada',
  'Sydney, Australie',
  'Melbourne, Australie',
];

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;
  bool _isPublishing = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  String _selectedContractType = 'CDI';
  String _selectedExperience = '2-5 ans';

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
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

  Future<void> _publishJob() async {
    if (_isPublishing) return;
    
    setState(() {
      _isPublishing = true;
    });

    try {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Validation des champs requis
      if (_titleController.text.trim().isEmpty) {
        throw Exception('Le titre est requis');
      }
      if (_descriptionController.text.trim().isEmpty) {
        throw Exception('La description est requise');
      }
      if (_locationController.text.trim().isEmpty) {
        throw Exception('La localisation est requise');
      }
      if (_salaryController.text.trim().isEmpty) {
        throw Exception('Le salaire est requis');
      }

      // Créer l'offre d'emploi
      await FirebaseJobService.createJobOffer(
        title: _titleController.text.trim(),
        company: 'Votre entreprise', // TODO: Récupérer depuis le profil utilisateur
        location: _locationController.text.trim(),
        salary: _salaryController.text.trim(),
        description: _descriptionController.text.trim(),
        requirements: ['Expérience requise', 'Compétences techniques'], // TODO: Collecter ces données
        benefits: ['Avantages sociaux', 'Formation'], // TODO: Collecter ces données
        postedBy: uid,
        type: _selectedContractType,
        experience: _selectedExperience,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offre publiée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/profile');
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
              child: Text('Étape ${_currentStep + 1}/$_totalSteps', style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
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
                _JobDetailsStep(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                ),
                _JobRequirementsStep(
                  locationController: _locationController,
                  salaryController: _salaryController,
                  selectedContractType: _selectedContractType,
                  selectedExperience: _selectedExperience,
                  onContractTypeChanged: (String value) {
                    setState(() {
                      _selectedContractType = value;
                    });
                  },
                  onExperienceChanged: (String value) {
                    setState(() {
                      _selectedExperience = value;
                    });
                  },
                ),
                _JobPreviewStep(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  location: _locationController.text,
                  salary: _salaryController.text,
                  contractType: _selectedContractType,
                  experience: _selectedExperience,
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
                        : (_currentStep == _totalSteps - 1 ? _publishJob : _nextStep),
                    child: _isPublishing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _currentStep == _totalSteps - 1 ? 'Publier' : 'Suivant',
                          ),
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

class _JobDetailsStep extends StatelessWidget {
  const _JobDetailsStep({
    required this.titleController,
    required this.descriptionController,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Détails du poste',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Titre du poste',
              hintText: 'Ex: Développeur Flutter Senior',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: "Décrivez le poste, les missions, l'équipe...",
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 6,
          ),
        ],
      ),
    );
  }
}

class _JobRequirementsStep extends StatelessWidget {
  const _JobRequirementsStep({
    required this.locationController,
    required this.salaryController,
    required this.selectedContractType,
    required this.selectedExperience,
    required this.onContractTypeChanged,
    required this.onExperienceChanged,
  });

  final TextEditingController locationController;
  final TextEditingController salaryController;
  final String selectedContractType;
  final String selectedExperience;
  final ValueChanged<String> onContractTypeChanged;
  final ValueChanged<String> onExperienceChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Exigences',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return _locationSuggestions.where((String location) {
                return location.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
              });
            },
            onSelected: (String location) {
              locationController.text = location;
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController fieldTextEditingController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted,
            ) {
              // Synchroniser le controller externe avec le controller interne au démarrage
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (fieldTextEditingController.text != locationController.text) {
                  fieldTextEditingController.text = locationController.text;
                }
              });
              
              return TextField(
                controller: fieldTextEditingController,
                focusNode: fieldFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Localisation',
                  hintText: 'Ex: Paris, France',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.location_on),
                ),
                onChanged: (String value) {
                  locationController.text = value;
                },
                onSubmitted: (String value) {
                  onFieldSubmitted();
                },
              );
            },
            optionsViewBuilder: (
              BuildContext context,
              AutocompleteOnSelected<String> onSelected,
              Iterable<String> options,
            ) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return InkWell(
                          onTap: () {
                            onSelected(option);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.location_city, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: salaryController,
            decoration: const InputDecoration(
              labelText: 'Salaire',
              hintText: 'Ex: 45k - 60k €',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Type de contrat',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <String>['CDI', 'CDD', 'Freelance', 'Stage']
                .map(
                  (String type) => FilterChip(
                    label: Text(type),
                    selected: selectedContractType == type,
                    onSelected: (bool selected) {
                      if (selected) {
                        onContractTypeChanged(type);
                      }
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Expérience requise',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <String>['0-2 ans', '2-5 ans', '5-10 ans', '10+ ans']
                .map(
                  (String exp) => FilterChip(
                    label: Text(exp),
                    selected: selectedExperience == exp,
                    onSelected: (bool selected) {
                      if (selected) {
                        onExperienceChanged(exp);
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _JobPreviewStep extends StatelessWidget {
  const _JobPreviewStep({
    required this.title,
    required this.description,
    required this.location,
    required this.salary,
    required this.contractType,
    required this.experience,
  });

  final String title;
  final String description;
  final String location;
  final String salary;
  final String contractType;
  final String experience;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Aperçu de l'offre",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title.isEmpty ? 'Titre du poste' : title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gueudet • $location',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description.isEmpty ? 'Description du poste...' : description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    Chip(label: Text(contractType)),
                    Chip(label: Text(experience)),
                    if (salary.isNotEmpty) Chip(label: Text(salary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
