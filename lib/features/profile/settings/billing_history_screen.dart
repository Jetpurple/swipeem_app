import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class BillingHistoryScreen extends ConsumerStatefulWidget {
  const BillingHistoryScreen({super.key});

  @override
  ConsumerState<BillingHistoryScreen> createState() => _BillingHistoryScreenState();
}

class _BillingHistoryScreenState extends ConsumerState<BillingHistoryScreen> {
  String _selectedFilter = 'Toutes';
  
  final List<String> _filters = [
    'Toutes',
    'Payées',
    'En attente',
    'Échouées',
    'Remboursées',
  ];

  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 'INV-2024-001',
      'date': '2024-01-15',
      'amount': 9.99,
      'currency': 'EUR',
      'status': 'paid',
      'plan': 'Premium',
      'period': 'Janvier 2024',
      'description': 'Abonnement Premium - Janvier 2024',
      'paymentMethod': 'PayPal',
      'paymentMethodType': 'paypal',
      'downloadUrl': 'https://example.com/invoice-001.pdf',
    },
    {
      'id': 'INV-2023-012',
      'date': '2023-12-15',
      'amount': 9.99,
      'currency': 'EUR',
      'status': 'paid',
      'plan': 'Premium',
      'period': 'Décembre 2023',
      'description': 'Abonnement Premium - Décembre 2023',
      'paymentMethod': 'Visa •••• 4242',
      'paymentMethodType': 'card',
      'downloadUrl': 'https://example.com/invoice-012.pdf',
    },
    {
      'id': 'INV-2023-011',
      'date': '2023-11-15',
      'amount': 9.99,
      'currency': 'EUR',
      'status': 'paid',
      'plan': 'Premium',
      'period': 'Novembre 2023',
      'description': 'Abonnement Premium - Novembre 2023',
      'paymentMethod': 'PayPal',
      'paymentMethodType': 'paypal',
      'downloadUrl': 'https://example.com/invoice-011.pdf',
    },
    {
      'id': 'INV-2023-010',
      'date': '2023-10-15',
      'amount': 9.99,
      'currency': 'EUR',
      'status': 'failed',
      'plan': 'Premium',
      'period': 'Octobre 2023',
      'description': 'Abonnement Premium - Octobre 2023',
      'paymentMethod': 'Visa •••• 4242',
      'paymentMethodType': 'card',
      'downloadUrl': null,
    },
    {
      'id': 'INV-2023-009',
      'date': '2023-09-15',
      'amount': 9.99,
      'currency': 'EUR',
      'status': 'paid',
      'plan': 'Premium',
      'period': 'Septembre 2023',
      'description': 'Abonnement Premium - Septembre 2023',
      'paymentMethod': 'PayPal',
      'paymentMethodType': 'paypal',
      'downloadUrl': 'https://example.com/invoice-009.pdf',
    },
    {
      'id': 'INV-2023-008',
      'date': '2023-08-15',
      'amount': 19.99,
      'currency': 'EUR',
      'status': 'paid',
      'plan': 'Pro',
      'period': 'Août 2023',
      'description': 'Abonnement Pro - Août 2023',
      'paymentMethod': 'Mastercard •••• 5555',
      'paymentMethodType': 'card',
      'downloadUrl': 'https://example.com/invoice-008.pdf',
    },
    {
      'id': 'INV-2023-007',
      'date': '2023-07-15',
      'amount': 9.99,
      'currency': 'EUR',
      'status': 'refunded',
      'plan': 'Premium',
      'period': 'Juillet 2023',
      'description': 'Abonnement Premium - Juillet 2023',
      'paymentMethod': 'PayPal',
      'paymentMethodType': 'paypal',
      'downloadUrl': 'https://example.com/invoice-007.pdf',
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
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleFilterAction,
            itemBuilder: (context) => _filters.map((filter) => PopupMenuItem(
              value: filter,
              child: Text(filter),
            )).toList(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedFilter,
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
                  Icons.receipt_long,
                  size: isTablet ? 60 : 48,
                  color: Colors.white,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  'Historique des Factures',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 4),
                Text(
                  'Consultez et téléchargez vos factures',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Statistiques
          _buildStatsSection(),
          
          // Liste des factures
          Expanded(
            child: _buildInvoicesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    final totalPaid = _invoices
        .where((invoice) => invoice['status'] == 'paid')
        .fold(0.0, (sum, invoice) => sum + (invoice['amount'] as double));
    
    final totalInvoices = _invoices.length;
    final paidInvoices = _invoices.where((invoice) => invoice['status'] == 'paid').length;
    
    return Container(
      margin: EdgeInsets.all(isTablet ? 20 : 16),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total payé',
              '${totalPaid.toStringAsFixed(2)} €',
              Icons.euro,
              const Color(0xFF4CAF50),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Factures payées',
              '$paidInvoices/$totalInvoices',
              Icons.check_circle,
              const Color(0xFF5271FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: isTablet ? 24 : 20,
        ),
        SizedBox(height: isTablet ? 8 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isTablet ? 4 : 2),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoicesList() {
    final filteredInvoices = _getFilteredInvoices();
    
    if (filteredInvoices.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width > 600 ? 20 : 16),
      itemCount: filteredInvoices.length,
      itemBuilder: (context, index) {
        return _buildInvoiceCard(filteredInvoices[index]);
      },
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
              Icons.receipt_outlined,
              size: isTablet ? 80 : 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'Aucune facture trouvée',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              'Vos factures apparaîtront ici une fois que vous aurez souscrit à un abonnement',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
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
            // Header avec statut
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice['description'] as String,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        '${invoice['date']} • ${invoice['id']}',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(invoice['status'] as String),
              ],
            ),
            
            SizedBox(height: isTablet ? 16 : 12),
            
            // Détails
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Montant',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        '${invoice['amount']} ${invoice['currency']}',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Méthode de paiement',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Row(
                        children: [
                          _buildPaymentMethodIcon(invoice['paymentMethodType'] as String?),
                          SizedBox(width: isTablet ? 8 : 6),
                          Expanded(
                            child: Text(
                              invoice['paymentMethod'] as String,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isTablet ? 16 : 12),
            
            // Actions
            Row(
              children: [
                if (invoice['downloadUrl'] != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadInvoice(invoice),
                      icon: const Icon(Icons.download),
                      label: const Text('Télécharger'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5271FF),
                        side: const BorderSide(color: Color(0xFF5271FF)),
                      ),
                    ),
                  ),
                if (invoice['downloadUrl'] != null)
                  SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewInvoice(invoice),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Voir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
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

  Widget _buildStatusBadge(String status) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    Color backgroundColor;
    Color textColor;
    String statusText;
    
    switch (status) {
      case 'paid':
        backgroundColor = const Color(0xFF4CAF50);
        textColor = Colors.white;
        statusText = 'Payée';
      case 'pending':
        backgroundColor = const Color(0xFFFF9800);
        textColor = Colors.white;
        statusText = 'En attente';
      case 'failed':
        backgroundColor = const Color(0xFFF44336);
        textColor = Colors.white;
        statusText = 'Échouée';
      case 'refunded':
        backgroundColor = const Color(0xFF9E9E9E);
        textColor = Colors.white;
        statusText = 'Remboursée';
      default:
        backgroundColor = const Color(0xFF9E9E9E);
        textColor = Colors.white;
        statusText = 'Inconnu';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: isTablet ? 12 : 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredInvoices() {
    if (_selectedFilter == 'Toutes') {
      return _invoices;
    }
    
    String statusFilter;
    switch (_selectedFilter) {
      case 'Payées':
        statusFilter = 'paid';
      case 'En attente':
        statusFilter = 'pending';
      case 'Échouées':
        statusFilter = 'failed';
      case 'Remboursées':
        statusFilter = 'refunded';
      default:
        return _invoices;
    }
    
    return _invoices.where((invoice) => invoice['status'] == statusFilter).toList();
  }

  void _handleFilterAction(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _downloadInvoice(Map<String, dynamic> invoice) {
    _showComingSoon(context);
  }

  void _viewInvoice(Map<String, dynamic> invoice) {
    _showComingSoon(context);
  }

  Widget _buildPaymentMethodIcon(String? paymentMethodType) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    IconData iconData;
    Color iconColor;
    
    switch (paymentMethodType) {
      case 'paypal':
        iconData = Icons.account_balance_wallet;
        iconColor = const Color(0xFF0070BA);
      case 'card':
        iconData = Icons.credit_card;
        iconColor = const Color(0xFF5271FF);
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
      padding: EdgeInsets.all(isTablet ? 6 : 4),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: isTablet ? 16 : 14,
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
