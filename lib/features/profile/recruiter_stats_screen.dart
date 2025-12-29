import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class RecruiterStatsScreen extends ConsumerStatefulWidget {
  const RecruiterStatsScreen({super.key});

  @override
  ConsumerState<RecruiterStatsScreen> createState() => _RecruiterStatsScreenState();
}

class _RecruiterStatsScreenState extends ConsumerState<RecruiterStatsScreen> {
  String _selectedPeriod = '30 derniers jours';
  
  final List<String> _periods = [
    '7 derniers jours',
    '30 derniers jours',
    '3 derniers mois',
    '6 derniers mois',
    '1 an',
  ];

  // Données simulées
  final Map<String, dynamic> _stats = {
    'totalViews': 1247,
    'totalApplications': 89,
    'totalMatches': 23,
    'totalHires': 5,
    'conversionRate': 5.6,
    'averageResponseTime': 2.3,
    'topSkills': [
      {'skill': 'Flutter', 'count': 45},
      {'skill': 'React', 'count': 38},
      {'skill': 'Python', 'count': 32},
      {'skill': 'JavaScript', 'count': 28},
      {'skill': 'Node.js', 'count': 25},
    ],
    'applicationsByDay': [
      {'day': 'Lun', 'count': 12},
      {'day': 'Mar', 'count': 18},
      {'day': 'Mer', 'count': 15},
      {'day': 'Jeu', 'count': 22},
      {'day': 'Ven', 'count': 8},
      {'day': 'Sam', 'count': 3},
      {'day': 'Dim', 'count': 1},
    ],
    'matchesBySource': [
      {'source': 'Recherche active', 'count': 8},
      {'source': 'Candidats spontanés', 'count': 6},
      {'source': 'Recommandations', 'count': 4},
      {'source': 'Réseaux sociaux', 'count': 3},
      {'source': 'Autres', 'count': 2},
    ],
  };

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
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => _periods.map((period) => PopupMenuItem(
              value: period,
              child: Text(period),
            )).toList(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedPeriod,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const ThemeToggleIconButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.analytics,
                      size: isTablet ? 60 : 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Text(
                      'Statistiques Recruteur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 28 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isTablet ? 8 : 4),
                    Text(
                      'Analysez vos performances de recrutement',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: isTablet ? 24 : 20),
              
              // Métriques principales
              _buildMainMetrics(),
              
              SizedBox(height: isTablet ? 24 : 20),
              
              // Graphique des candidatures
              _buildApplicationsChart(),
              
              SizedBox(height: isTablet ? 24 : 20),
              
              // Compétences les plus recherchées
              _buildTopSkills(),
              
              SizedBox(height: isTablet ? 24 : 20),
              
              // Sources des matchs
              _buildMatchesBySource(),
              
              SizedBox(height: isTablet ? 24 : 20),
              
              // Actions
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainMetrics() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métriques principales',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isTablet ? 4 : 2,
          crossAxisSpacing: isTablet ? 16 : 12,
          mainAxisSpacing: isTablet ? 16 : 12,
          childAspectRatio: isTablet ? 1.2 : 1.1,
          children: [
            _buildMetricCard(
              'Vues totales',
              _stats['totalViews'].toString(),
              Icons.visibility,
              const Color(0xFF5271FF),
            ),
            _buildMetricCard(
              'Candidatures',
              _stats['totalApplications'].toString(),
              Icons.assignment,
              const Color(0xFF4CAF50),
            ),
            _buildMetricCard(
              'Matchs',
              _stats['totalMatches'].toString(),
              Icons.favorite,
              const Color(0xFFE91E63),
            ),
            _buildMetricCard(
              'Embauches',
              _stats['totalHires'].toString(),
              Icons.work,
              const Color(0xFFFF9800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isTablet ? 32 : 28,
            color: color,
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsChart() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
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
            'Candidatures par jour',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          SizedBox(
            height: isTablet ? 200 : 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _stats['applicationsByDay'].map<Widget>((data) {
                final maxCount = _stats['applicationsByDay']
                    .map((d) => d['count'] as int)
                    .reduce((a, b) => a > b ? a : b);
                final height = (data['count'] as int) / maxCount;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: isTablet ? 40 : 30,
                      height: (isTablet ? 150 : 100) * height,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5271FF),
                        borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                      ),
                    ),
                    SizedBox(height: isTablet ? 8 : 4),
                    Text(
                      data['day'],
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      data['count'].toString(),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSkills() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
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
            'Compétences les plus recherchées',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          ..._stats['topSkills'].map<Widget>((skill) => Padding(
            padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    skill['skill'],
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 8,
                    vertical: isTablet ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5271FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  ),
                  child: Text(
                    '${skill['count']} candidats',
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 10,
                      color: const Color(0xFF5271FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildMatchesBySource() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
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
            'Sources des matchs',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          ..._stats['matchesBySource'].map<Widget>((source) => Padding(
            padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    source['source'],
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 8,
                    vertical: isTablet ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  ),
                  child: Text(
                    '${source['count']} matchs',
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 10,
                      color: const Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showComingSoon(context),
            icon: const Icon(Icons.download),
            label: const Text('Exporter les données'),
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
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showComingSoon(context),
            icon: const Icon(Icons.share),
            label: const Text('Partager'),
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
          ),
        ),
      ],
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
