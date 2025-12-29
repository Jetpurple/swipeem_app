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

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _companyController;
  late TextEditingController _jobTitleController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _companyController = TextEditingController();
    _jobTitleController = TextEditingController();
    
    // Initialiser les contrôleurs avec les données utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }
  
  void _initializeControllers() {
    final currentUserAsync = ref.read(currentUserProvider);
    currentUserAsync.whenData((currentUser) {
      if (currentUser != null) {
        _firstNameController.text = currentUser.firstName;
        _lastNameController.text = currentUser.lastName;
        _emailController.text = currentUser.email;
        _companyController.text = currentUser.companyName ?? '';
        _jobTitleController.text = currentUser.jobTitle ?? '';
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    
    return currentUserAsync.when(
      data: (currentUser) {
        final isRecruiter = currentUser?.isRecruiter ?? false;

    return Scaffold(
      appBar: AppBar(
            title: const Logo1(height: 100, fit: BoxFit.contain),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          context.go('/profile');
        },
      ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    key: ValueKey(currentUser?.profileImageUrl ?? 'no-photo'),
                    radius: 46,
                    backgroundColor: const Color(0xFF5271FF),
                    child: Builder(
                      builder: (_) {
                        final photoUrl = currentUser?.profileImageUrl;
                        final imageProvider = StorageService.resolveProfileImage(photoUrl);
                        return CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white,
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? const Icon(Icons.person, size: 42, color: Color(0xFF5271FF))
                              : null,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(color: Color(0xFF5271FF), shape: BoxShape.circle),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                          onPressed: () async {
                              final uid = ref.read(currentUserIdProvider);
                              if (uid == null) return;
                              try {
                                final source = await showModalBottomSheet<dynamic>(
                                  context: context,
                                  builder: (ctx) => SafeArea(
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.photo_library),
                                          title: const Text('Galerie'),
                                          onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.photo_camera),
                                          title: const Text('Caméra'),
                                          onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete, color: Colors.red),
                                          title: const Text('Supprimer la photo'),
                                          onTap: () => Navigator.of(ctx).pop('delete'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                if (source == null) return;

                                if (source == 'delete') {
                                  await StorageService.deleteUserProfileImage(uid: uid);
                                  await FirebaseUserService.clearProfileImageUrl(uid);
                                  
                                  // Vider le cache d'images pour forcer le rechargement
                                  PaintingBinding.instance.imageCache.clear();
                                  PaintingBinding.instance.imageCache.clearLiveImages();
                                  
                                  ref.invalidate(currentUserProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Photo supprimée')),
                                    );
                                  }
                                  return;
                                }

                                final picker = ImagePicker();
                                final picked = await picker.pickImage(source: source as ImageSource, imageQuality: 90);
                                if (picked == null) return;

                                File? file;
                                Uint8List? webImageBytes;
                                final mimeType = picked.mimeType ?? 'image/jpeg';

                                if (kIsWeb) {
                                  webImageBytes = await picked.readAsBytes();
                                } else {
                                  file = File(picked.path);
                                  var processedFile = file;
                                  final cropped = await StorageService.cropSquare(processedFile);
                                  if (cropped == null) {
                                    processedFile = file;
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
                                await FirebaseUserService.updateProfileImageUrl(uid, url);
                                
                                // Vider le cache d'images pour forcer le rechargement
                                PaintingBinding.instance.imageCache.clear();
                                PaintingBinding.instance.imageCache.clearLiveImages();
                                
                                ref.invalidate(currentUserProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Photo mise à jour')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
            ),
            const SizedBox(height: 24),

                Text('Informations personnelles', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'Prénom', border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.isEmpty) ? 'Prénom requis' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.isEmpty) ? 'Nom requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email requis';
                if (!v.contains('@')) return 'Email invalide';
                return null;
              },
            ),

            const SizedBox(height: 24),
                Text('Informations professionnelles', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
            if (isRecruiter) ...[
              TextFormField(
                controller: _companyController,
                    decoration: const InputDecoration(labelText: 'Entreprise', border: OutlineInputBorder()),
                ),
                  const SizedBox(height: 12),
              TextFormField(
                controller: _jobTitleController,
                    decoration: const InputDecoration(labelText: 'Poste', border: OutlineInputBorder()),
                ),
                ] else ...[
            TextFormField(
                    controller: _jobTitleController,
                    decoration: const InputDecoration(labelText: 'Poste (optionnel)', border: OutlineInputBorder()),
                  ),
                ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
                  height: 48,
                  child: FilledButton(
                onPressed: _saveProfile,
                    child: const Text('Sauvegarder les modifications'),
                  ),
                ),
              ],
        ),
      ),
    );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      // Préparer les données à mettre à jour
      final updateData = <String, dynamic>{
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'name': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        'email': _emailController.text.trim(),
      };
      
      // Ajouter les champs spécifiques selon le rôle
      final currentUserAsync = ref.read(currentUserProvider);
      currentUserAsync.whenData((currentUser) {
        final isRecruiter = currentUser?.isRecruiter ?? false;
        
        if (isRecruiter) {
          updateData['companyName'] = _companyController.text.trim();
          updateData['jobTitle'] = _jobTitleController.text.trim();
        } else {
          updateData['jobTitle'] = _jobTitleController.text.trim();
        }
      });
      
      // Mettre à jour via AuthService
      await AuthService.updateUserData(updateData);
      
      // Attendre un peu pour que Firestore se synchronise
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      // Invalider le provider pour rafraîchir les données
      ref.invalidate(currentUserProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Attendre un peu avant de naviguer pour que le message s'affiche
        await Future<void>.delayed(const Duration(milliseconds: 300));
        context.go('/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
