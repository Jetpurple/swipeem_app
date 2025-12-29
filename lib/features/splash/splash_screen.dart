import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logo1Controller;
  late AnimationController _logo2Controller;
  late AnimationController _fadeController;
  
  late Animation<double> _logo1Scale;
  late Animation<double> _logo2Opacity;
  late Animation<double> _screenFade;

  @override
  void initState() {
    super.initState();
    
    // Controller pour l'animation du logo1 (scale down)
    _logo1Controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Controller pour l'apparition du logo2
    _logo2Controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Controller pour le fade out final
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Animation de réduction du logo1 (de 1.5x à 0.3x)
    _logo1Scale = Tween<double>(
      begin: 1.5,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _logo1Controller,
      curve: Curves.easeInOutCubic,
    ));
    
    // Animation d'apparition du logo2
    _logo2Opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logo2Controller,
      curve: Curves.easeInCubic,
    ));
    
    // Animation de fade out de tout l'écran
    _screenFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutQuad,
    ));
    
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Attendre un petit moment au début
    await Future<void>.delayed(const Duration(milliseconds: 400));
    
    // Démarrer l'animation du logo1 (réduction)
    await _logo1Controller.forward();
    
    // Démarrer le logo2 immédiatement après la fin du logo1
    await _logo2Controller.forward();
    
    // Attendre que le logo2 soit bien visible
    await Future<void>.delayed(const Duration(milliseconds: 600));
    
    // Fade out de tout l'écran
    await _fadeController.forward();
    
    // Navigation vers la page de login
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _logo1Controller.dispose();
    _logo2Controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A3D),
      body: FadeTransition(
        opacity: _screenFade,
        child: Center(
          child: SizedBox(
            width: 400,
            height: 400,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Logo 1 - qui se réduit et disparaît complètement
                AnimatedBuilder(
                  animation: _logo1Controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 1.0 - _logo1Controller.value,
                      child: Transform.scale(
                        scale: _logo1Scale.value,
                        child: Image.asset(
                          'assets/ui/logo1_withoutbg.png',
                          width: 350,
                          height: 350,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
                
                // Logo 2 - qui apparaît en fondu avec léger scale up
                AnimatedBuilder(
                  animation: _logo2Controller,
                  builder: (context, child) {
                    final scale = 0.85 + (_logo2Opacity.value * 0.15);
                    return Opacity(
                      opacity: _logo2Opacity.value,
                      child: Transform.scale(
                        scale: scale,
                        child: Image.asset(
                          'assets/ui/logo2_dark.png',
                          width: 350,
                          height: 350,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

