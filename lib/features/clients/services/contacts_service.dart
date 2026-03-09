import 'package:flutter/foundation.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import '../models/client_model.dart';

class ContactsImportService {
  static final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();

  /// Opens the native contact picker and returns the selected contact as a Client
  /// No permissions required - uses native OS picker
  static Future<Client?> pickContactAsClient() async {
    try {
      debugPrint('📞 Abriendo selector de contactos...');
      
      // Open native contact picker (no permissions needed)
      final contact = await _contactPicker.selectContact();
      
      debugPrint('📞 Contacto seleccionado: ${contact?.fullName}');
      debugPrint('📞 Números disponibles: ${contact?.phoneNumbers}');
      
      if (contact == null) {
        debugPrint('📞 Usuario canceló la selección');
        return null; // User cancelled
      }

      // Skip contacts without name
      if (contact.fullName == null || contact.fullName!.isEmpty) {
        debugPrint('❌ Contacto sin nombre');
        throw Exception('Contact has no name');
      }

      // Get phone number
      String? phone;
      if (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty) {
        phone = contact.phoneNumbers!.first;
        debugPrint('📞 Teléfono seleccionado: $phone');
      } else {
        debugPrint('⚠️ Contacto sin número de teléfono');
      }

      // Create client
      final client = Client(
        clientName: contact.fullName!,
        clientMobile: phone,
        createdAt: DateTime.now(),
        status: true,
      );

      debugPrint('✅ Cliente creado: ${client.clientName}, ${client.clientMobile}');
      return client;
    } catch (e) {
      debugPrint('❌ Error al seleccionar contacto: $e');
      throw Exception('Failed to pick contact: $e');
    }
  }
}
