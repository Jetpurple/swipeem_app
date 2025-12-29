import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class SubscriptionBillingScreen extends ConsumerWidget {
  const SubscriptionBillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Icône de facturation en haut
            Container(
              padding: EdgeInsets.only(
                top: isTablet ? 30 : 20, 
                bottom: isTablet ? 40 : 30
              ),
              child: Icon(
                Icons.payment,
                size: isTablet ? 80 : 60,
                color: const Color(0xFF5271FF),
              ),
            ),
            
            // Sections de menu
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 40 : 20,
              ),
              child: Column(
                children: [
                  // Section Abonnement actuel
                  _buildCurrentSubscriptionCard(context),
                  
                  const SizedBox(height: 20),
                  
                  // Section Plans disponibles
                  _buildMenuSection(context, 'PLANS DISPONIBLES', [
                    _buildPlanCard(context, 'Gratuit', '0€/mois', [
                      '5 swipes par jour',
                      'Profil de base',
                      'Messages limités',
                    ], false, () => _showComingSoon(context)),
                    _buildPlanCard(context, 'Premium', '9.99€/mois', [
                      'Swipes illimités',
                      'Profil premium',
                      'Messages illimités',
                      'Filtres avancés',
                    ], true, () => _showComingSoon(context)),
                    _buildPlanCard(context, 'Pro', '19.99€/mois', [
                      'Tout Premium',
                      'Statistiques avancées',
                      'Support prioritaire',
                      'Fonctionnalités exclusives',
                    ], false, () => _showComingSoon(context)),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Facturation
                  _buildMenuSection(context, 'FACTURATION', [
                    _buildMenuItem(context,
                      'Méthode de paiement',
                      'Gérer vos moyens de paiement',
                      Icons.credit_card,
                      () => context.go('/settings/payment-methods'),
                    ),
                    _buildMenuItem(context,
                      'Historique des factures',
                      'Voir toutes vos factures',
                      Icons.receipt_long,
                      () => context.go('/settings/billing-history'),
                    ),
                    _buildMenuItem(context,
                      'Télécharger les factures',
                      'Exporter vos factures',
                      Icons.download,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Informations fiscales',
                      'Gérer vos informations fiscales',
                      Icons.account_balance,
                      () => _showComingSoon(context),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Gestion
                  _buildMenuSection(context, 'GESTION', [
                    _buildMenuItem(context,
                      'Changer de plan',
                      'Modifier votre abonnement',
                      Icons.swap_horiz,
                      () => context.go('/settings/change-plan'),
                    ),
                    _buildMenuItem(context,
                      "Gestion d'abonnement",
                      'Pause, annulation et plus',
                      Icons.settings,
                      () => context.go('/settings/subscription-management'),
                    ),
                    _buildMenuItem(context,
                      'Remboursement',
                      'Demander un remboursement',
                      Icons.monetization_on,
                      () => _showComingSoon(context),
                    ),
                  ]),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.white,
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                'Abonnement actuel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'Plan Gratuit',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 4),
          Text(
            '0€/mois',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isTablet ? 16 : 14,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showComingSoon(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5271FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    ),
                  ),
                  child: Text(
                    'Passer à Premium',
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
    );
  }

  Widget _buildPlanCard(
    BuildContext context, 
    String title, 
    String price, 
    List<String> features, 
    bool isRecommended,
    VoidCallback onTap,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRecommended ? const Color(0xFF5271FF) : Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: isRecommended ? const Color(0xFF5271FF) : Colors.grey[300]!,
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isRecommended ? Colors.white : Colors.black,
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isRecommended)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                      ),
                      child: Text(
                        'RECOMMANDÉ',
                        style: TextStyle(
                          color: const Color(0xFF5271FF),
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: isTablet ? 8 : 4),
              Text(
                price,
                style: TextStyle(
                  color: isRecommended ? Colors.white70 : Colors.grey[600],
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              ...features.map((feature) => Padding(
                padding: EdgeInsets.only(bottom: isTablet ? 6 : 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: isRecommended ? Colors.white : const Color(0xFF5271FF),
                      size: isTablet ? 20 : 16,
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: isRecommended ? Colors.white : Colors.black87,
                          fontSize: isTablet ? 14 : 12,
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

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isTablet ? 8 : 4,
            bottom: isTablet ? 12 : 8,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF5271FF),
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
          child: Column(
            children: items
                .expand((item) => [
                      item,
                      if (item != items.last)
                        const Divider(
                          color: Colors.white,
                          height: 1,
                          thickness: 0.5,
                        ),
                    ])
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData icon,
    VoidCallback onTap,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20, 
          vertical: isTablet ? 20 : 16
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
          ],
        ),
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

  void _showCancelSubscriptionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Annuler l'abonnement"),
          content: const Text(
            "Êtes-vous sûr de vouloir annuler votre abonnement ? Vous perdrez l'accès aux fonctionnalités premium.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showComingSoon(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}
