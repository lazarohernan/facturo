import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class StoreRatingService {
  // URLs de las stores (debes reemplazar con las URLs reales de tu app)
  static const String _androidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.facturo.app';
  static const String _iosStoreUrl =
      'https://apps.apple.com/app/facturo/id1234567890';

  /// Abre la store correspondiente según la plataforma
  static Future<void> openStoreForRating() async {
    try {
      final Uri url;

      if (Platform.isAndroid) {
        url = Uri.parse(_androidStoreUrl);
      } else if (Platform.isIOS) {
        url = Uri.parse(_iosStoreUrl);
      } else {
        // Para web o desktop, abrir la store de Android por defecto
        url = Uri.parse(_androidStoreUrl);
      }

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (kDebugMode) {
          debugPrint('No se pudo abrir la URL: $url');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al abrir la store: $e');
      }
    }
  }

  /// Abre la store de Android específicamente
  static Future<void> openAndroidStore() async {
    try {
      final url = Uri.parse(_androidStoreUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al abrir Google Play Store: $e');
      }
    }
  }

  /// Abre la App Store de iOS específicamente
  static Future<void> openIOSStore() async {
    try {
      final url = Uri.parse(_iosStoreUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al abrir App Store: $e');
      }
    }
  }
}
