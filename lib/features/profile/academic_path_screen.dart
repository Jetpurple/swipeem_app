import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class AcademicPathScreen extends ConsumerStatefulWidget {
  const AcademicPathScreen({super.key});

  @override
  ConsumerState<AcademicPathScreen> createState() => _AcademicPathScreenState();
}

class _AcademicPathScreenState extends ConsumerState<AcademicPathScreen> {
  final List<Map<String, dynamic>> _academicPath = [
    {
      'id': '1',
      'degree': 'Master en Informatique',
      'school': 'Université de Paris',
      'location': 'Paris, France',
      'startDate': '2018-09',
      'endDate': '2020-06',
      'isCurrent': false,
      'description': 'Spécialisation en développement web et intelligence artificielle.',
      'grade': 'Mention Très Bien',
      'courses': [
        'Algorithmes avancés',
        'Intelligence artificielle',
        'Développement web',
        'Base de données',
        'Sécurité informatique'
      ],
      'achievements': [
        "Projet de fin d'études : Application de recommandation IA",
        'Participation au hackathon universitaire (2ème place)',
        'Tuteur pour les étudiants de licence'
      ]
    },
    {
      'id': '2',
      'degree': 'Licence en Informatique',
      'school': 'Université de Lyon',
      'location': 'Lyon, France',
      'startDate': '2015-09',
      'endDate': '2018-06',
      'isCurrent': false,
      'description': 'Formation fondamentale en informatique et mathématiques.',
      'grade': 'Mention Bien',
      'courses': [
        'Programmation orientée objet',
        'Mathématiques appliquées',
        'Réseaux informatiques',
        "Systèmes d'exploitation",
        'Architecture des ordinateurs'
      ],
      'achievements': [
        "Membre de l'association étudiante informatique",
        "Projet de groupe : Site web pour l'université"
      ]
    },
    {
      'id': '3',
      'degree': 'Baccalauréat Scientifique',
      'school': 'Lycée Victor Hugo',
      'location': 'Marseille, France',
      'startDate': '2012-09',
      'endDate': '2015-06',
      'isCurrent': false,
      'description': "Spécialité Mathématiques et Sciences de l'Ingénieur.",
      'grade': 'Mention Bien',
      'courses': [
        'Mathématiques',
        'Physique-Chimie',
        "Sciences de l'Ingénieur",
        'Français',
        'Anglais'
      ],
      'achievements': [
        'Délégué de classe en Terminale',
        'Participation aux Olympiades de Mathématiques'
      ]
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
            onPressed: () => _showAddAcademicDialog(context),
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
                  Icons.school,
                  size: isTablet ? 60 : 48,
                  color: Colors.white,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  'Mon Parcours Académique',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 4),
                Text(
                  'Gérez votre formation et vos diplômes',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Liste du parcours académique
          Expanded(
            child: _academicPath.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    itemCount: _academicPath.length,
                    itemBuilder: (context, index) {
                      return _buildAcademicCard(_academicPath[index], index);
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
              Icons.school_outlined,
              size: isTablet ? 80 : 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'Aucun diplôme ajouté',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              'Ajoutez vos diplômes et formations pour enrichir votre profil',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            ElevatedButton.icon(
              onPressed: () => _showAddAcademicDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un diplôme'),
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

  Widget _buildAcademicCard(Map<String, dynamic> academic, int index) {
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
                        academic['degree'],
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        academic['school'],
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
                            academic['location'],
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
                            '${academic['startDate']} - ${academic['isCurrent'] ? 'En cours' : academic['endDate']}',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      if (academic['grade'] != null) ...[
                        SizedBox(height: isTablet ? 4 : 2),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 8 : 6,
                            vertical: isTablet ? 4 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5271FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                          ),
                          child: Text(
                            academic['grade'],
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
                              color: const Color(0xFF5271FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAcademicAction(value, academic),
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
              academic['description'],
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            
            SizedBox(height: isTablet ? 16 : 12),
            
            // Matières/Modules
            if (academic['courses'].isNotEmpty) ...[
              Text(
                'Matières principales :',
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
                children: academic['courses'].map<Widget>((course) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 8,
                    vertical: isTablet ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    course,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 10,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
              SizedBox(height: isTablet ? 16 : 12),
            ],
            
            // Réalisations
            if (academic['achievements'].isNotEmpty) ...[
              Text(
                'Réalisations :',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: isTablet ? 8 : 4),
              ...academic['achievements'].map<Widget>((achievement) => Padding(
                padding: EdgeInsets.only(bottom: isTablet ? 4 : 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.star,
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
            ],
          ],
        ),
      ),
    );
  }

  void _handleAcademicAction(String action, Map<String, dynamic> academic) {
    switch (action) {
      case 'edit':
        _showEditAcademicDialog(context, academic);
      case 'delete':
        _showDeleteAcademicDialog(context, academic);
    }
  }

  void _showAddAcademicDialog(BuildContext context) {
    _showAcademicDialog(context, null);
  }

  void _showEditAcademicDialog(BuildContext context, Map<String, dynamic> academic) {
    _showAcademicDialog(context, academic);
  }

  void _showAcademicDialog(BuildContext context, Map<String, dynamic>? academic) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(academic == null ? 'Ajouter un diplôme' : 'Modifier le diplôme'),
        content: SizedBox(
          width: isTablet ? 500 : double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Diplôme/Formation',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: academic?['degree'] ?? ''),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Établissement',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: academic?['school'] ?? ''),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Lieu',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: academic?['location'] ?? ''),
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
                        controller: TextEditingController(text: academic?['startDate'] ?? ''),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Date de fin',
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: academic?['endDate'] ?? ''),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Mention/Grade',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: academic?['grade'] ?? ''),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  controller: TextEditingController(text: academic?['description'] ?? ''),
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
            child: Text(academic == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAcademicDialog(BuildContext context, Map<String, dynamic> academic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le diplôme'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${academic['degree']}" ?'),
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
