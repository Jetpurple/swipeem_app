import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class SubscriptionManagementScreen extends ConsumerStatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  ConsumerState<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends ConsumerState<SubscriptionManagementScreen> {
  String _subscriptionStatus = 'active'; // active, paused, cancelled
  DateTime? _nextBillingDate;
  DateTime? _pauseEndDate;
  String _pauseReason = '';
  
  final List<String> _pauseReasons = [
    'Temporairement indisponible',
    'Budget limité',
    "Test d'autres services",
    'Problème technique',
    'Autre raison',
  ];

  @override
  void initState() {
    super.initState();
    _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings/subscription-billing'),
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
                  Icons.settings,
                  size: isTablet ? 60 : 48,
                  color: Colors.white,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  "Gestion d'Abonnement",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 4),
                Text(
                  'Gérez votre abonnement et vos préférences',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Statut de l'abonnement
          _buildSubscriptionStatusCard(),
          
          // Actions disponibles
          Expanded(
            child: _buildActionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatusCard() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (_subscriptionStatus) {
      case 'active':
        statusColor = const Color(0xFF4CAF50);
        statusText = 'Actif';
        statusIcon = Icons.check_circle;
      case 'paused':
        statusColor = const Color(0xFFFF9800);
        statusText = 'En pause';
        statusIcon = Icons.pause_circle;
      case 'cancelled':
        statusColor = const Color(0xFFF44336);
        statusText = 'Annulé';
        statusIcon = Icons.cancel;
      default:
        statusColor = const Color(0xFF9E9E9E);
        statusText = 'Inconnu';
        statusIcon = Icons.help;
    }
    
    return Container(
      margin: EdgeInsets.all(isTablet ? 20 : 16),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: statusColor,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: isTablet ? 32 : 28,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Statut de l'abonnement",
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (_subscriptionStatus == 'active' && _nextBillingDate != null) ...[
            SizedBox(height: isTablet ? 16 : 12),
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    size: isTablet ? 20 : 18,
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                  Text(
                    'Prochain paiement: ${_formatDate(_nextBillingDate!)}',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (_subscriptionStatus == 'paused' && _pauseEndDate != null) ...[
            SizedBox(height: isTablet ? 16 : 12),
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pause,
                    color: const Color(0xFFFF9800),
                    size: isTablet ? 20 : 18,
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                  Expanded(
                    child: Text(
                      'Reprise automatique: ${_formatDate(_pauseEndDate!)}',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsList() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    var actions = <Map<String, dynamic>>[];
    
    switch (_subscriptionStatus) {
      case 'active':
        actions = [
          {
            'title': 'Mettre en pause',
            'subtitle': 'Suspendre temporairement votre abonnement',
            'icon': Icons.pause,
            'color': const Color(0xFFFF9800),
            'action': _showPauseSubscriptionDialog,
          },
          {
            'title': "Annuler l'abonnement",
            'subtitle': 'Arrêter définitivement votre abonnement',
            'icon': Icons.cancel,
            'color': const Color(0xFFF44336),
            'action': _showCancelSubscriptionDialog,
          },
        ];
      case 'paused':
        actions = [
          {
            'title': "Reprendre l'abonnement",
            'subtitle': 'Réactiver votre abonnement immédiatement',
            'icon': Icons.play_arrow,
            'color': const Color(0xFF4CAF50),
            'action': _resumeSubscription,
          },
          {
            'title': "Annuler l'abonnement",
            'subtitle': 'Arrêter définitivement votre abonnement',
            'icon': Icons.cancel,
            'color': const Color(0xFFF44336),
            'action': _showCancelSubscriptionDialog,
          },
        ];
      case 'cancelled':
        actions = [
          {
            'title': "Réactiver l'abonnement",
            'subtitle': 'Souscrire à nouveau à un abonnement',
            'icon': Icons.refresh,
            'color': const Color(0xFF4CAF50),
            'action': _reactivateSubscription,
          },
        ];
    }
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return _buildActionCard(actions[index]);
      },
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
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
      child: InkWell(
        onTap: action['action'] as VoidCallback,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 8),
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
                child: Icon(
                  action['icon'] as IconData,
                  color: action['color'] as Color,
                  size: isTablet ? 28 : 24,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action['title'] as String,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      action['subtitle'] as String,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: isTablet ? 28 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPauseSubscriptionDialog() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mettre en pause l'abonnement"),
        content: SizedBox(
          width: isTablet ? 500 : double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choisissez la raison de la pause :'),
              const SizedBox(height: 16),
              ..._pauseReasons.map((reason) => RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _pauseReason,
                onChanged: (value) => setState(() => _pauseReason = value!),
              )),
              const SizedBox(height: 16),
              const Text(
                'Votre abonnement sera suspendu et reprendra automatiquement dans 30 jours.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
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
              _pauseSubscription();
            },
            child: const Text('Mettre en pause'),
          ),
        ],
      ),
    );
  }

  void _showCancelSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Annuler l'abonnement"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir annuler votre abonnement ?'),
            SizedBox(height: 16),
            Text('Cette action est irréversible et vous perdrez :'),
            SizedBox(height: 8),
            Text('• Accès aux fonctionnalités premium'),
            Text('• Statistiques avancées'),
            Text('• Support prioritaire'),
            SizedBox(height: 16),
            Text(
              'Vous pourrez toujours réactiver votre abonnement plus tard.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelSubscription();
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Confirmer l'annulation"),
          ),
        ],
      ),
    );
  }

  void _pauseSubscription() {
    setState(() {
      _subscriptionStatus = 'paused';
      _pauseEndDate = DateTime.now().add(const Duration(days: 30));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abonnement mis en pause avec succès'),
        backgroundColor: Color(0xFFFF9800),
      ),
    );
  }

  void _resumeSubscription() {
    setState(() {
      _subscriptionStatus = 'active';
      _pauseEndDate = null;
      _pauseReason = '';
      _nextBillingDate = DateTime.now().add(const Duration(days: 30));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abonnement repris avec succès'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _cancelSubscription() {
    setState(() {
      _subscriptionStatus = 'cancelled';
      _pauseEndDate = null;
      _pauseReason = '';
      _nextBillingDate = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abonnement annulé'),
        backgroundColor: Color(0xFFF44336),
      ),
    );
  }

  void _reactivateSubscription() {
    setState(() {
      _subscriptionStatus = 'active';
      _nextBillingDate = DateTime.now().add(const Duration(days: 30));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abonnement réactivé avec succès'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
