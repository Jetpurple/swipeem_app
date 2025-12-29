import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/services/auth_service.dart';
import 'package:hire_me/core/theme/color_schemes.dart';
import 'package:linkedin_login/linkedin_login.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

// Design constants
class _LoginDesign {
  static const double inputRadius = 30.0;
  static const double buttonRadius = 30.0;
  static const double maxContentWidth = 360.0;
  
  // Colors
  static const Color forgotPasswordColor = Color(0xFF666666);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color dividerTextColor = Color(0xFF999999);
  static Color get signUpColor => accentBlue;
  
  // Gradients - using app colors
  static List<Color> get backgroundGradient => [
    primaryBlue.withOpacity(0.95), // Dark blue at top
    accentBlue.withOpacity(0.85), // Accent blue
    lightBlue.withOpacity(0.75), // Light blue
    lightBlue.withOpacity(0.65), // Lighter blue at bottom
  ];
  
  static const List<double> backgroundGradientStops = [0.0, 0.3, 0.7, 1.0];
  
  static List<Color> get buttonGradient => [
    accentBlue, // Accent blue
    lightBlue, // Light blue
  ];
  
  // Shadows - modern and subtle
  static BoxShadow get inputShadow => BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 12,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );
  
  static BoxShadow get buttonShadow => BoxShadow(
    color: accentBlue.withOpacity(0.35),
    blurRadius: 16,
    offset: const Offset(0, 6),
    spreadRadius: 0,
  );
  
  static BoxShadow get socialButtonShadow => BoxShadow(
    color: Colors.black.withOpacity(0.12),
    blurRadius: 10,
    offset: const Offset(0, 3),
    spreadRadius: 0,
  );
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isUsernameValid = false;
  
  // Unified Splash Animation Controller
  late AnimationController _splashController;
  
  // Splash Animations
  late Animation<double> _logo1Scale;
  late Animation<double> _logo1Opacity;
  late Animation<double> _logo1Blur;
  
  late Animation<double> _logo2Opacity;
  late Animation<double> _logo2Scale;
  late Animation<double> _logo2Rotate;
  late Animation<double> _logo2PositionY; // Position Y pour déplacer logo2 vers le haut
  
  late Animation<double> _splashOverlayOpacity;
  late Animation<double> _loginContentOpacity;
  late Animation<double> _loginContentScale;
  
  // Login Form Staggered Animations
  late AnimationController _animationController;
  late Animation<double> _formFade;
  late Animation<Offset> _field1Slide;
  late Animation<Offset> _field2Slide;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _footerFade;
  
  // Wave animation
  late AnimationController _waveAnimationController;
  late Animation<double> _waveAnimation;
  
  bool _showLoginContent = false;

  @override
  void initState() {
    super.initState();
    
    // 1. Unified Splash Controller (Total duration: 5.5s - ralenti)
    _splashController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    
    // --- Logo 1 Exit (0.0 - 0.4) ---
    // Scale down slightly (1.1 -> 0.7)
    _logo1Scale = Tween<double>(begin: 1.1, end: 0.7).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOutCubic),
      ),
    );
    
    // Fade out
    _logo1Opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.2, 0.4, curve: Curves.easeOut),
      ),
    );
    
    // Blur increase (0 -> 10)
    _logo1Blur = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
      ),
    );
    
    // --- Logo 2 Entrance (0.3 - 0.6) ---
    // Fade in
    _logo2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
      ),
    );
    
    // Scale up (zoom in effect: 0.8 -> 1.0)
    _logo2Scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOutBack),
      ),
    );
    
    // Slight rotation settling (-0.05 rad -> 0)
    _logo2Rotate = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOutQuart),
      ),
    );
    
    // --- Logo 2 Movement to Final Position (0.55 - 0.95) ---
    // Move from center (0.5) to top position (approximately 0.15 of screen height)
    _logo2PositionY = Tween<double>(begin: 0.5, end: 0.25).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.50, 0.95, curve: Curves.easeInOutCubic),
      ),
    );
    
    // --- Transition to Login (0.6 - 1.0) ---
    // Splash overlay fade out
    _splashOverlayOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.7, 0.95, curve: Curves.easeInOut),
      ),
    );
    
    // Login content fade in
    _loginContentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.65, 0.9, curve: Curves.easeOut),
      ),
    );
    
    // Login content scale (grow into place: 0.96 -> 1.0)
    _loginContentScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.65, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Login Form Staggered Controller (ralenti)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Staggered Animations Setup
    // Form Fields
    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _field1Slide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutQuart),
      ),
    );

    _field2Slide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutQuart),
      ),
    );

    // Action Buttons
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutQuart),
      ),
    );

    // Footer
    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    
    // 3. Wave Animation
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 10000), // Ralenti pour mouvement plus lent
      vsync: this,
    )..repeat();
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveAnimationController,
      curve: Curves.linear,
    ));
    
    // Listen to splash controller to trigger state changes
    _splashController.addListener(() {
      // Trigger login content visibility shortly before the transition starts
      if (_splashController.value > 0.6 && !_showLoginContent) {
        if (mounted) {
          setState(() {
            _showLoginContent = true;
          });
        }
      }
      
      // Trigger form staggered animation near the end of splash
      if (_splashController.value > 0.85 && !_animationController.isAnimating && !_animationController.isCompleted) {
        _animationController.forward();
      }
    });
    
    _startSplashAnimation();
  }
  
  Future<void> _startSplashAnimation() async {
    // Small initial delay for app launch smoothness
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _splashController.forward();
    }
  }

  @override
  void dispose() {
    _splashController.dispose();
    _animationController.dispose();
    _waveAnimationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final maxWidth = screenWidth > 400 
        ? _LoginDesign.maxContentWidth 
        : screenWidth * 0.9;

    return Scaffold(
      body: Stack(
        children: [
          // -----------------------------------------------------------
          // LAYER 1: LOGIN CONTENT (Background)
          // -----------------------------------------------------------
          if (_showLoginContent)
            AnimatedBuilder(
              animation: _splashController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _loginContentOpacity,
                  child: Transform.scale(
                    scale: _loginContentScale.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _LoginDesign.backgroundGradient,
                    stops: _LoginDesign.backgroundGradientStops,
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      // --- Parallax Waves ---
                      // Wave Layer 1 (Back, slower/offset)
                      Positioned(
                        bottom: -50,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: 0.6,
                              child: CustomPaint(
                                size: Size(screenWidth, screenHeight * 0.5),
                                painter: AnimatedWavePainter(
                                  animationValue: (_waveAnimation.value + 0.5) % 1.0, // Offset phase
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Wave Layer 2 (Front, main)
                      Positioned(
                        bottom: -60,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size(screenWidth, 1000),
                              painter: AnimatedWavePainter(
                                animationValue: _waveAnimation.value,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // --- Main Content ---
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxWidth,
                              maxHeight: screenHeight * 0.9,
                            ),
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                // Logo - Hidden because logo2 from splash moves to this position
                                // The splash logo2 becomes the login logo
                                const SizedBox.shrink(),
                                // Form
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: screenHeight * 0.3),
                                      // Username field - narrower and more transparent
                                      FadeTransition(
                                        opacity: _formFade,
                                        child: SlideTransition(
                                          position: _field1Slide,
                                          child: SizedBox(
                                            width: maxWidth * 0.85, // 85% of max width
                                            child: RoundedInputField(
                                              controller: _usernameController,
                                              hintText: 'Email',
                                              prefixIcon: Icons.person_outline,
                                              suffixIcon: _isUsernameValid ? Icons.check_circle : null,
                                              suffixIconColor: Colors.green,
                                              onChanged: (value) {
                                                setState(() {
                                                  _isUsernameValid = value.isNotEmpty && value.length > 3;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      
                                      // Password field - narrower and more transparent
                                      FadeTransition(
                                        opacity: _formFade,
                                        child: SlideTransition(
                                          position: _field2Slide,
                                          child: SizedBox(
                                            width: maxWidth * 0.85, // 85% of max width
                                            child: RoundedInputField(
                      controller: _passwordController,
                                              hintText: 'Password',
                                              prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                                              suffixIcon: _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              onSuffixTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.03),
                                      
                                      // Login button - smaller size
                                      FadeTransition(
                                        opacity: _formFade,
                                        child: SlideTransition(
                                          position: _buttonSlide,
                                          child: SizedBox(
                                            width: maxWidth * 0.85, // Same width as input fields
                                            child: PrimaryButton(
                                              text: 'Login',
                                              onPressed: _isLoading ? null : _signIn,
                                              isLoading: _isLoading,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                      
                                      // Forgot password
                                      FadeTransition(
                                        opacity: _footerFade,
                                        child: GestureDetector(
                                          onTap: () {
                                            // TODO: Implement forgot password
                                          },
                                          child: Text(
                                            'Forgot your password?',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _LoginDesign.forgotPasswordColor,
                                              fontSize: screenWidth < 360 ? 12 : 14,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                      
                                      // Divider
                                      FadeTransition(
                                        opacity: _footerFade,
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final isSmallScreen = constraints.maxWidth < 300;
                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    height: 1,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.transparent,
                                                          _LoginDesign.dividerColor,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: isSmallScreen ? 8 : 16,
                                                  ),
                                                  child: Text(
                                                    'or connect with',
                                style: TextStyle(
                                                      color: _LoginDesign.dividerTextColor,
                                                      fontSize: isSmallScreen ? 11 : 13,
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 0.5,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    height: 1,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          _LoginDesign.dividerColor,
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.03),
                                      
                                      // Social buttons
                                      FadeTransition(
                                        opacity: _footerFade,
                                        child: Column(
                                          children: [
                    SizedBox(
                      width: double.infinity,
                                              child: SocialButton(
                                                icon: FontAwesomeIcons.google,
                                                label: 'Google',
                                                backgroundColor: const Color(0xFF4285F4),
                                                onPressed: _isLoading ? null : _signInWithGoogle,
                                                useFontAwesome: true,
                                              ),
                                            ),
                                            SizedBox(height: screenHeight * 0.01),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: LinkedInButtonWrapper(
                                                    onSuccess: _handleLinkedInSuccess,
                                                    onError: _handleLinkedInError,
                                                  ),
                                                ),
                                                SizedBox(width: screenWidth * 0.03),
                                                Expanded(
                                                  child: SocialButton(
                                                    icon: FontAwesomeIcons.github,
                                                    label: 'GitHub',
                                                    backgroundColor: const Color(0xFF24292E),
                                                    onPressed: _isLoading ? null : _signInWithGitHub,
                                                    useFontAwesome: true,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.04),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Sign up text
                      Positioned(
                        bottom: math.max(screenHeight * 0.03, 20.0),
                        left: 0,
                        right: 0,
                        child: FadeTransition(
                          opacity: _footerFade,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                            child: GestureDetector(
                              onTap: () {
                        context.go('/register');
                      },
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                        style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: screenWidth < 360 ? 13 : 15,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.3,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(
                                        fontSize: screenWidth < 360 ? 12 : 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Sign up',
                        style: TextStyle(
                                        color: _LoginDesign.signUpColor,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                        decorationColor: _LoginDesign.signUpColor,
                                        decorationThickness: 1.5,
                                        fontSize: screenWidth < 360 ? 13 : 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
          // -----------------------------------------------------------
          // LAYER 2: SPLASH OVERLAY (Foreground)
          // -----------------------------------------------------------
          if (_splashOverlayOpacity.value > 0.01) // Optimization: don't render if invisible
            AnimatedBuilder(
              animation: _splashController,
              builder: (context, child) {
                return IgnorePointer(
                  ignoring: _splashOverlayOpacity.value < 0.1 || _showLoginContent, // Ignore interactions when mostly transparent or login content is shown (lowered threshold)
                  child: Opacity(
                    opacity: _splashOverlayOpacity.value,
                    child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1A3D),
                    ),
                    child: Stack(
                      children: [
                        // Logo 1 (Exit) - Centered
                        if (_logo1Opacity.value > 0)
                          Positioned(
                            top: screenHeight * 0.5 - 175, // Center vertically
                            left: screenWidth * 0.5 - 175, // Center horizontally
                            child: Opacity(
                              opacity: _logo1Opacity.value,
                              child: Transform.scale(
                                scale: _logo1Scale.value,
                                child: _logo1Blur.value > 0.1
                                    ? ImageFiltered(
                                        imageFilter: ui.ImageFilter.blur(
                                          sigmaX: _logo1Blur.value,
                                          sigmaY: _logo1Blur.value,
                                        ),
                                        child: Image.asset(
                                          'assets/ui/logo1_withoutbg.png',
                                          width: 350,
                                          height: 350,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/ui/logo1_withoutbg.png',
                                        width: 350,
                                        height: 350,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                            ),
                          ),
                        
                        // Logo 2 is now rendered outside the splash overlay to remain visible
                  ],
                ),
              ),
            ),
              );
            },
          ),
          
          // -----------------------------------------------------------
          // LAYER 3: LOGO2 (Foreground - Top Layer)
          // -----------------------------------------------------------
          // Logo2 from splash - moves from center to top position
          // This stays visible even after splash overlay disappears
          if (_logo2Opacity.value > 0.01)
            AnimatedBuilder(
              animation: _splashController,
              builder: (context, child) {
                // Fixed size - increased to push form down
                const logoSize = 420.0;
                
                // Calculate position - center horizontally, move vertically
                final logoTop = screenHeight * _logo2PositionY.value - (logoSize / 2);
                final logoLeft = screenWidth * 0.5 - (logoSize / 2);
                
                // Calculate opacity: start with logo2Opacity, then fade in as overlay fades out
                final baseOpacity = _logo2Opacity.value;
                final overlayFadeIn = (1.0 - _splashOverlayOpacity.value);
                final finalOpacity = math.min(1.0, baseOpacity + overlayFadeIn * 0.5);
                
                return Positioned(
                  top: logoTop,
                  left: logoLeft,
                  child: IgnorePointer(
                    // Don't block interactions - logo is just visual
                    child: Opacity(
                      opacity: finalOpacity,
                      child: Transform.scale(
                        scale: _logo2Scale.value, // Keep original scale animation, no reduction
                        child: Transform.rotate(
                          angle: _logo2Rotate.value,
                          child: Image.asset(
                            'assets/ui/logo2_dark.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signInWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        context.go('/swipe');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService.signInWithGoogle();

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connexion Google annulée'),
            ),
          );
        }
        return;
      }

      await AuthService.ensureUserDocumentExists();
      
      if (mounted) {
        context.go('/swipe');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur Google: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLinkedInSuccess(UserSucceededAction action) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obtenir le token d'accès LinkedIn depuis l'action
      final accessToken = action.user.token.accessToken;
      
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Token LinkedIn non disponible');
      }
      
      // Utiliser le token pour se connecter avec Firebase
      final user = await AuthService.signInWithLinkedInToken(accessToken);

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connexion LinkedIn échouée'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await AuthService.ensureUserDocumentExists();

      if (mounted) {
        context.go('/swipe');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur LinkedIn: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLinkedInError(UserFailedAction action) {
    setState(() {
      _isLoading = false;
    });

    final errorMessage = action.exception.toString();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signInWithGitHub() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService.signInWithGitHub();

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connexion GitHub annulée'),
            ),
          );
        }
        return;
      }

      await AuthService.ensureUserDocumentExists();

      if (mounted) {
        context.go('/swipe');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur GitHub: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Rounded Input Field Widget with glassmorphism
class RoundedInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final Color? suffixIconColor;
  final bool obscureText;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;

  const RoundedInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.suffixIconColor,
    this.obscureText = false,
    this.onSuffixTap,
    this.onChanged,
  });

  @override
  State<RoundedInputField> createState() => _RoundedInputFieldState();
}

class _RoundedInputFieldState extends State<RoundedInputField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_isFocused ? 1.0 : 0.75), // Fully opaque when focused
        borderRadius: BorderRadius.circular(_LoginDesign.inputRadius),
        border: Border.all(
          color: _isFocused 
              ? _LoginDesign.buttonGradient.first.withOpacity(0.9) // More pronounced border when focused
              : Colors.white.withOpacity(0.3),
          width: _isFocused ? 2.5 : 1.5,
        ),
        boxShadow: _isFocused
            ? [
                _LoginDesign.inputShadow,
                BoxShadow(
                  color: _LoginDesign.buttonGradient.first.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ]
            : [_LoginDesign.inputShadow],
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          onChanged: widget.onChanged,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade700, // Darker and more pronounced (was shade400)
              fontWeight: FontWeight.w500, // Slightly bolder (was w400)
            ),
            prefixIcon: Icon(
              widget.prefixIcon,
              color: _isFocused
                  ? _LoginDesign.buttonGradient.first
                  : Colors.grey.shade600,
            ),
            suffixIcon: widget.suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      widget.suffixIcon,
                      color: widget.suffixIconColor ?? Colors.grey.shade600,
                    ),
                    onPressed: widget.onSuffixTap,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }
}

// Primary Button Widget with animations
class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 48, // Reduced from 56
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _LoginDesign.buttonGradient,
                ),
                borderRadius: BorderRadius.circular(_LoginDesign.buttonRadius),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: _LoginDesign.buttonGradient.first
                              .withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [_LoginDesign.buttonShadow],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(_LoginDesign.buttonRadius),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Reduced padding
                    child: widget.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.text,
                            style: const TextStyle(
                              fontSize: 15, // Reduced from 17
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Social Button Widget with animations
class SocialButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final bool useFontAwesome;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.onPressed,
    this.useFontAwesome = false,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_LoginDesign.buttonRadius),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: widget.backgroundColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [_LoginDesign.socialButtonShadow],
              ),
              child: ElevatedButton.icon(
                onPressed: widget.onPressed,
                icon: widget.useFontAwesome
                    ? FaIcon(widget.icon, color: Colors.white, size: 20)
                    : Icon(widget.icon, color: Colors.white, size: 20),
                label: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.backgroundColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_LoginDesign.buttonRadius),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Wave Painter for bottom wave shape - smoother and more organic
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Créer un dégradé pour la vague en bleu marine
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height * 0.3),
        Offset(0, size.height),
        [
          primaryBlue.withOpacity(0.95),
          primaryBlue,
        ],
      )
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Commencer depuis le bas gauche avec un léger chevauchement
    path.moveTo(0, size.height + 10);
    
    // Créer une vague plus fluide avec des courbes cubic bezier
    // Première courbe - montée douce
    path.cubicTo(
      size.width * 0.15,
      size.height * 0.5,
      size.width * 0.3,
      size.height * 0.35,
      size.width * 0.45,
      size.height * 0.4,
    );
    
    // Deuxième courbe - descente douce
    path.cubicTo(
      size.width * 0.6,
      size.height * 0.45,
      size.width * 0.75,
      size.height * 0.3,
      size.width * 0.9,
      size.height * 0.35,
    );
    
    // Dernière courbe vers le bord droit
    path.cubicTo(
      size.width * 0.95,
      size.height * 0.38,
      size.width,
      size.height * 0.32,
      size.width,
      size.height * 0.4,
    );
    
    // Compléter le chemin vers le bas droit et revenir au début
    path.lineTo(size.width, size.height + 10);
    path.lineTo(0, size.height + 10);
    path.close();

    canvas.drawPath(path, paint);
    
    // Ajouter une ombre douce sous la vague
    final shadowPath = Path()
      ..addPath(path, Offset.zero);
    
    canvas.drawShadow(
      shadowPath,
      Colors.black.withOpacity(0.1),
      8.0,
      true,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Animated Wave Painter for smooth wave movement
class AnimatedWavePainter extends CustomPainter {
  final double animationValue;
  
  AnimatedWavePainter({required this.animationValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Créer un dégradé pour la vague en bleu marine
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height * 0.3),
        Offset(0, size.height),
        [
          primaryBlue.withOpacity(0.95),
          primaryBlue,
        ],
      )
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Commencer depuis le bas gauche
    path.moveTo(0, size.height + 10);
    
    // Utiliser une fonction sinusoïdale pour créer un mouvement de vague naturel
    // L'animation déplace la vague de gauche à droite
    final waveSpeed = animationValue * 2 * math.pi; // 2π pour un cycle complet
    final waveAmplitude = size.height * 0.08; // Amplitude de la vague
    
    // Commencer la vague dès le bord gauche (x=0) avec une hauteur visible
    final y0 = size.height * 0.45 + (waveAmplitude * 0.4 * math.sin(waveSpeed - 0.5));
    path.lineTo(0, y0);
    
    // Créer des points de contrôle animés avec une fonction sinusoïdale
    // Première courbe - montée douce avec animation depuis le bord gauche
    final x1 = size.width * 0.1;
    final y1 = size.height * 0.5 + (waveAmplitude * 0.5 * math.sin(waveSpeed));
    final x2 = size.width * 0.25;
    final y2 = size.height * 0.35 + (waveAmplitude * 0.7 * math.sin(waveSpeed + 0.5));
    final x3 = size.width * 0.45;
    final y3 = size.height * 0.4 + (waveAmplitude * 0.6 * math.sin(waveSpeed + 1.0));
    
    path.cubicTo(x1, y1, x2, y2, x3, y3);
    
    // Deuxième courbe - descente douce avec animation
    final x4 = size.width * 0.6;
    final y4 = size.height * 0.45 + (waveAmplitude * 0.5 * math.sin(waveSpeed + 1.5));
    final x5 = size.width * 0.75;
    final y5 = size.height * 0.3 + (waveAmplitude * 0.8 * math.sin(waveSpeed + 2.0));
    final x6 = size.width * 0.9;
    final y6 = size.height * 0.35 + (waveAmplitude * 0.6 * math.sin(waveSpeed + 2.5));
    
    path.cubicTo(x4, y4, x5, y5, x6, y6);
    
    // Dernière courbe vers le bord droit avec animation
    final x7 = size.width * 0.95;
    final y7 = size.height * 0.38 + (waveAmplitude * 0.4 * math.sin(waveSpeed + 3.0));
    final x8 = size.width;
    final y8 = size.height * 0.32 + (waveAmplitude * 0.5 * math.sin(waveSpeed + 3.5));
    
    path.cubicTo(x7, y7, x8, y8, size.width, size.height * 0.4);
    
    // Compléter le chemin vers le bas droit et revenir au début
    path.lineTo(size.width, size.height + 10);
    path.lineTo(0, size.height + 10);
    path.close();

    canvas.drawPath(path, paint);
    
    // Note: drawShadow removed for performance optimization on CanvasKit
    // The gradient already provides visual depth
  }

  @override
  bool shouldRepaint(AnimatedWavePainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

// LinkedIn Button Wrapper Widget
class LinkedInButtonWrapper extends StatelessWidget {
  final void Function(UserSucceededAction) onSuccess;
  final void Function(UserFailedAction) onError;

  const LinkedInButtonWrapper({
    super.key,
    required this.onSuccess,
    required this.onError,
  });

  // TODO: Configurez ces valeurs avec vos credentials LinkedIn
  // Obtenez-les depuis https://www.linkedin.com/developers/apps
  static const String linkedInClientId = 'YOUR_LINKEDIN_CLIENT_ID';
  static const String linkedInClientSecret = 'YOUR_LINKEDIN_CLIENT_SECRET';
  static const String linkedInRedirectUrl = 'YOUR_LINKEDIN_REDIRECT_URL';

  @override
  Widget build(BuildContext context) {
    // Si les credentials ne sont pas configurés, afficher un bouton désactivé
    if (linkedInClientId == 'YOUR_LINKEDIN_CLIENT_ID' || 
        linkedInClientSecret == 'YOUR_LINKEDIN_CLIENT_SECRET' ||
        linkedInRedirectUrl == 'YOUR_LINKEDIN_REDIRECT_URL') {
      return SocialButton(
        icon: FontAwesomeIcons.linkedin,
        label: 'LinkedIn',
        backgroundColor: const Color(0xFF0077B5),
        onPressed: null,
        useFontAwesome: true,
      );
    }

    // Créer un bouton personnalisé qui ouvre LinkedInUserWidget
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_LoginDesign.buttonRadius),
        boxShadow: [_LoginDesign.socialButtonShadow],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // Naviguer vers le widget LinkedInUserWidget
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => LinkedInUserWidget(
                redirectUrl: linkedInRedirectUrl,
                clientId: linkedInClientId,
                clientSecret: linkedInClientSecret,
                onGetUserProfile: onSuccess,
                onError: onError,
              ),
            ),
          );
        },
        icon: const FaIcon(
          FontAwesomeIcons.linkedin,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          'LinkedIn',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0077B5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_LoginDesign.buttonRadius),
          ),
        ),
      ),
    );
  }
}
