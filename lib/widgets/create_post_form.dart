import 'package:flutter/material.dart';

// Liste des domaines disponibles
const List<String> availableDomains = [
  'Développement Web',
  'Développement Mobile',
  'DevOps / Infrastructure',
  'Data Science / IA',
  'Cybersécurité',
  'Design / UI/UX',
  'Marketing Digital',
  'Gestion de Projet',
  'Finance / Comptabilité',
  'Ressources Humaines',
  'Commercial / Vente',
  'Support Client',
  'Autre',
];

// Mapping domaine -> hard skills suggérés
Map<String, List<String>> getDomainHardSkills() {
  return {
    'Développement Web': [
      'JavaScript',
      'TypeScript',
      'React',
      'Vue.js',
      'Angular',
      'Node.js',
      'Python',
      'PHP',
      'SQL',
      'MongoDB',
      'PostgreSQL',
      'REST API',
      'GraphQL',
      'Git',
      'Docker',
      'CI/CD',
    ],
    'Développement Mobile': [
      'Flutter',
      'Dart',
      'React Native',
      'Swift',
      'Kotlin',
      'Java',
      'iOS',
      'Android',
      'Firebase',
      'Git',
      'REST API',
    ],
    'DevOps / Infrastructure': [
      'Docker',
      'Kubernetes',
      'AWS',
      'Azure',
      'GCP',
      'CI/CD',
      'Git',
      'Linux',
      'Python',
      'Terraform',
      'Ansible',
    ],
    'Data Science / IA': [
      'Python',
      'Machine Learning',
      'Data Science',
      'SQL',
      'MongoDB',
      'PostgreSQL',
      'TensorFlow',
      'PyTorch',
      'R',
      'Pandas',
      'NumPy',
    ],
    'Cybersécurité': [
      'Cybersécurité',
      'Linux',
      'Python',
      'SQL',
      'Network Security',
      'Penetration Testing',
      'SIEM',
    ],
    'Design / UI/UX': [
      'UI/UX Design',
      'Figma',
      'Photoshop',
      'Illustrator',
      'Sketch',
      'Adobe XD',
      'Prototyping',
    ],
    'Marketing Digital': [
      'SEO',
      'Google Analytics',
      'Social Media Marketing',
      'Content Marketing',
      'Email Marketing',
      'Google Ads',
    ],
    'Gestion de Projet': [
      'Gestion de projet',
      'Agile',
      'Scrum',
      'Jira',
      'Trello',
      'Microsoft Project',
    ],
    'Finance / Comptabilité': [
      'Comptabilité',
      'Excel',
      'SAP',
      'Tableau',
      'Power BI',
    ],
    'Ressources Humaines': [
      'Recrutement',
      'Gestion de projet',
      'Excel',
      'HRIS',
    ],
    'Commercial / Vente': [
      'CRM',
      'Salesforce',
      'HubSpot',
      'Négociation',
    ],
    'Support Client': [
      'Zendesk',
      'ServiceNow',
      'Communication',
      'Troubleshooting',
    ],
  };
}

// Liste des soft skills disponibles
const List<String> availableSoftSkills = [
  'Communication',
  'Travail en équipe',
  'Leadership',
  'Gestion du stress',
  'Adaptabilité',
  'Créativité',
  'Empathie',
  'Organisation',
  'Autonomie',
  'Esprit d\'initiative',
  'Résolution de problèmes',
  'Négociation',
  'Gestion du temps',
  'Motivation',
  'Persévérance',
  'Confiance en soi',
  'Curiosité',
  'Pensée critique',
  'Intelligence émotionnelle',
  'Flexibilité',
];

// Liste des hard skills disponibles
const List<String> availableHardSkills = [
  'Flutter',
  'Dart',
  'React Native',
  'JavaScript',
  'TypeScript',
  'Python',
  'Java',
  'Kotlin',
  'Swift',
  'Node.js',
  'Firebase',
  'Git',
  'Docker',
  'Kubernetes',
  'AWS',
  'Azure',
  'GCP',
  'SQL',
  'MongoDB',
  'PostgreSQL',
  'REST API',
  'GraphQL',
  'CI/CD',
  'Agile',
  'Scrum',
  'Gestion de projet',
  'UI/UX Design',
  'Figma',
  'Photoshop',
  'Illustrator',
  'Machine Learning',
  'Data Science',
  'DevOps',
  'Cybersécurité',
  'Blockchain',
  'Web3',
];

