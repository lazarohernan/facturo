import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class ImageCropService {
  static Future<File?> cropProfileImage(BuildContext context, File sourceFile) async {
    try {
      final l10n = AppLocalizations.of(context);
      final isDark = Theme.of(context).brightness == Brightness.dark;
      debugPrint('✂️ Starting image crop for profile');

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: sourceFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Square aspect ratio
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: l10n.cropProfilePhoto,
            toolbarColor: const Color(0xFF1E3A8A),
            toolbarWidgetColor: const Color(0xFFFFFFFF),
            backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF),
            activeControlsWidgetColor: const Color(0xFF2563EB),
            dimmedLayerColor: const Color(0x80000000),
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: l10n.cropProfilePhoto,
            cancelButtonTitle: l10n.cancel,
            doneButtonTitle: l10n.done,
            aspectRatioLockEnabled: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        final file = File(croppedFile.path);
        debugPrint('✅ Image cropped successfully: ${file.path}');
        return file;
      } else {
        debugPrint('⚠️ Image cropping cancelled by user');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error cropping image: $e');
      return null;
    }
  }

  static Future<File?> cropBusinessLogo(BuildContext context, File sourceFile) async {
    try {
      final l10n = AppLocalizations.of(context);
      final isDark = Theme.of(context).brightness == Brightness.dark;
      debugPrint('✂️ Starting image crop for business logo');

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: sourceFile.path,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 90,
        maxWidth: 1200,
        maxHeight: 675,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: l10n.cropBusinessLogo,
            toolbarColor: const Color(0xFF1E3A8A),
            toolbarWidgetColor: const Color(0xFFFFFFFF),
            backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF),
            activeControlsWidgetColor: const Color(0xFF2563EB),
            dimmedLayerColor: const Color(0x80000000),
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: l10n.cropBusinessLogo,
            cancelButtonTitle: l10n.cancel,
            doneButtonTitle: l10n.done,
            aspectRatioLockEnabled: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        final file = File(croppedFile.path);
        debugPrint('✅ Business logo cropped successfully: ${file.path}');
        return file;
      } else {
        debugPrint('⚠️ Business logo cropping cancelled by user');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error cropping business logo: $e');
      return null;
    }
  }

  static Future<File?> cropDocumentImage(BuildContext context, File sourceFile) async {
    try {
      final l10n = AppLocalizations.of(context);
      final isDark = Theme.of(context).brightness == Brightness.dark;
      debugPrint('✂️ Starting image crop for document');

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: sourceFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        maxWidth: 2000,
        maxHeight: 1500,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: l10n.cropDocument,
            toolbarColor: const Color(0xFF1E3A8A),
            toolbarWidgetColor: const Color(0xFFFFFFFF),
            backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF),
            activeControlsWidgetColor: const Color(0xFF2563EB),
            dimmedLayerColor: const Color(0x80000000),
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.original,
            ],
          ),
          IOSUiSettings(
            title: l10n.cropDocument,
            cancelButtonTitle: l10n.cancel,
            doneButtonTitle: l10n.done,
            aspectRatioLockEnabled: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.original,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        final file = File(croppedFile.path);
        debugPrint('✅ Document cropped successfully: ${file.path}');
        return file;
      } else {
        debugPrint('⚠️ Document cropping cancelled by user');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error cropping document: $e');
      return null;
    }
  }
}
