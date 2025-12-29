import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/services/firebase_user_service.dart';

class SimplePersonalityTestScreen extends ConsumerStatefulWidget {
  const SimplePersonalityTestScreen({super.key});

  @override
  ConsumerState<SimplePersonalityTestScreen> createState() => _SimplePersonalityTestScreenState();
}

class _SimplePersonalityTestScreenState extends ConsumerState<SimplePersonalityTestScreen> {
  int _currentQuestion = 0;
  final List<int> _answers = [];
  bool _testCompleted = false;
  String _personalityType = '';

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Dans une situation de travail en équipe, vous préférez :',
      'options': [
        'Prendre le leadership et diriger le groupe',
        'Collaborer de manière égale avec tous',
        'Écouter et suivre les suggestions des autres',
        'Travailler de manière autonome'
      ]
    },
    {
      'question': 'Face à un problème complexe, vous :',
      'options': [
        'Analysez méthodiquement toutes les données',
        'Recherchez des solutions créatives et innovantes',
        'Consultez vos collègues pour leurs avis',
        'Prenez une décision rapide et agissez'
      ]
    },
    {
      'question': 'Votre environnement de travail idéal est :',
      'options': [
        'Un bureau calme et organisé',
        'Un espace ouvert et dynamique',
        'Un environnement flexible et adaptable',
        "Un lieu avec beaucoup d'interactions sociales"
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
        actions: const [
          ThemeToggleIconButton(),
        ],
      ),
      body: _testCompleted ? _buildResults() : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          children: [
            // Progression
            Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFF5271FF),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
              child: Column(
                children: [
                  Text(
                    'Test de Personnalité',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  LinearProgressIndicator(
                    value: (_currentQuestion + 1) / _questions.length,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: isTablet ? 8 : 6,
                  ),
                  SizedBox(height: isTablet ? 12 : 8),
                  Text(
                    'Question ${_currentQuestion + 1} sur ${_questions.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: isTablet ? 24 : 20),
            
            // Question
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 24 : 20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _questions[_currentQuestion]['question'] as String,
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 16),
                  ...List.generate((_questions[_currentQuestion]['options'] as List).length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                      child: _buildOptionButton(index),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(int optionIndex) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final options = _questions[_currentQuestion]['options'] as List;
    final option = options[optionIndex] as String;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _selectAnswer(optionIndex),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          foregroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 16 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildResults() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          children: [
            // Résultats
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5271FF), Color(0xFF3B5BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5271FF).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.psychology,
                    size: isTablet ? 60 : 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Text(
                    'Votre Profil de Personnalité',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isTablet ? 12 : 8),
                  Text(
                    _personalityType,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: isTablet ? 24 : 20),
            
            // Description
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description de votre profil',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: isTablet ? 12 : 8),
                  Text(
                    _getPersonalityDescription(),
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: isTablet ? 24 : 20),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _restartTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    child: Text(
                      'Refaire le test',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _savePersonalityResults,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5271FF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Sauvegarder et générer mes soft skills',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _answers.add(answerIndex);
      if (_currentQuestion < _questions.length - 1) {
        _currentQuestion++;
      } else {
        _testCompleted = true;
        _personalityType = _calculatePersonalityType();
      }
    });
  }

  String _calculatePersonalityType() {
    // Logique simple pour déterminer le type de personnalité
    var analytical = 0;
    var creative = 0;
    var collaborative = 0;
    var action = 0;

    for (var i = 0; i < _answers.length; i++) {
      final answer = _answers[i];
      switch (i) {
        case 0: // Leadership
          if (answer == 0) {
            action++;
          } else if (answer == 1) collaborative++;
          else if (answer == 2) collaborative++;
          else analytical++;
        case 1: // Résolution de problème
          if (answer == 0) {
            analytical++;
          } else if (answer == 1) creative++;
          else if (answer == 2) collaborative++;
          else action++;
        case 2: // Environnement
          if (answer == 0) {
            analytical++;
          } else if (answer == 1) action++;
          else if (answer == 2) creative++;
          else collaborative++;
      }
    }

    if (analytical >= creative && analytical >= collaborative && analytical >= action) {
      return 'Analytique';
    } else if (creative >= collaborative && creative >= action) {
      return 'Créatif';
    } else if (collaborative >= action) {
      return 'Collaboratif';
    } else {
      return 'Action';
    }
  }

  String _getPersonalityDescription() {
    switch (_personalityType) {
      case 'Analytique':
        return "Vous êtes méthodique, organisé et vous préférez analyser les situations avant d'agir. Vous excellez dans les tâches qui nécessitent de la précision et de l'attention aux détails.";
      case 'Créatif':
        return "Vous êtes innovant, imaginatif et vous aimez explorer de nouvelles idées. Vous excellez dans les environnements qui encouragent la créativité et l'innovation.";
      case 'Collaboratif':
        return "Vous êtes sociable, empathique et vous excellez dans le travail d'équipe. Vous êtes à l'aise dans les environnements où la communication et la collaboration sont essentielles.";
      case 'Action':
        return "Vous êtes dynamique, décidé et vous préférez l'action à la réflexion. Vous excellez dans les environnements rapides et compétitifs où les décisions doivent être prises rapidement.";
      default:
        return 'Votre profil de personnalité est unique et combine plusieurs traits qui vous rendent adaptable à différents environnements de travail.';
    }
  }

  List<Map<String, dynamic>> _generateSoftSkillsFromPersonality() {
    // Définir les soft skills de base selon le type de personnalité
    final Map<String, List<Map<String, dynamic>>> personalitySkills = {
      'Analytique': [
        {'label': 'Analyse et résolution de problèmes', 'score': 5, 'category': 'Cognitif'},
        {'label': 'Attention aux détails', 'score': 5, 'category': 'Cognitif'},
        {'label': 'Pensée critique', 'score': 5, 'category': 'Cognitif'},
        {'label': 'Organisation', 'score': 4, 'category': 'Personnel'},
        {'label': 'Rigueur', 'score': 4, 'category': 'Personnel'},
        {'label': 'Planification stratégique', 'score': 4, 'category': 'Cognitif'},
        {'label': 'Prise de décision basée sur les données', 'score': 5, 'category': 'Cognitif'},
      ],
      'Créatif': [
        {'label': 'Créativité et innovation', 'score': 5, 'category': 'Cognitif'},
        {'label': 'Pensée hors des sentiers battus', 'score': 5, 'category': 'Cognitif'},
        {'label': 'Flexibilité', 'score': 4, 'category': 'Personnel'},
        {'label': 'Imagination', 'score': 5, 'category': 'Personnel'},
        {'label': 'Résolution créative de problèmes', 'score': 5, 'category': 'Cognitif'},
        {'label': 'Adaptabilité', 'score': 4, 'category': 'Personnel'},
        {'label': 'Vision stratégique', 'score': 4, 'category': 'Cognitif'},
      ],
      'Collaboratif': [
        {'label': 'Travail d\'équipe', 'score': 5, 'category': 'Interpersonnel'},
        {'label': 'Communication', 'score': 5, 'category': 'Interpersonnel'},
        {'label': 'Empathie', 'score': 5, 'category': 'Interpersonnel'},
        {'label': 'Écoute active', 'score': 5, 'category': 'Interpersonnel'},
        {'label': 'Collaboration', 'score': 5, 'category': 'Interpersonnel'},
        {'label': 'Intelligence émotionnelle', 'score': 4, 'category': 'Interpersonnel'},
        {'label': 'Gestion des conflits', 'score': 4, 'category': 'Interpersonnel'},
      ],
      'Action': [
        {'label': 'Prise d\'initiative', 'score': 5, 'category': 'Personnel'},
        {'label': 'Leadership', 'score': 5, 'category': 'Leadership'},
        {'label': 'Décision rapide', 'score': 5, 'category': 'Cognitif'},
        {'label': 'Orientation résultats', 'score': 5, 'category': 'Personnel'},
        {'label': 'Dynamisme', 'score': 5, 'category': 'Personnel'},
        {'label': 'Gestion de la pression', 'score': 4, 'category': 'Personnel'},
        {'label': 'Esprit de compétition', 'score': 4, 'category': 'Personnel'},
      ],
    };

    // Retourner les skills correspondant au type de personnalité
    return personalitySkills[_personalityType] ?? [];
  }

  void _restartTest() {
    setState(() {
      _currentQuestion = 0;
      _answers.clear();
      _testCompleted = false;
      _personalityType = '';
    });
  }

  Future<void> _savePersonalityResults() async {
    try {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur : utilisateur non connecté'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Générer les soft skills basées sur la personnalité
      final softSkills = _generateSoftSkillsFromPersonality();
      
      // Sauvegarder les soft skills dans Firestore
      await FirebaseUserService.updateSoftSkills(uid, softSkills);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Profil $_personalityType sauvegardé !\nVos ${softSkills.length} soft skills ont été générées.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Invalider le cache pour recharger les données
        ref.invalidate(currentUserProvider);
        
        // Retourner au profil après 2 secondes
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/profile');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
