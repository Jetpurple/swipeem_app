import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/features/auth/login_screen.dart';
import 'package:hire_me/features/auth/register_screen.dart';
import 'package:hire_me/features/posts/create_post_screen.dart';
import 'package:hire_me/features/messages/chat_room_screen.dart';
import 'package:hire_me/features/messages/messages_screen.dart';
import 'package:hire_me/features/profile/academic_path_screen.dart';
import 'package:hire_me/features/profile/edit_profile_screen.dart';
import 'package:hire_me/features/profile/experiences_screen.dart';
import 'package:hire_me/features/profile/profile_dashboard_screen.dart';
import 'package:hire_me/features/profile/recruiter_stats_screen.dart';
import 'package:hire_me/features/profile/settings/account_security_screen.dart';
import 'package:hire_me/features/profile/settings/appearance_accessibility_screen.dart';
import 'package:hire_me/features/profile/settings/billing_history_screen.dart';
import 'package:hire_me/features/profile/settings/change_plan_screen.dart';
import 'package:hire_me/features/profile/settings/integration_screen.dart';
import 'package:hire_me/features/profile/settings/language_region_screen.dart';
import 'package:hire_me/features/profile/settings/notifications_screen.dart';
import 'package:hire_me/features/profile/settings/payment_methods_screen.dart';
import 'package:hire_me/features/profile/settings/privacy_gdpr_screen.dart';
import 'package:hire_me/features/profile/settings/subscription_billing_screen.dart';
import 'package:hire_me/features/profile/settings/subscription_management_screen.dart';
import 'package:hire_me/features/profile/settings_screen.dart';
import 'package:hire_me/features/profile/simple_personality_test_screen.dart';
import 'package:hire_me/features/profile/skills_screens.dart';
import 'package:hire_me/features/recruiter/candidate_detail_screen.dart';
import 'package:hire_me/features/recruiter/recruiter_job_offers_screen.dart';
import 'package:hire_me/features/recruiter/recruiter_matches_screen.dart';
import 'package:hire_me/features/recruiter/recruiter_swipe_screen.dart';
import 'package:hire_me/features/swipe/swipe_screen.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/providers/message_provider.dart';
import 'package:hire_me/features/interviews/calendar_screen.dart';
import 'package:hire_me/features/interviews/propose_interview_screen.dart';
import 'package:hire_me/features/admin/admin_dashboard_screen.dart';
import 'package:hire_me/features/admin/test_data_screen.dart';

