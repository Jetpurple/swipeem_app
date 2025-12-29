import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  /// Obtient le répertoire de stockage des images de profil
  static Future<Directory> _getProfileImagesDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Le stockage local des images n\'est pas disponible sur le web.',
      );
    }

    Directory baseDir;

    try {
      baseDir = await getApplicationSupportDirectory();
    } catch (_) {
      // Fallback sur le répertoire documents si le répertoire Support n'est pas disponible
      baseDir = await getApplicationDocumentsDirectory();
    }

    final Directory profileImagesDir = Directory('${baseDir.path}/profile_images');

    // Créer le répertoire s'il n'existe pas
    if (!await profileImagesDir.exists()) {
      await profileImagesDir.create(recursive: true);
    }

    return profileImagesDir;
  }

  /// Obtient le répertoire de stockage pour un utilisateur spécifique
  static Future<Directory> _getUserProfileDirectory(String uid) async {
    final Directory profileImagesDir = await _getProfileImagesDirectory();
    final Directory userDir = Directory('${profileImagesDir.path}/$uid');
    
    // Créer le répertoire utilisateur s'il n'existe pas
    if (!await userDir.exists()) {
      await userDir.create(recursive: true);
    }
    
    return userDir;
  }

  /// Upload (sauvegarde locale) de l'image de profil d'un utilisateur
  static Future<String> uploadUserProfileImage({
    required String uid,
    File? file,
    Uint8List? webImageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    debugPrint('📤 uploadUserProfileImage - uid: $uid, isWeb: $kIsWeb');
    
    if (kIsWeb) {
      if (webImageBytes == null) {
        throw Exception('Aucune donnée image fournie pour le web.');
      }

      debugPrint('📤 Web: encodage de ${webImageBytes.length} bytes en base64...');
      final String base64Data = base64Encode(webImageBytes);
      
      // Vérification de la taille (Firestore limite à 1 MiB par document)
      // 1 MiB = 1,048,576 bytes. Base64 ajoute ~33% d'overhead.
      if (base64Data.length > 1000000) {
        throw Exception(
          'L\'image est trop volumineuse pour le web. Veuillez choisir une image plus petite.',
        );
      }

      final String dataUri = 'data:$mimeType;base64,$base64Data';
      debugPrint('✅ Data URI créée: ${dataUri.substring(0, dataUri.length > 100 ? 100 : dataUri.length)}...');
      return dataUri;
    }

    if (file == null) {
      throw Exception('Aucun fichier fourni pour la sauvegarde.');
    }

    try {
      final Directory userDir = await _getUserProfileDirectory(uid);
      final String destinationPath = '${userDir.path}/profile.jpg';
      debugPrint('📤 Destination: $destinationPath');

      final File destinationFile = File(destinationPath);
      if (await destinationFile.exists()) {
        debugPrint('🗑️ Suppression de l\'ancienne photo');
        await destinationFile.delete();
      }

      // Copier le fichier dans le répertoire de l'utilisateur
      final File savedFile = await file.copy(destinationPath);
      debugPrint('✅ Fichier sauvegardé: ${savedFile.path}');

      // Retourner le chemin local du fichier
      return savedFile.path;
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la sauvegarde de la photo de profil: $e');
      debugPrint('$stackTrace');
      throw Exception('Sauvegarde échouée: $e');
    }
  }

  /// Suppression de l'image de profil d'un utilisateur
  static Future<void> deleteUserProfileImage({required String uid}) async {
    if (kIsWeb) {
      // Sur le web, l'image est stockée directement dans Firestore (data URI).
      // Rien à supprimer localement.
      return;
    }

    try {
      final Directory userDir = await _getUserProfileDirectory(uid);
      final File profileFile = File('${userDir.path}/profile.jpg');
      
      if (await profileFile.exists()) {
        await profileFile.delete();
      }
    } catch (_) {
      // ignore if file does not exist
    }
  }

  static Future<File?> cropSquare(File file) async {
    // Web fallback: image_cropper web interface is unstable; skip crop on web
    if (kIsWeb) return file;

    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 512,
      maxHeight: 512,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer',
          toolbarColor: const Color(0xFF5271FF),
          toolbarWidgetColor: const Color(0xFFFFFFFF),
          activeControlsWidgetColor: const Color(0xFF5271FF),
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Recadrer',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (cropped == null) return null;
    return File(cropped.path);
  }

  /// Résout un [ImageProvider] depuis un chemin/URL ou data URI stocké.
  static ImageProvider? resolveProfileImage(String? path) {
    debugPrint('🖼️ resolveProfileImage appelé avec: ${path?.substring(0, path.length > 100 ? 100 : path.length)}...');
    
    if (path == null || path.isEmpty) {
      debugPrint('❌ Chemin vide ou null');
      return null;
    }

    if (path.startsWith('http')) {
      debugPrint('✅ Image réseau détectée');
      return NetworkImage(path);
    }

    if (path.startsWith('data:image')) {
      debugPrint('✅ Data URI détectée');
      final parts = path.split(',');
      if (parts.length < 2) {
        debugPrint('❌ Data URI mal formée');
        return null;
      }
      try {
        final bytes = base64Decode(parts.last);
        debugPrint('✅ Data URI décodée avec succès (${bytes.length} bytes)');
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint('❌ Erreur de décodage base64: $e');
        return null;
      }
    }

    if (kIsWeb) {
      debugPrint('⚠️ Sur web mais pas de data URI, retour null');
      return null;
    }

    final file = File(path);
    if (!file.existsSync()) {
      debugPrint('❌ Fichier local inexistant: $path');
      return null;
    }

    debugPrint('✅ Fichier local trouvé');
    return FileImage(file);
  }
}
