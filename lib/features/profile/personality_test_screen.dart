import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class PersonalityTestScreen extends ConsumerStatefulWidget {
  const PersonalityTestScreen({super.key});

  @override
  ConsumerState<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends ConsumerState<PersonalityTestScreen> {
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
    },
    {
      'question': "Lors d'une présentation, vous :",
      'options': [
        'Préparez minutieusement avec des données précises',
        'Improviserez en vous basant sur votre expérience',
        "Collaborerez avec l'audience pour une présentation interactive",
        "Vous concentrez sur l'impact émotionnel"
      ]
    },
    {
      'question': 'Votre approche face au changement est :',
      'options': [
        "Vous l'analysez avant de l'accepter",
        "Vous l'embrassez comme une opportunité",
        "Vous cherchez l'avis des autres d'abord",
        'Vous vous adaptez rapidement'
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
    final option = (_questions[_currentQuestion]['options'] as List)[optionIndex] as String;
    
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
          textAlign: TextAlign.center,
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
                    onPressed: () => _showComingSoon(context),
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
                    child: Text(
                      'Sauvegarder',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
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
    final scores = <String, int>{
      'Analytique': 0,
      'Créatif': 0,
      'Collaboratif': 0,
      'Action': 0,
    };

    for (var i = 0; i < _answers.length; i++) {
      final answer = _answers[i];
      switch (i) {
        case 0: // Leadership
          if (answer == 0) {
            scores['Action'] = scores['Action']! + 1;
          } else if (answer == 1) scores['Collaboratif'] = scores['Collaboratif']! + 1;
          else if (answer == 2) scores['Collaboratif'] = scores['Collaboratif']! + 1;
          else scores['Analytique'] = scores['Analytique']! + 1;
        case 1: // Résolution de problème
          if (answer == 0) {
            scores['Analytique'] = scores['Analytique']! + 1;
          } else if (answer == 1) scores['Créatif'] = scores['Créatif']! + 1;
          else if (answer == 2) scores['Collaboratif'] = scores['Collaboratif']! + 1;
          else scores['Action'] = scores['Action']! + 1;
        case 2: // Environnement
          if (answer == 0) {
            scores['Analytique'] = scores['Analytique']! + 1;
          } else if (answer == 1) scores['Action'] = scores['Action']! + 1;
          else if (answer == 2) scores['Créatif'] = scores['Créatif']! + 1;
          else scores['Collaboratif'] = scores['Collaboratif']! + 1;
        case 3: // Présentation
          if (answer == 0) {
            scores['Analytique'] = scores['Analytique']! + 1;
          } else if (answer == 1) scores['Action'] = scores['Action']! + 1;
          else if (answer == 2) scores['Collaboratif'] = scores['Collaboratif']! + 1;
          else scores['Créatif'] = scores['Créatif']! + 1;
        case 4: // Changement
          if (answer == 0) {
            scores['Analytique'] = scores['Analytique']! + 1;
          } else if (answer == 1) scores['Créatif'] = scores['Créatif']! + 1;
          else if (answer == 2) scores['Collaboratif'] = scores['Collaboratif']! + 1;
          else scores['Action'] = scores['Action']! + 1;
      }
    }

    final maxScore = scores.values.reduce((a, b) => a > b ? a : b);
    final personalityType = scores.entries
        .firstWhere((entry) => entry.value == maxScore)
        .key;

    return personalityType;
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

  void _restartTest() {
    setState(() {
      _currentQuestion = 0;
      _answers.clear();
      _testCompleted = false;
      _personalityType = '';
    });
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
