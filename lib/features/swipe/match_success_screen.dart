import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:hire_me/core/app_theme.dart';
import 'package:hire_me/services/storage_service.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hire_me/services/firebase_user_service.dart';
import 'package:hire_me/models/user_model.dart';
import 'dart:ui';

class MatchSuccessScreen extends ConsumerStatefulWidget {
  final String matchId;
  final String otherUserId;

  const MatchSuccessScreen({
    super.key,
    required this.matchId,
    required this.otherUserId,
  });

  @override
  ConsumerState<MatchSuccessScreen> createState() => _MatchSuccessScreenState();
}

class _MatchSuccessScreenState extends ConsumerState<MatchSuccessScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(
      'assets/animations/match_animation.mov',
    );

    try {
      await _videoController.initialize();
      _videoController.setLooping(true);
      _videoController.play();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final otherUserAsync = ref.watch(userProvider(widget.otherUserId));
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Video Background
          if (_isVideoInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
          else
            Container(color: Colors.white), // Placeholder while loading

          // 2. Content Overlay
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Avatars Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Current User Avatar
                    currentUserAsync.when(
                      data: (user) => _buildAvatar(user?.profileImageUrl, isLeft: true),
                      loading: () => _buildAvatarPlaceholder(),
                      error: (_, __) => _buildAvatarPlaceholder(),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Matched User Avatar
                    otherUserAsync.when(
                      data: (user) => _buildAvatar(user?.profileImageUrl, isLeft: false),
                      loading: () => _buildAvatarPlaceholder(),
                      error: (_, __) => _buildAvatarPlaceholder(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // "MATCH !" Title
                Text(
                  'MATCH !',
                  style: TextStyle(
                    fontFamily: 'Outfit', // Assuming Outfit is used, otherwise system font
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5B8EFF), // Light blue similar to image
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.8),
                        offset: const Offset(0, 2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      // "PROPOSER UN ENTRETIEN" Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement interview proposal logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fonctionnalité à venir')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B8EFF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          child: const Text('PROPOSER UN ENTRETIEN'),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // "CONTACTER" Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to chat
                            debugPrint('🔵 CONTACTER button pressed - matchId: ${widget.matchId}');
                            context.go('/chat?matchId=${widget.matchId}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B8EFF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          child: const Text('CONTACTER'),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Close/Back Button (Optional, maybe just tap outside or a small X)
                      TextButton(
                        onPressed: () {
                          context.go('/swipe');
                        },
                        child: const Text(
                          'Retour',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? photoUrl, {required bool isLeft}) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isLeft ? Colors.black : const Color(0xFF00B0FF), // Black for left, Cyan for right
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Builder(
          builder: (context) {
            final imageProvider = StorageService.resolveProfileImage(photoUrl);
            return CircleAvatar(
              radius: 60,
              backgroundImage: imageProvider,
              backgroundColor: Colors.grey.shade200,
              child: imageProvider == null
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            );
          }
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
