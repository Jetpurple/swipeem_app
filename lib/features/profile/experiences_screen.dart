import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class ExperiencesScreen extends ConsumerStatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  ConsumerState<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends ConsumerState<ExperiencesScreen> {
  final List<Map<String, dynamic>> _experiences = [
    {
      'id': '1',
      'title': 'Développeur Full Stack',
      'company': 'TechCorp',
      'location': 'Paris, France',
      'startDate': '2022-01',
      'endDate': '2024-01',
      'isCurrent': false,
      'description': "Développement d'applications web et mobiles avec React, Node.js et Flutter. Gestion d'équipe de 5 développeurs.",
      'achievements': [
        "Augmentation de 40% des performances de l'application",
        "Mise en place d'une architecture microservices",
        'Formation de 3 nouveaux développeurs'
      ],
      'skills': ['React', 'Node.js', 'Flutter', 'PostgreSQL', 'AWS']
    },
    {
      'id': '2',
      'title': 'Développeur Frontend',
      'company': 'StartupXYZ',
      'location': 'Lyon, France',
      'startDate': '2020-06',
      'endDate': '2021-12',
      'isCurrent': false,
      'description': "Développement d'interfaces utilisateur modernes et responsives.",
      'achievements': [
        "Amélioration de l'UX de 60%",
        'Réduction du temps de chargement de 50%'
      ],
      'skills': ['Vue.js', 'TypeScript', 'CSS3', 'Figma']
    },
    {
      'id': '3',
      'title': 'Développeur Junior',
      'company': 'WebAgency',
      'location': 'Marseille, France',
      'startDate': '2019-09',
      'endDate': '2020-05',
      'isCurrent': false,
      'description': 'Première expérience professionnelle en développement web.',
      'achievements': [
        'Développement de 15 sites web',
        'Apprentissage des bonnes pratiques'
      ],
      'skills': ['HTML', 'CSS', 'JavaScript', 'PHP']
    }
  ];

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExperienceDialog(context),
          ),
          const ThemeToggleIconButton(),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5271FF), Color(0xFF3B5BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.work,
                  size: isTablet ? 60 : 48,
                  color: Colors.white,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  'Mes Expériences',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 4),
                Text(
                  'Gérez votre parcours professionnel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des expériences
          Expanded(
            child: _experiences.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    itemCount: _experiences.length,
                    itemBuilder: (context, index) {
                      return _buildExperienceCard(_experiences[index], index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 40 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: isTablet ? 80 : 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'Aucune expérience ajoutée',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              'Ajoutez vos expériences professionnelles pour enrichir votre profil',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            ElevatedButton.icon(
              onPressed: () => _showAddExperienceDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une expérience'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5271FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> experience, int index) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec titre et actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        experience['title'] as String,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        experience['company'],
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: isTablet ? 16 : 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          SizedBox(width: isTablet ? 4 : 2),
                          Text(
                            experience['location'],
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          SizedBox(width: isTablet ? 16 : 12),
                          Icon(
                            Icons.calendar_today,
                            size: isTablet ? 16 : 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          SizedBox(width: isTablet ? 4 : 2),
                          Text(
                            '${experience['startDate']} - ${experience['isCurrent'] ? 'Présent' : experience['endDate']}',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleExperienceAction(value, experience),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isTablet ? 16 : 12),
            
            // Description
            Text(
              experience['description'],
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            
            SizedBox(height: isTablet ? 16 : 12),
            
            // Réalisations
            if (experience['achievements'].isNotEmpty) ...[
              Text(
                'Réalisations clés :',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: isTablet ? 8 : 4),
              ...experience['achievements'].map<Widget>((achievement) => Padding(
                padding: EdgeInsets.only(bottom: isTablet ? 4 : 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: isTablet ? 16 : 14,
                      color: const Color(0xFF5271FF),
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    Expanded(
                      child: Text(
                        achievement,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              SizedBox(height: isTablet ? 16 : 12),
            ],
            
            // Compétences
            if (experience['skills'].isNotEmpty) ...[
              Text(
                'Compétences :',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: isTablet ? 8 : 4),
              Wrap(
                spacing: isTablet ? 8 : 6,
                runSpacing: isTablet ? 8 : 6,
                children: experience['skills'].map<Widget>((skill) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 8,
                    vertical: isTablet ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5271FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    border: Border.all(
                      color: const Color(0xFF5271FF).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 10,
                      color: const Color(0xFF5271FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleExperienceAction(String action, Map<String, dynamic> experience) {
    switch (action) {
      case 'edit':
        _showEditExperienceDialog(context, experience);
      case 'delete':
        _showDeleteExperienceDialog(context, experience);
    }
  }

  void _showAddExperienceDialog(BuildContext context) {
    _showExperienceDialog(context, null);
  }

  void _showEditExperienceDialog(BuildContext context, Map<String, dynamic> experience) {
    _showExperienceDialog(context, experience);
  }

  void _showExperienceDialog(BuildContext context, Map<String, dynamic>? experience) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(experience == null ? 'Ajouter une expérience' : "Modifier l'expérience"),
        content: SizedBox(
          width: isTablet ? 500 : double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Poste',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: experience?['title'] ?? ''),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Entreprise',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: experience?['company'] ?? ''),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Lieu',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: experience?['location'] ?? ''),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Date de début',
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: experience?['startDate'] ?? ''),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Date de fin',
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: experience?['endDate'] ?? ''),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  controller: TextEditingController(text: experience?['description'] ?? ''),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(context);
            },
            child: Text(experience == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  void _showDeleteExperienceDialog(BuildContext context, Map<String, dynamic> experience) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer l'expérience"),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'expérience "${experience['title']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(context);
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
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
}
