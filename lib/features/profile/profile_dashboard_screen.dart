import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/services/auth_service.dart';
import 'package:hire_me/services/firebase_user_service.dart';
import 'package:hire_me/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileDashboardScreen extends ConsumerWidget {
  const ProfileDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        final displayName = user?.fullName ?? 'Utilisateur';
        final photoUrl = user?.profileImageUrl;
        debugPrint('👤 ProfileDashboard - photoUrl: ${photoUrl?.substring(0, photoUrl.length > 100 ? 100 : photoUrl.length)}...');

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Logo1(
              height: 100,
              fit: BoxFit.contain,
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualiser',
                onPressed: () {
                  ref.invalidate(currentUserProvider);
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.go('/settings'),
              ),
              IconButton(
                tooltip: 'Déconnexion',
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  try {
                    await AuthService.signOut();
                  } catch (_) {}
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Header gradient with centered avatar and name
              Container(
                padding: const EdgeInsets.only(
                  top: 24,
                  left: 16,
                  right: 16,
                  bottom: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          key: ValueKey(photoUrl ?? 'no-photo'),
                          radius: 56,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Builder(
                            builder: (_) {
                              final imageProvider = StorageService.resolveProfileImage(photoUrl);
                              return CircleAvatar(
                                radius: 52,
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                backgroundImage: imageProvider,
                                child: imageProvider == null
                                    ? Icon(
                                        Icons.person,
                                        size: 56,
                                        color: Theme.of(context).colorScheme.primary,
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          right: 92,
                          bottom: 0,
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Changer la photo',
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 22,
                                ),
                                onPressed: () async {
                                  final uid = ref.read(currentUserIdProvider);
                                  if (uid == null) return;
                                  try {
                                    final source =
                                        await showModalBottomSheet<dynamic>(
                                          context: context,
                                          builder: (ctx) => SafeArea(
                                            child: Wrap(
                                              children: [
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.photo_library,
                                                  ),
                                                  title: const Text('Galerie'),
                                                  onTap: () => Navigator.of(
                                                    ctx,
                                                  ).pop(ImageSource.gallery),
                                                ),
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.photo_camera,
                                                  ),
                                                  title: const Text('Caméra'),
                                                  onTap: () => Navigator.of(
                                                    ctx,
                                                  ).pop(ImageSource.camera),
                                                ),
                                                if (photoUrl != null &&
                                                    photoUrl.isNotEmpty)
                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.delete,
                                                      color: Theme.of(context).colorScheme.error,
                                                    ),
                                                    title: const Text(
                                                      'Supprimer la photo',
                                                    ),
                                                    onTap: () => Navigator.of(
                                                      ctx,
                                                    ).pop('delete'),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                    if (source == null) return;

                                    if (source == 'delete') {
                                      await StorageService.deleteUserProfileImage(
                                        uid: uid,
                                      );
                                      await FirebaseUserService.clearProfileImageUrl(
                                        uid,
                                      );
                                      
                                      // Vider le cache d'images pour forcer le rechargement
                                      PaintingBinding.instance.imageCache.clear();
                                      PaintingBinding.instance.imageCache.clearLiveImages();
                                      
                                      ref.invalidate(currentUserProvider);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Photo supprimée'),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    final picker = ImagePicker();
                                    final picked = await picker.pickImage(
                                      source: source as ImageSource,
                                      imageQuality: 70, // Réduit pour éviter de dépasser la limite Firestore (1MB)
                                      maxWidth: 512,    // Redimensionné pour le web
                                      maxHeight: 512,
                                    );
                                    if (picked == null) return;

                                    File? file;
                                    Uint8List? webImageBytes;
                                    String mimeType = picked.mimeType ?? 'image/jpeg';

                                    if (kIsWeb) {
                                      webImageBytes = await picked.readAsBytes();
                                    } else {
                                      file = File(picked.path);
                                      var processedFile = file;
                                      final cropped = await StorageService.cropSquare(processedFile);
                                      if (cropped == null) {
                                        // L'utilisateur a annulé le recadrage, on continue avec l'image originale
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Recadrage annulé, image originale utilisée'),
                                            ),
                                          );
                                        }
                                      } else {
                                        processedFile = cropped;
                                      }
                                      file = processedFile;
                                    }

                                    final url = await StorageService.uploadUserProfileImage(
                                      uid: uid,
                                      file: file,
                                      webImageBytes: webImageBytes,
                                      mimeType: mimeType,
                                    );
                                    await FirebaseUserService.updateProfileImageUrl(
                                      uid,
                                      url,
                                    );
                                    
                                    // Vider le cache d'images pour forcer le rechargement
                                    PaintingBinding.instance.imageCache.clear();
                                    PaintingBinding.instance.imageCache.clearLiveImages();
                                    
                                    ref.invalidate(currentUserProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Photo mise à jour'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Erreur: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Bouton pour modifier les informations
                    ElevatedButton.icon(
                      onPressed: () => context.go('/edit-profile'),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('MODIFIER MES INFORMATIONS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Affichage conditionnel selon le rôle
              if (user?.isRecruiter ?? false) ...[
                // Sections pour les recruteurs
                _ImageTile(
                  title: "MES OFFRES D'EMPLOI",
                  imageUrl:
                      'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?q=80&w=900',
                  onTap: () => context.go('/recruiter/job-offers'),
                  titleColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : null,
                ),
                const SizedBox(height: 12),
                _ImageTile(
                  title: 'PUBLIER UNE OFFRE',
                  imageUrl:
                      'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?q=80&w=900',
                  onTap: () => context.go('/create-post'),
                  titleColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : null,
                ),
                const SizedBox(height: 12),
                _ImageTile(
                  title: 'CANDIDATS MATCHÉS',
                  imageUrl:
                      'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?q=80&w=900',
                  onTap: () => context.go('/recruiter/matches'),
                  titleColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : null,
                ),
                const SizedBox(height: 12),
                _ImageTile(
                  title: 'STATISTIQUES',
                  imageUrl:
                      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=900',
                  onTap: () => context.go('/recruiter/stats'),
                  titleColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : null,
                ),
              ] else ...[
                // Sections pour les candidats
                _ImageTile(
                  title: 'MES SOFT SKILLS',
                  imageUrl:
                      'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?q=80&w=900',
                  onTap: () => context.go('/skills/soft'),
                  titleColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : null,
                ),
                const SizedBox(height: 12),
                _ImageTile(
                  title: 'MES HARD SKILLS',
                  imageUrl:
                      'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?q=80&w=900',
                  onTap: () => context.go('/skills/hard'),
                  titleColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : null,
                ),
                const SizedBox(height: 12),
                _ImageTile(
                  title: 'MON TEST DE PERSONNALITÉ',
                  imageUrl:
                      'https://images.unsplash.com/photo-1543722530-d2c3201371e7?q=80&w=900',
                  onTap: () => context.go('/personality-test'),
                  titleColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : null,
                ),
                const SizedBox(height: 12),
                _ImageTile(
                  title: 'MES EXPÉRIENCES',
                  imageUrl:
                      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=900',
                  onTap: () => context.go('/experiences'),
                  titleColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : null,
                ),
                const SizedBox(height: 12),
                _ImageTile(
                  title: 'MON PARCOURS ACADÉMIQUE',
                  imageUrl:
                      'https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?q=80&w=900',
                  onTap: () => context.go('/academic-path'),
                  titleColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : null,
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.title,
    required this.imageUrl,
    required this.onTap,
    this.titleColor,
  });
  final String title;
  final String imageUrl;
  final VoidCallback onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Theme.of(context).colorScheme.surface),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Theme.of(context).colorScheme.shadow.withValues(alpha: 0.15),
                      Theme.of(context).colorScheme.shadow.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 56,
              bottom: 16,
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
