import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class ChangePlanScreen extends ConsumerStatefulWidget {
  const ChangePlanScreen({super.key});

  @override
  ConsumerState<ChangePlanScreen> createState() => _ChangePlanScreenState();
}

class _ChangePlanScreenState extends ConsumerState<ChangePlanScreen> {
  String _currentPlan = 'Gratuit';
  String? _selectedPlan;
  
  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'free',
      'name': 'Gratuit',
      'price': 0.0,
      'currency': 'EUR',
      'period': 'mois',
      'description': 'Parfait pour commencer',
      'features': [
        '5 swipes par jour',
        'Profil de base',
        'Messages limités',
        'Support par email',
      ],
      'isCurrent': true,
      'isPopular': false,
    },
    {
      'id': 'premium',
      'name': 'Premium',
      'price': 9.99,
      'currency': 'EUR',
      'period': 'mois',
      'description': 'Le plus populaire',
      'features': [
        'Swipes illimités',
        'Profil premium',
        'Messages illimités',
        'Filtres avancés',
        'Statistiques de base',
        'Support prioritaire',
      ],
      'isCurrent': false,
      'isPopular': true,
    },
    {
      'id': 'pro',
      'name': 'Pro',
      'price': 19.99,
      'currency': 'EUR',
      'period': 'mois',
      'description': 'Pour les professionnels',
      'features': [
        'Tout Premium',
        'Statistiques avancées',
        'Support prioritaire',
        'Fonctionnalités exclusives',
        'API access',
        'Intégrations avancées',
      ],
      'isCurrent': false,
      'isPopular': false,
    },
  ];

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
                  Icons.swap_horiz,
                  size: isTablet ? 60 : 48,
                  color: Colors.white,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  'Changer de Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 4),
                Text(
                  'Choisissez le plan qui vous convient le mieux',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Plan actuel
          _buildCurrentPlanCard(),
          
          // Liste des plans
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                return _buildPlanCard(_plans[index]);
              },
            ),
          ),
          
          // Bouton de confirmation
          if (_selectedPlan != null)
            _buildConfirmationButton(),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      margin: EdgeInsets.all(isTablet ? 20 : 16),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: const Color(0xFF5271FF),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: const Color(0xFF5271FF),
            size: isTablet ? 32 : 28,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan actuel',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: isTablet ? 4 : 2),
                Text(
                  _currentPlan,
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSelected = _selectedPlan == plan['id'];
    final isCurrent = plan['isCurrent'] as bool;
    
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isSelected 
            ? const Color(0xFF5271FF).withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: isSelected 
              ? const Color(0xFF5271FF)
              : isCurrent
                  ? const Color(0xFF4CAF50)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: isSelected || isCurrent ? 2 : 1,
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
        onTap: isCurrent ? null : () => _selectPlan(plan['id'] as String),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan['name'] as String,
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (plan['isPopular'] as bool) ...[
                              SizedBox(width: isTablet ? 8 : 6),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 8 : 6,
                                  vertical: isTablet ? 4 : 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5271FF),
                                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                                ),
                                child: Text(
                                  'POPULAIRE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 10 : 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: isTablet ? 4 : 2),
                        Text(
                          plan['description'] as String,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 8 : 6,
                            vertical: isTablet ? 4 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                          ),
                          child: Text(
                            'ACTUEL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 10 : 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isSelected && !isCurrent)
                        Icon(
                          Icons.radio_button_checked,
                          color: const Color(0xFF5271FF),
                          size: isTablet ? 24 : 20,
                        ),
                      if (!isSelected && !isCurrent)
                        Icon(
                          Icons.radio_button_unchecked,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                          size: isTablet ? 24 : 20,
                        ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: isTablet ? 16 : 12),
              
              // Prix
              Row(
                children: [
                  Text(
                    '${plan['price']} ${plan['currency']}',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '/${plan['period']}',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isTablet ? 16 : 12),
              
              // Fonctionnalités
              ...(plan['features'] as List).map<Widget>((feature) => Padding(
                padding: EdgeInsets.only(bottom: isTablet ? 6 : 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: const Color(0xFF5271FF),
                      size: isTablet ? 20 : 16,
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    Expanded(
                      child: Text(
                        feature as String,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationButton() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final selectedPlanData = _plans.firstWhere((plan) => plan['id'] == _selectedPlan);
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Résumé du changement
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: const Color(0xFF5271FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: const Color(0xFF5271FF),
                  size: isTablet ? 20 : 18,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: Text(
                    'Vous allez passer de $_currentPlan à ${selectedPlanData['name']}',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isTablet ? 16 : 12),
          
          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _selectedPlan = null),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                  child: const Text('Annuler'),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _confirmPlanChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5271FF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                  child: const Text('Confirmer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectPlan(String planId) {
    setState(() {
      _selectedPlan = planId;
    });
  }

  void _confirmPlanChange() {
    if (_selectedPlan == null) return;
    
    final selectedPlanData = _plans.firstWhere((plan) => plan['id'] == _selectedPlan);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le changement de plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vous allez passer de $_currentPlan à ${selectedPlanData['name']}.'),
            const SizedBox(height: 16),
            Text(
              'Nouveau prix: ${selectedPlanData['price']} ${selectedPlanData['currency']}/${selectedPlanData['period']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Le changement prendra effet immédiatement.'),
            const SizedBox(height: 16),
            const Text('Choisissez votre méthode de paiement :'),
            const SizedBox(height: 8),
            _buildPaymentMethodSelection(),
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
              _processPlanChange();
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Column(
      children: [
        _buildPaymentOption(
          'Visa •••• 4242',
          Icons.credit_card,
          const Color(0xFF5271FF),
          true,
        ),
        const SizedBox(height: 8),
        _buildPaymentOption(
          'PayPal',
          Icons.account_balance_wallet,
          const Color(0xFF0070BA),
          false,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, Color color, bool isSelected) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
        border: Border.all(
          color: isSelected ? color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: isTablet ? 20 : 18,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: color,
              size: isTablet ? 20 : 18,
            ),
        ],
      ),
    );
  }

  void _processPlanChange() {
    // Simulation du changement de plan
    setState(() {
      _currentPlan = _plans.firstWhere((plan) => plan['id'] == _selectedPlan)['name'] as String;
      _selectedPlan = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plan changé avec succès !'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }
}
