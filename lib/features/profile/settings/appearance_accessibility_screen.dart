import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/theme_toggle_button.dart';
import 'package:hire_me/providers/theme_provider.dart';

class AppearanceAccessibilityScreen extends ConsumerStatefulWidget {
  const AppearanceAccessibilityScreen({super.key});

  @override
  ConsumerState<AppearanceAccessibilityScreen> createState() => _AppearanceAccessibilityScreenState();
}

class _AppearanceAccessibilityScreenState extends ConsumerState<AppearanceAccessibilityScreen> {
  // États des paramètres d'apparence
  String _selectedTheme = 'Système';
  String _selectedFontSize = 'Moyen';
  String _selectedFontFamily = 'Système';
  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _screenReader = false;
  bool _largeText = false;
  bool _colorBlindSupport = false;
  String _selectedColorScheme = 'Par défaut';

  final List<String> _themes = [
    'Clair',
    'Sombre',
    'Système',
  ];

  final List<String> _fontSizes = [
    'Très petit',
    'Petit',
    'Moyen',
    'Grand',
    'Très grand',
  ];

  final List<String> _fontFamilies = [
    'Système',
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
  ];

  final List<String> _colorSchemes = [
    'Par défaut',
    'Bleu',
    'Vert',
    'Rouge',
    'Violet',
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
            // Icône d'apparence en haut
            Container(
              padding: EdgeInsets.only(
                top: isTablet ? 30 : 20, 
                bottom: isTablet ? 40 : 30
              ),
              child: Icon(
                Icons.palette,
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
                  // Section Thème
                  _buildMenuSection(context, 'THÈME', [
                    _buildThemeSelector(context),
                    _buildMenuItem(context,
                      'Schéma de couleurs',
                      _selectedColorScheme,
                      Icons.color_lens,
                      () => _showColorSchemeSelector(context),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Typographie
                  _buildMenuSection(context, 'TYPOGRAPHIE', [
                    _buildMenuItem(context,
                      'Taille de police',
                      _selectedFontSize,
                      Icons.text_fields,
                      () => _showFontSizeSelector(context),
                    ),
                    _buildMenuItem(context,
                      'Police de caractères',
                      _selectedFontFamily,
                      Icons.font_download,
                      () => _showFontFamilySelector(context),
                    ),
                    _buildAccessibilitySwitch(
                      context,
                      'Texte agrandi',
                      'Augmenter la taille du texte',
                      Icons.zoom_in,
                      _largeText,
                      (value) => setState(() => _largeText = value),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Section Accessibilité
                  _buildMenuSection(context, 'ACCESSIBILITÉ', [
                    _buildAccessibilitySwitch(
                      context,
                      'Contraste élevé',
                      'Améliorer le contraste des couleurs',
                      Icons.contrast,
                      _highContrast,
                      (value) => setState(() => _highContrast = value),
                    ),
                    _buildAccessibilitySwitch(
                      context,
                      'Réduire les animations',
                      'Désactiver les animations',
                      Icons.motion_photos_off,
                      _reduceMotion,
                      (value) => setState(() => _reduceMotion = value),
                    ),
                    _buildAccessibilitySwitch(
                      context,
                      "Lecteur d'écran",
                      "Optimiser pour les lecteurs d'écran",
                      Icons.record_voice_over,
                      _screenReader,
                      (value) => setState(() => _screenReader = value),
                    ),
                    _buildAccessibilitySwitch(
                      context,
                      'Support daltonisme',
                      'Ajuster les couleurs pour le daltonisme',
                      Icons.visibility,
                      _colorBlindSupport,
                      (value) => setState(() => _colorBlindSupport = value),
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
                      "Réinitialiser l'apparence",
                      'Remettre les paramètres par défaut',
                      Icons.restore,
                      () => _showResetDialog(context),
                    ),
                    _buildMenuItem(context,
                      'Exporter les paramètres',
                      'Sauvegarder vos préférences',
                      Icons.download,
                      () => _showComingSoon(context),
                    ),
                    _buildMenuItem(context,
                      'Importer les paramètres',
                      'Restaurer des préférences',
                      Icons.upload,
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

  Widget _buildThemeSelector(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(themeNotifierProvider);
        // final themeNotifier = ref.read(themeNotifierProvider.notifier);
        
        return InkWell(
          onTap: () => _showThemeSelector(context),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 20, 
              vertical: isTablet ? 20 : 16
            ),
            child: Row(
              children: [
                Icon(
                  themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Text(
                    'Thème',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _selectedTheme,
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
      },
    );
  }

  Widget _buildAccessibilitySwitch(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Padding(
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white70,
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white30,
          ),
        ],
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
            'Aperçu des paramètres',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          _buildPreviewItem('Thème', _selectedTheme),
          _buildPreviewItem('Taille de police', _selectedFontSize),
          _buildPreviewItem('Police', _selectedFontFamily),
          _buildPreviewItem('Contraste élevé', _highContrast ? 'Activé' : 'Désactivé'),
          _buildPreviewItem('Animations', _reduceMotion ? 'Réduites' : 'Normales'),
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

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildSelectorBottomSheet(
        context,
        'Sélectionner un thème',
        _themes,
        _selectedTheme,
        (value) => setState(() => _selectedTheme = value),
      ),
    );
  }

  void _showFontSizeSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildSelectorBottomSheet(
        context,
        'Taille de police',
        _fontSizes,
        _selectedFontSize,
        (value) => setState(() => _selectedFontSize = value),
      ),
    );
  }

  void _showFontFamilySelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildSelectorBottomSheet(
        context,
        'Police de caractères',
        _fontFamilies,
        _selectedFontFamily,
        (value) => setState(() => _selectedFontFamily = value),
      ),
    );
  }

  void _showColorSchemeSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildSelectorBottomSheet(
        context,
        'Schéma de couleurs',
        _colorSchemes,
        _selectedColorScheme,
        (value) => setState(() => _selectedColorScheme = value),
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
          title: const Text("Réinitialiser l'apparence"),
          content: const Text(
            "Êtes-vous sûr de vouloir remettre les paramètres d'apparence par défaut ?",
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
                  _selectedTheme = 'Système';
                  _selectedFontSize = 'Moyen';
                  _selectedFontFamily = 'Système';
                  _highContrast = false;
                  _reduceMotion = false;
                  _screenReader = false;
                  _largeText = false;
                  _colorBlindSupport = false;
                  _selectedColorScheme = 'Par défaut';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Paramètres d'apparence réinitialisés"),
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
