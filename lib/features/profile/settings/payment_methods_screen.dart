import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': '1',
      'type': 'card',
      'brand': 'Visa',
      'last4': '4242',
      'expiryMonth': '12',
      'expiryYear': '2025',
      'isDefault': false,
      'holderName': 'Jean Dupont',
    },
    {
      'id': '2',
      'type': 'card',
      'brand': 'Mastercard',
      'last4': '5555',
      'expiryMonth': '08',
      'expiryYear': '2026',
      'isDefault': false,
      'holderName': 'Jean Dupont',
    },
    {
      'id': '3',
      'type': 'paypal',
      'email': 'jean.dupont@email.com',
      'isDefault': true,
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
                  Icons.credit_card,
                  size: isTablet ? 60 : 48,
                  color: Colors.white,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  'Méthodes de Paiement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 4),
                Text(
                  'Gérez vos moyens de paiement',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des méthodes de paiement
          Expanded(
            child: _paymentMethods.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    itemCount: _paymentMethods.length,
                    itemBuilder: (context, index) {
                      return _buildPaymentMethodCard(_paymentMethods[index], index);
                    },
                  ),
          ),
          
          // Bouton d'ajout
          Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddPaymentMethodDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une méthode de paiement'),
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
              Icons.credit_card_outlined,
              size: isTablet ? 80 : 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'Aucune méthode de paiement',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              'Ajoutez une méthode de paiement pour gérer vos abonnements',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            ElevatedButton.icon(
              onPressed: () => _showAddPaymentMethodDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une méthode'),
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

  Widget _buildPaymentMethodCard(Map<String, dynamic> method, int index) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: method['isDefault'] 
              ? const Color(0xFF5271FF) 
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: method['isDefault'] ? 2 : 1,
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
            // Header avec actions
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildPaymentIcon(method['type']),
                      SizedBox(width: isTablet ? 16 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getPaymentMethodTitle(method),
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: isTablet ? 4 : 2),
                            Text(
                              _getPaymentMethodSubtitle(method),
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (method['isDefault'])
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
                      'PAR DÉFAUT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 10 : 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handlePaymentMethodAction(value, method),
                  itemBuilder: (context) => [
                    if (!method['isDefault'])
                      const PopupMenuItem(
                        value: 'set_default',
                        child: Row(
                          children: [
                            Icon(Icons.star),
                            SizedBox(width: 8),
                            Text('Définir par défaut'),
                          ],
                        ),
                      ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentIcon(String type) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    IconData iconData;
    Color iconColor;
    
    switch (type) {
      case 'card':
        iconData = Icons.credit_card;
        iconColor = const Color(0xFF5271FF);
      case 'paypal':
        iconData = Icons.account_balance_wallet;
        iconColor = const Color(0xFF0070BA);
      case 'apple_pay':
        iconData = Icons.phone_iphone;
        iconColor = Colors.black;
      case 'google_pay':
        iconData = Icons.phone_android;
        iconColor = const Color(0xFF4285F4);
      default:
        iconData = Icons.payment;
        iconColor = const Color(0xFF5271FF);
    }
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: isTablet ? 24 : 20,
      ),
    );
  }

  String _getPaymentMethodTitle(Map<String, dynamic> method) {
    switch (method['type']) {
      case 'card':
        return '${method['brand']} •••• ${method['last4']}';
      case 'paypal':
        return 'PayPal';
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
      default:
        return 'Méthode de paiement';
    }
  }

  String _getPaymentMethodSubtitle(Map<String, dynamic> method) {
    switch (method['type']) {
      case 'card':
        return 'Expire ${method['expiryMonth']}/${method['expiryYear']}';
      case 'paypal':
        return method['email'] as String;
      case 'apple_pay':
        return 'Paiement via Apple Pay';
      case 'google_pay':
        return 'Paiement via Google Pay';
      default:
        return 'Méthode de paiement';
    }
  }

  void _handlePaymentMethodAction(String action, Map<String, dynamic> method) {
    switch (action) {
      case 'set_default':
        _setAsDefault(method);
      case 'edit':
        _showEditPaymentMethodDialog(context, method);
      case 'delete':
        _showDeletePaymentMethodDialog(context, method);
    }
  }

  void _setAsDefault(Map<String, dynamic> method) {
    setState(() {
      for (final m in _paymentMethods) {
        m['isDefault'] = false;
      }
      method['isDefault'] = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Méthode de paiement définie par défaut'),
        backgroundColor: Color(0xFF5271FF),
      ),
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une méthode de paiement'),
        content: SizedBox(
          width: isTablet ? 500 : double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPaymentOption(
                context,
                'Carte bancaire',
                'Ajouter une carte Visa, Mastercard ou American Express',
                Icons.credit_card,
                () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                context,
                'PayPal',
                'Payer avec votre compte PayPal',
                Icons.account_balance_wallet,
                () => _addPayPalAccount(context),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                context,
                'Apple Pay',
                'Payer avec Apple Pay',
                Icons.phone_iphone,
                () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                context,
                'Google Pay',
                'Payer avec Google Pay',
                Icons.phone_android,
                () => _showComingSoon(context),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5271FF)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  void _showEditPaymentMethodDialog(BuildContext context, Map<String, dynamic> method) {
    _showComingSoon(context);
  }

  void _showDeletePaymentMethodDialog(BuildContext context, Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la méthode de paiement'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette méthode de paiement ?'),
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

  void _addPayPalAccount(BuildContext context) {
    Navigator.pop(context); // Fermer le dialogue précédent
    
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: const Color(0xFF0070BA),
              size: isTablet ? 24 : 20,
            ),
            const SizedBox(width: 8),
            const Text('Ajouter PayPal'),
          ],
        ),
        content: SizedBox(
          width: isTablet ? 500 : double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0070BA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  border: Border.all(
                    color: const Color(0xFF0070BA).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: const Color(0xFF0070BA),
                      size: isTablet ? 20 : 18,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Expanded(
                      child: Text(
                        'Vous allez être redirigé vers PayPal pour vous connecter et autoriser les paiements.',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),
              Text(
                'Avantages de PayPal :',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              _buildPayPalBenefit(
                'Paiements sécurisés',
                'Vos informations bancaires restent privées',
                Icons.security,
              ),
              _buildPayPalBenefit(
                'Paiements rapides',
                'Payer en un clic sans ressaisir vos informations',
                Icons.speed,
              ),
              _buildPayPalBenefit(
                'Protection acheteur',
                'Protection contre les achats non autorisés',
                Icons.shield,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () => _connectPayPal(context),
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Se connecter à PayPal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0070BA),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 12 : 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayPalBenefit(String title, String description, IconData icon) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF0070BA),
            size: isTablet ? 16 : 14,
          ),
          SizedBox(width: isTablet ? 8 : 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _connectPayPal(BuildContext context) {
    Navigator.pop(context); // Fermer le dialogue
    
    // Simulation de la connexion PayPal
    _showPayPalConnectionDialog(context);
  }

  void _showPayPalConnectionDialog(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            SizedBox(
              width: isTablet ? 20 : 16,
              height: isTablet ? 20 : 16,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0070BA)),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Connexion à PayPal'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Redirection vers PayPal...',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'Veuillez vous connecter à votre compte PayPal et autoriser les paiements pour Swipe Em.',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
    
    // Simulation du processus de connexion
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Fermer le dialogue de connexion
      _simulatePayPalSuccess(context);
    });
  }

  void _simulatePayPalSuccess(BuildContext context) {
    // Ajouter PayPal à la liste des méthodes de paiement
    final newPayPalMethod = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'paypal',
      'email': 'jean.dupont@email.com',
      'isDefault': false,
    };
    
    setState(() {
      _paymentMethods.add(newPayPalMethod);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PayPal ajouté avec succès !'),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 3),
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
