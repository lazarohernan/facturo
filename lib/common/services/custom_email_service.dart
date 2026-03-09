import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:facturo/core/providers/locale_provider.dart';

class CustomEmailService {
  final SupabaseClient _supabase;
  final LocaleNotifier _localeNotifier;

  CustomEmailService(this._supabase, this._localeNotifier);

  /// Envía un email personalizado según el idioma del usuario
  Future<Map<String, dynamic>> sendCustomEmail({
    required String email,
    required String type, // 'signup', 'reset_password', 'email_change'
    String? userName,
    String? resetLink,
    String? verificationLink,
  }) async {
    try {
      // Obtener el idioma actual del usuario
      final currentLocale = _localeNotifier.currentLocale;
      final locale = currentLocale.languageCode == 'en' ? 'en' : 'es';

      final response = await _supabase.functions.invoke(
        'send-custom-email',
        body: {
          'email': email,
          'type': type,
          'locale': locale,
          if (userName != null) 'userName': userName,
          if (resetLink != null) 'resetLink': resetLink,
          if (verificationLink != null) 'verificationLink': verificationLink,
        },
      );

      if (response.data == null) {
        return {
          'success': false,
          'error': 'No response from server',
        };
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] == true) {
        return {
          'success': true,
          'message': locale == 'en' 
            ? 'Email sent successfully' 
            : 'Correo enviado exitosamente',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Unknown error occurred',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Envía email de confirmación de registro
  Future<Map<String, dynamic>> sendSignupConfirmation({
    required String email,
    String? userName,
    required String verificationLink,
  }) async {
    return sendCustomEmail(
      email: email,
      type: 'signup',
      userName: userName,
      verificationLink: verificationLink,
    );
  }

  /// Envía email de reset de contraseña
  Future<Map<String, dynamic>> sendPasswordReset({
    required String email,
    required String resetLink,
  }) async {
    return sendCustomEmail(
      email: email,
      type: 'reset_password',
      resetLink: resetLink,
    );
  }

  /// Envía email de confirmación de cambio de correo
  Future<Map<String, dynamic>> sendEmailChangeConfirmation({
    required String email,
    required String verificationLink,
  }) async {
    return sendCustomEmail(
      email: email,
      type: 'email_change',
      verificationLink: verificationLink,
    );
  }
}

// Provider para el servicio de email personalizado
final customEmailServiceProvider = Provider<CustomEmailService>((ref) {
  final supabase = Supabase.instance.client;
  final localeNotifier = ref.read(localeProvider.notifier);
  return CustomEmailService(supabase, localeNotifier);
});