import 'package:hire_me/features/swipe/match_success_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch the stream directly for GoRouterRefreshStream
  // final authStateStream = ref.watch(authStateProvider.stream);
  // Using FirebaseAuth directly to avoid StreamProvider issues for now
  final authStream = FirebaseAuth.instance.authStateChanges();
  
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authStream),
    redirect: (context, state) {
      // Vérifier directement l'état d'authentification Firebase
      final currentUser = FirebaseAuth.instance.currentUser;
      final isLoggedIn = currentUser != null;
      
      print('🔀 Router redirect - Path: ${state.uri.path}, isLoggedIn: $isLoggedIn, user: ${currentUser?.email}');
      
      // Routes publiques (accessibles sans authentification)
      final publicRoutes = ['/login', '/register', '/admin', '/admin/test-data'];
      final currentPath = state.uri.path;
      
      // Rediriger /splash vers /login (l'animation splash est maintenant dans login)
      if (currentPath == '/splash') {
        return '/login';
      }
      
      // Si on est sur une route publique, ne pas rediriger
      if (publicRoutes.contains(currentPath)) {
        // Si l'utilisateur est connecté et sur login/register, rediriger vers la page swipe
        if (isLoggedIn) {
          print('✅ User logged in on public route, redirecting to /swipe');
          return '/swipe';
        }
        return null;
      }
      
      // Si l'utilisateur n'est pas connecté et n'est pas sur une route publique
      if (!isLoggedIn) {
        print('❌ User not logged in, redirecting to /login');
        return '/login';
      }

      return null; // Pas de redirection
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterScreen(),
      ),
      GoRoute(
        path: '/match-success',
        builder: (BuildContext context, GoRouterState state) {
          final matchId = state.uri.queryParameters['matchId'] ?? '';
          final otherUserId = state.uri.queryParameters['otherUserId'] ?? '';
          return MatchSuccessScreen(
            matchId: matchId,
            otherUserId: otherUserId,
          );
        },
      ),
      // Routes admin
      GoRoute(
        path: '/admin',
        builder: (BuildContext context, GoRouterState state) =>
            const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/test-data',
        builder: (BuildContext context, GoRouterState state) =>
            const TestDataScreen(),
      ),
      // Routes pour les recruteurs (en dehors du ShellRoute)
      GoRoute(
        path: '/recruiter/job-offers',
        builder: (BuildContext context, GoRouterState state) =>
            const RecruiterJobOffersScreen(),
      ),
      GoRoute(
        path: '/recruiter/matches',
        builder: (BuildContext context, GoRouterState state) =>
            const RecruiterMatchesScreen(),
      ),
      // Shell avec footer (bottom navigation)
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          // Pass current location from state to keep footer selection in sync
          final currentLocation = state.matchedLocation;
          return _FooterShell(location: currentLocation, child: child);
        },
        routes: <RouteBase>[
          // Sections principales avec footer
          GoRoute(
            path: '/swipe',
            builder: (BuildContext context, GoRouterState state) {
              // Show RecruiterSwipeScreen for recruiters, SwipeScreen for candidates
              return Consumer(
                builder: (context, ref, child) {
                  final currentUserAsync = ref.watch(currentUserProvider);
                  final isRecruiter = currentUserAsync.value?.isRecruiter ?? false;
                  return isRecruiter
                      ? const RecruiterSwipeScreen()
                      : const SwipeScreen();
                },
              );
            },
          ),
          GoRoute(
            path: '/messages',
            builder: (BuildContext context, GoRouterState state) =>
                const MessagesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (BuildContext context, GoRouterState state) =>
                const ProfileDashboardScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (BuildContext context, GoRouterState state) {
              final matchId = state.uri.queryParameters['matchId'];
              return ChatRoomScreen(matchId: matchId);
            },
          ),
          GoRoute(
            path: '/calendar',
            builder: (BuildContext context, GoRouterState state) =>
                const CalendarScreen(),
          ),
          GoRoute(
            path: '/calendar/propose/:matchId',
            builder: (BuildContext context, GoRouterState state) {
              final matchId = state.pathParameters['matchId']!;
              return ProposeInterviewScreen(matchId: matchId);
            },
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (BuildContext context, GoRouterState state) =>
                const EditProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (BuildContext context, GoRouterState state) =>
                const SettingsScreen(),
          ),
          // Routes pour les pages Settings
          GoRoute(
            path: '/settings/account-security',
            builder: (BuildContext context, GoRouterState state) =>
                const AccountSecurityScreen(),
          ),
          GoRoute(
            path: '/settings/subscription-billing',
            builder: (BuildContext context, GoRouterState state) =>
                const SubscriptionBillingScreen(),
          ),
          GoRoute(
            path: '/settings/notifications',
            builder: (BuildContext context, GoRouterState state) =>
                const NotificationsScreen(),
          ),
          GoRoute(
            path: '/settings/language-region',
            builder: (BuildContext context, GoRouterState state) =>
                const LanguageRegionScreen(),
          ),
          GoRoute(
            path: '/settings/integration',
            builder: (BuildContext context, GoRouterState state) =>
                const IntegrationScreen(),
          ),
          GoRoute(
            path: '/settings/appearance-accessibility',
            builder: (BuildContext context, GoRouterState state) =>
                const AppearanceAccessibilityScreen(),
          ),
          GoRoute(
            path: '/settings/privacy-gdpr',
            builder: (BuildContext context, GoRouterState state) =>
                const PrivacyGdprScreen(),
          ),
          // Routes pour les pages d'abonnement
          GoRoute(
            path: '/settings/payment-methods',
            builder: (BuildContext context, GoRouterState state) =>
                const PaymentMethodsScreen(),
          ),
          GoRoute(
            path: '/settings/billing-history',
            builder: (BuildContext context, GoRouterState state) =>
                const BillingHistoryScreen(),
          ),
          GoRoute(
            path: '/settings/change-plan',
            builder: (BuildContext context, GoRouterState state) =>
                const ChangePlanScreen(),
          ),
          GoRoute(
            path: '/settings/subscription-management',
            builder: (BuildContext context, GoRouterState state) =>
                const SubscriptionManagementScreen(),
          ),
          // Routes pour les pages Profile
          GoRoute(
            path: '/personality-test',
            builder: (BuildContext context, GoRouterState state) =>
                const SimplePersonalityTestScreen(),
          ),
          GoRoute(
            path: '/experiences',
            builder: (BuildContext context, GoRouterState state) =>
                const ExperiencesScreen(),
          ),
          GoRoute(
            path: '/academic-path',
            builder: (BuildContext context, GoRouterState state) =>
                const AcademicPathScreen(),
          ),
          GoRoute(
            path: '/recruiter/stats',
            builder: (BuildContext context, GoRouterState state) =>
                const RecruiterStatsScreen(),
          ),
          GoRoute(
            path: '/skills/soft',
            builder: (BuildContext context, GoRouterState state) =>
                const SoftSkillsScreen(),
          ),
          GoRoute(
            path: '/skills/hard',
            builder: (BuildContext context, GoRouterState state) =>
                const HardSkillsScreen(),
          ),
          GoRoute(
            path: '/create-post',
            builder: (BuildContext context, GoRouterState state) =>
                const CreatePostScreen(),
          ),
          GoRoute(
            path: '/candidate-detail',
            builder: (BuildContext context, GoRouterState state) {
              final candidateUid = state.uri.queryParameters['candidateUid'];
              if (candidateUid == null || candidateUid.isEmpty) {
                return const Scaffold(
                  body: Center(child: Text('ID candidat manquant')),
                );
              }
              return CandidateDetailScreen(candidateUid: candidateUid);
            },
          ),
        ],
      ),
    ],
  );
});

