import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';

class LanguageRegionScreen extends ConsumerStatefulWidget {
  const LanguageRegionScreen({super.key});

  @override
  ConsumerState<LanguageRegionScreen> createState() => _LanguageRegionScreenState();
}

class _LanguageRegionScreenState extends ConsumerState<LanguageRegionScreen> {
  String _selectedLanguage = 'Français';
  String _selectedRegion = 'France';
  String _selectedDateFormat = 'DD/MM/YYYY';
  String _selectedTimeFormat = '24h';
  String _selectedCurrency = 'EUR (€)';
  String _selectedTimezone = 'Europe/Paris';

  final List<Map<String, String>> _languages = [
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
  ];

  final List<Map<String, String>> _regions = [
    {'code': 'FR', 'name': 'France', 'flag': '🇫🇷'},
    {'code': 'US', 'name': 'United States', 'flag': '🇺🇸'},
    {'code': 'GB', 'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'code': 'CA', 'name': 'Canada', 'flag': '🇨🇦'},
    {'code': 'DE', 'name': 'Germany', 'flag': '🇩🇪'},
    {'code': 'ES', 'name': 'Spain', 'flag': '🇪🇸'},
    {'code': 'IT', 'name': 'Italy', 'flag': '🇮🇹'},
    {'code': 'PT', 'name': 'Portugal', 'flag': '🇵🇹'},
  ];

  final List<String> _dateFormats = [
    'DD/MM/YYYY',
    'MM/DD/YYYY',
    'YYYY-MM-DD',
    'DD-MM-YYYY',
  ];

  final List<String> _timeFormats = [
    '24h',
    '12h (AM/PM)',
  ];

  final List<Map<String, String>> _currencies = [
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'USD', 'symbol': r'$', 'name': 'US Dollar'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'CAD', 'symbol': r'C$', 'name': 'Canadian Dollar'},
  ];

  final List<Map<String, String>> _timezones = [
    {'code': 'Europe/Paris', 'name': 'Paris (UTC+1)'},
    {'code': 'America/New_York', 'name': 'New York (UTC-5)'},
    {'code': 'America/Los_Angeles', 'name': 'Los Angeles (UTC-8)'},
    {'code': 'Europe/London', 'name': 'London (UTC+0)'},
    {'code': 'Asia/Tokyo', 'name': 'Tokyo (UTC+9)'},
    {'code': 'Australia/Sydney', 'name': 'Sydney (UTC+10)'},
  ];