class CreatePostForm extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;
  final bool isLoading;
  final String? initialTitle;
  final String? initialContent;
  final List<String>? initialSoftSkills;
  final List<String>? initialHardSkills;
  final String? initialDomain;

  const CreatePostForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.initialTitle,
    this.initialContent,
    this.initialSoftSkills,
    this.initialHardSkills,
    this.initialDomain,
  });

  @override
  State<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _softSkillsTagsController = TextEditingController();
  final _hardSkillsTagsController = TextEditingController();
  final Set<String> _selectedSoftSkills = <String>{};
  final Set<String> _selectedHardSkills = <String>{};
  String? _selectedDomain;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialContent != null) {
      _contentController.text = widget.initialContent!;
    }
    if (widget.initialSoftSkills != null) {
      _softSkillsTagsController.text = widget.initialSoftSkills!.join(', ');
      _selectedSoftSkills.addAll(widget.initialSoftSkills!);
    }
    if (widget.initialHardSkills != null) {
      _hardSkillsTagsController.text = widget.initialHardSkills!.join(', ');
      _selectedHardSkills.addAll(widget.initialHardSkills!);
    }
    if (widget.initialDomain != null) {
      _selectedDomain = widget.initialDomain;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _softSkillsTagsController.dispose();
    _hardSkillsTagsController.dispose();
    super.dispose();
  }

  List<String> _parseTags(String tagsText) {
    return tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final customSoftSkills = _parseTags(_softSkillsTagsController.text);
    final customHardSkills = _parseTags(_hardSkillsTagsController.text);

    // Combiner les compétences sélectionnées et les tags personnalisés
    final allSoftSkills = [
      ..._selectedSoftSkills.toList(),
      ...customSoftSkills,
    ].toSet().toList(); // Utiliser Set pour éviter les doublons

    final allHardSkills = [
      ..._selectedHardSkills.toList(),
      ...customHardSkills,
    ].toSet().toList(); // Utiliser Set pour éviter les doublons

    widget.onSubmit({
      'title': _titleController.text,
      'content': _contentController.text,
      'softSkills': allSoftSkills,
      'hardSkills': allHardSkills,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le titre est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Contenu',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le contenu est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedDomain,
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
              onChanged: (String? domain) {
                setState(() {
                  _selectedDomain = domain;
                });
              },
            ),
            const SizedBox(height: 24),
            // Soft Skills
            Text(
              'Soft Skills recherchés',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Champ pour ajouter des soft skills personnalisés
            TextFormField(
              controller: _softSkillsTagsController,
              decoration: const InputDecoration(
                labelText: 'Soft Skills personnalisés (séparés par des virgules)',
                border: OutlineInputBorder(),
                hintText: 'Ex: Gestion d\'équipe, Résilience',
                helperText: 'Vous pouvez aussi sélectionner depuis la liste ci-dessous',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
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
                      final isSelected = _selectedSoftSkills.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSoftSkills.add(skill);
                            } else {
                              _selectedSoftSkills.remove(skill);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Hard Skills
            Text(
              'Hard Skills recherchés',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Champ pour ajouter des hard skills personnalisés
            TextFormField(
              controller: _hardSkillsTagsController,
              decoration: const InputDecoration(
                labelText: 'Hard Skills personnalisés (séparés par des virgules)',
                border: OutlineInputBorder(),
                hintText: 'Ex: Vue.js, Next.js, Tailwind CSS',
                helperText: 'Vous pouvez aussi sélectionner depuis la liste ci-dessous',
              ),
            ),
            // Afficher les suggestions si un domaine est sélectionné
            if (_selectedDomain != null) ...[
              Builder(
                builder: (context) {
                  final domainHardSkills = getDomainHardSkills()[_selectedDomain] ?? [];
                  final suggestedSkills = domainHardSkills.toSet();
                  final allSkills = availableHardSkills.toSet();
                  
                  final suggestedSkillsList = allSkills.where((skill) => suggestedSkills.contains(skill)).toList();
                  final additionalSuggestedSkills = suggestedSkills.where((skill) => !allSkills.contains(skill)).toList();
                  final allSuggestedSkills = [...suggestedSkillsList, ...additionalSuggestedSkills];
                  final otherSkillsList = allSkills.where((skill) => !suggestedSkills.contains(skill)).toList();

                  if (allSuggestedSkills.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                'Suggestions pour le domaine "$_selectedDomain"',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Compétences suggérées',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 150),
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
                                final isSelected = _selectedHardSkills.contains(skill);
                                return FilterChip(
                                  label: Text(skill),
                                  selected: isSelected,
                                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                                  checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedHardSkills.add(skill);
                                      } else {
                                        _selectedHardSkills.remove(skill);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      if (otherSkillsList.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Autres compétences',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Builder(
                    builder: (context) {
                      // Si un domaine est sélectionné, filtrer les compétences
                      if (_selectedDomain != null) {
                        final domainHardSkills = getDomainHardSkills()[_selectedDomain] ?? [];
                        final suggestedSkills = domainHardSkills.toSet();
                        final allSkills = availableHardSkills.toSet();
                        final otherSkillsList = allSkills.where((skill) => !suggestedSkills.contains(skill)).toList();
                        
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: otherSkillsList.map((skill) {
                            final isSelected = _selectedHardSkills.contains(skill);
                            return FilterChip(
                              label: Text(skill),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedHardSkills.add(skill);
                                  } else {
                                    _selectedHardSkills.remove(skill);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      }
                      
                      // Sinon, afficher toutes les compétences
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableHardSkills.map((skill) {
                          final isSelected = _selectedHardSkills.contains(skill);
                          return FilterChip(
                            label: Text(skill),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedHardSkills.add(skill);
                                } else {
                                  _selectedHardSkills.remove(skill);
                                }
                              });
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Publier l\'offre'),
            ),
          ],
        ),
      ),
    );
  }
}