class _FooterShell extends ConsumerWidget {
  const _FooterShell({required this.child, required this.location});

  final Widget child;
  final String location;

  int _indexFromLocation(String location) {
    if (location.startsWith('/messages') || location.startsWith('/chat')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0; // '/swipe' par défaut
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/swipe');
      case 1:
        context.go('/messages');
      case 2:
        context.go('/profile');
      default:
        context.go('/swipe');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _indexFromLocation(location);
    final unreadCountAsync = ref.watch(unreadMessageCountProvider);
    final unreadCount = unreadCountAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, __) => 0,
    );
    
    final currentUserAsync = ref.watch(currentUserProvider);
    final isRecruiter = currentUserAsync.value?.isRecruiter ?? false;

    return Scaffold(
      body: child,
      bottomNavigationBar: _GlassBottomNav(
        selectedIndex: selectedIndex,
        onTap: (index) => _onTap(context, index),
        unreadCount: unreadCount,
        isRecruiter: isRecruiter,
      ),
    );
  }
}

// Custom Glassmorphism Bottom Navigation Bar
class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.unreadCount,
    this.isRecruiter = false,
  });

  final int selectedIndex;
  final void Function(int) onTap;
  final int unreadCount;
  final bool isRecruiter;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.0),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _GlassNavButton(
                  isSelected: selectedIndex == 0,
                  onTap: () => onTap(0),
                  child: Icon(
                    isRecruiter ? Icons.person_search_rounded : Icons.swipe,
                    color: selectedIndex == 0 ? const Color(0xFF21D0C3) : Colors.white.withValues(alpha: 0.6),
                    size: 26,
                  ),
                  label: isRecruiter ? 'Talents' : 'Swipe',
                ),
                _GlassNavButton(
                  isSelected: selectedIndex == 1,
                  onTap: () => onTap(1),
                  child: _MessageIconWithBadge(
                    icon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: selectedIndex == 1 ? const Color(0xFF21D0C3) : Colors.white.withValues(alpha: 0.6),
                      size: 26,
                    ),
                    unreadCount: unreadCount,
                  ),
                  label: 'Messages',
                ),
                _GlassNavButton(
                  isSelected: selectedIndex == 2,
                  onTap: () => onTap(2),
                  child: Icon(
                    isRecruiter ? Icons.business_center_rounded : Icons.person_outline_rounded,
                    color: selectedIndex == 2 ? const Color(0xFF21D0C3) : Colors.white.withValues(alpha: 0.6),
                    size: 26,
                  ),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Glassmorphism Navigation Button
class _GlassNavButton extends StatefulWidget {
  const _GlassNavButton({
    required this.isSelected,
    required this.onTap,
    required this.child,
    required this.label,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final String label;

  @override
  State<_GlassNavButton> createState() => _GlassNavButtonState();
}

class _GlassNavButtonState extends State<_GlassNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected || _isPressed;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Center(child: widget.child),
            ),
            const SizedBox(height: 1),
            Text(
              widget.label,
              style: TextStyle(
                color: isActive ? const Color(0xFF21D0C3) : Colors.white.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageIconWithBadge extends StatelessWidget {
  const _MessageIconWithBadge({
    required this.icon,
    required this.unreadCount,
  });

  final Widget icon;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        icon,
        if (unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  // textAlign: TextAlign.center, // Removed invalid parameter
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A stream that notifies the router when the stream emits a value.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