  @override
  Widget build(BuildContext context) {
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
            // Icône de langue en haut
            Container(
              padding: EdgeInsets.only(
                top: isTablet ? 30 : 20, 
                bottom: isTablet ? 40 : 30
              ),
              child: Icon(
                Icons.language,
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
                  // Section Langue
                  _buildMenuSection(context, 'LANGUE', [
                    _buildLanguageSelector(context),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Région
                  _buildMenuSection(context, 'RÉGION', [
                    _buildRegionSelector(context),
                    _buildMenuItem(context,
                      'Fuseau horaire',
                      _selectedTimezone,
                      Icons.access_time,
                      () => _showTimezoneSelector(context),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Format
                  _buildMenuSection(context, 'FORMAT', [
                    _buildMenuItem(context,
                      'Format de date',
                      _selectedDateFormat,
                      Icons.calendar_today,
                      () => _showDateFormatSelector(context),
                    ),
                    _buildMenuItem(context,
                      "Format d'heure",
                      _selectedTimeFormat,
                      Icons.schedule,
                      () => _showTimeFormatSelector(context),
                    ),
                    _buildMenuItem(context,
                      'Devise',
                      _selectedCurrency,
                      Icons.attach_money,
                      () => _showCurrencySelector(context),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Aperçu
                  _buildMenuSection(context, 'APERÇU', [
                    _buildPreviewCard(context),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Gestion
                  _buildMenuSection(context, 'GESTION', [
                    _buildMenuItem(context,
                      'Détecter automatiquement',
                      'Utiliser les paramètres du système',
                      Icons.auto_awesome,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Réinitialiser les paramètres',
                      'Remettre les paramètres par défaut',
                      Icons.restore,
                      () => _showResetDialog(context),
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

  Widget _buildLanguageSelector(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return InkWell(
      onTap: () => _showLanguageSelector(context),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20, 
          vertical: isTablet ? 20 : 16
        ),
        child: Row(
          children: [
            Icon(
              Icons.language,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Text(
                "Langue de l'interface",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              _selectedLanguage,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
            SizedBox(width: isTablet ? 8 : 6),
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

  Widget _buildRegionSelector(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return InkWell(
      onTap: () => _showRegionSelector(context),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20, 
          vertical: isTablet ? 20 : 16
        ),
        child: Row(
          children: [
            Icon(
              Icons.public,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Text(
                'Région',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              _selectedRegion,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
            SizedBox(width: isTablet ? 8 : 6),
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
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
            SizedBox(width: isTablet ? 8 : 6),
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

  Widget _buildPreviewCard(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aperçu des formats',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          _buildPreviewItem('Date', _getFormattedDate()),
          _buildPreviewItem('Heure', _getFormattedTime()),
          _buildPreviewItem('Devise', _getFormattedCurrency()),
          _buildPreviewItem('Fuseau horaire', _selectedTimezone),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 6 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    switch (_selectedDateFormat) {
      case 'DD/MM/YYYY':
        return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      case 'MM/DD/YYYY':
        return '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
      case 'YYYY-MM-DD':
        return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      case 'DD-MM-YYYY':
        return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      default:
        return '${now.day}/${now.month}/${now.year}';
    }
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    if (_selectedTimeFormat == '24h') {
      return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
      final period = now.hour < 12 ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';
    }
  }

  String _getFormattedCurrency() {
    final currency = _currencies.firstWhere(
      (c) => c['name'] == _selectedCurrency.split(' ')[0],
      orElse: () => _currencies[0],
    );
    return '${currency['symbol']} 1,234.56';
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildSelectorBottomSheet(
        context,
        'Sélectionner une langue',
        _languages.map((lang) => '${lang['flag']} ${lang['name']}').toList(),
        _selectedLanguage,
        (value) => setState(() => _selectedLanguage = value),
      ),
    );
  }

  void _showRegionSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildSelectorBottomSheet(
        context,
        'Sélectionner une région',
        _regions.map((region) => '${region['flag']} ${region['name']}').toList(),
        _selectedRegion,
        (value) => setState(() => _selectedRegion = value),
      ),
    );
  }

  void _showDateFormatSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildSelectorBottomSheet(
        context,
        'Format de date',
        _dateFormats,
        _selectedDateFormat,
        (value) => setState(() => _selectedDateFormat = value),
      ),
    );
  }

  void _showTimeFormatSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildSelectorBottomSheet(
        context,
        "Format d'heure",
        _timeFormats,
        _selectedTimeFormat,
        (value) => setState(() => _selectedTimeFormat = value),
      ),
    );
  }

  void _showCurrencySelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildSelectorBottomSheet(
        context,
        'Devise',
        _currencies.map((c) => '${c['symbol']} ${c['name']} (${c['code']})').toList(),
        _selectedCurrency,
        (value) => setState(() => _selectedCurrency = value),
      ),
    );
  }

  void _showTimezoneSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildSelectorBottomSheet(
        context,
        'Fuseau horaire',
        _timezones.map((tz) => tz['name']!).toList(),
        _selectedTimezone,
        (value) => setState(() => _selectedTimezone = value),
      ),
    );
  }

  Widget _buildSelectorBottomSheet(
    BuildContext context,
    String title,
    List<String> options,
    String currentValue,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...options.map((option) => ListTile(
            title: Text(option),
            trailing: option == currentValue ? const Icon(Icons.check, color: Color(0xFF5271FF)) : null,
            onTap: () {
              onChanged(option);
              Navigator.pop(context);
            },
          )),
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

  void _showResetDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Réinitialiser les paramètres'),
          content: const Text(
            'Êtes-vous sûr de vouloir remettre les paramètres de langue et région par défaut ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedLanguage = 'Français';
                  _selectedRegion = 'France';
                  _selectedDateFormat = 'DD/MM/YYYY';
                  _selectedTimeFormat = '24h';
                  _selectedCurrency = 'EUR (€)';
                  _selectedTimezone = 'Europe/Paris';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paramètres réinitialisés'),
                    backgroundColor: Color(0xFF5271FF),
                  ),
                );
              },
              child: const Text('Réinitialiser'),
            ),
          ],
        );
      },
    );
  }
}
