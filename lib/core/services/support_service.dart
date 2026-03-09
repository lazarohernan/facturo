import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupportService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Envía un reporte de problema a Supabase
  static Future<void> sendSupportRequest({
    required String problemTitle,
    required String problemDescription,
    required String userEmail,
    String? platform,
    String? appVersion,
  }) async {
    try {
      await _supabase.from('support_requests').insert({
        'user_id': _supabase.auth.currentUser?.id,
        'title': problemTitle.trim(),
        'description': problemDescription.trim(),
        'user_email': userEmail,
        'platform': platform ?? 'unknown',
        'app_version': appVersion ?? 'unknown',
        'status': 'pending',
        'priority': 'medium',
      });

      if (kDebugMode) {
        debugPrint('Solicitud de soporte guardada exitosamente');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al guardar solicitud de soporte: $e');
      }
      rethrow;
    }
  }
}
