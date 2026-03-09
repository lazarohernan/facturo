import 'dart:io';
import 'package:facturo/core/services/storage_service.dart';
import 'package:facturo/features/invoices/models/invoice_attachment_model.dart';
import 'package:facturo/features/invoices/models/invoice_item_model.dart';
import 'package:facturo/features/invoices/models/invoice_model.dart';
import 'package:facturo/features/subscriptions/services/subscription_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class InvoiceService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SubscriptionService? _subscriptionService;

  // Límite de facturas en la versión gratuita
  static const int freeInvoiceLimit = 5;

  InvoiceService({SubscriptionService? subscriptionService})
    : _subscriptionService = subscriptionService;

  // Get all invoices for the current user
  Future<List<Invoice>> getInvoices() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('invoices')
          .select()
          .eq('user_id', userId)
          .eq('status', true)
          .order('document_date', ascending: false);

      // Convert response to Invoice objects
      final invoices = response
          .map<Invoice>((json) => Invoice.fromJson(json))
          .toList();

      // Load details for each invoice
      for (var i = 0; i < invoices.length; i++) {
        final details = await getInvoiceDetails(invoices[i].id);
        invoices[i] = invoices[i].copyWith(details: details);
      }

      return invoices;
    } catch (e) {
      throw Exception('Failed to get invoices: $e');
    }
  }

  // Get invoice details
  Future<List<InvoiceItem>> getInvoiceDetails(String invoiceId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('invoice_detail')
          .select()
          .eq('invoice_id', invoiceId)
          .eq('user_id', userId);

      return response.map<InvoiceItem>((json) {
        return InvoiceItem(
          id: json['id'] ?? '',
          invoiceId: json['invoice_id'],
          description: json['description'],
          quantity: json['quantity']?.toDouble(),
          unitCost: json['unit_cost']?.toDouble(),
          discountAmount: json['discount_amount']?.toDouble(),
          discountType: json['discount_type'],
          taxable: json['taxable'],
          taxRate:
              0, // Asumimos un valor por defecto ya que no existe en el modelo anterior
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get invoice details: $e');
    }
  }

  // Get a single invoice with its details
  Future<Invoice> getInvoice(String invoiceId) async {
    try {
      final invoiceResponse = await _supabase
          .from('invoices')
          .select()
          .eq('id', invoiceId)
          .single();

      final invoice = Invoice.fromJson(invoiceResponse);

      // Get invoice details
      final details = await getInvoiceDetails(invoiceId);

      return invoice.copyWith(details: details);
    } catch (e) {
      throw Exception('Failed to get invoice: $e');
    }
  }

  // Create a new invoice
  Future<Invoice> createInvoice(Invoice invoice) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user has active subscription first
      if (_subscriptionService != null) {
        try {
          final subscription = await _subscriptionService
              .getCurrentSubscription();
          if (subscription.isActive) {
            debugPrint(
              '✅ User has active subscription, skipping invoice limit check',
            );
          } else {
            // Check if user is within free tier limits
            final currentInvoiceCount = await getActiveInvoiceCount();
            if (currentInvoiceCount >= freeInvoiceLimit) {
              throw const FreeTierLimitExceededException(
                'You have reached the limit of $freeInvoiceLimit invoices in the free tier. '
                'Please upgrade your subscription to create more invoices.',
              );
            }
          }
        } catch (e) {
          debugPrint(
            'Error checking subscription: $e, proceeding with limit check',
          );
          // Check if user is within free tier limits
          final currentInvoiceCount = await getActiveInvoiceCount();
          if (currentInvoiceCount >= freeInvoiceLimit) {
            throw const FreeTierLimitExceededException(
              'You have reached the limit of $freeInvoiceLimit invoices in the free tier. '
              'Please upgrade your subscription to create more invoices.',
            );
          }
        }
      } else {
        // Check if user is within free tier limits
        final currentInvoiceCount = await getActiveInvoiceCount();
        if (currentInvoiceCount >= freeInvoiceLimit) {
          throw const FreeTierLimitExceededException(
            'You have reached the limit of $freeInvoiceLimit invoices in the free tier. '
            'Please upgrade your subscription to create more invoices.',
          );
        }
      }

      // Create invoice
      final invoiceData = invoice.toJson();
      invoiceData['user_id'] = userId;

      final response = await _supabase
          .from('invoices')
          .insert(invoiceData)
          .select()
          .single();

      final createdInvoice = Invoice.fromJson(response);

      // Create invoice details if available
      if (invoice.details != null && invoice.details!.isNotEmpty) {
        for (var detail in invoice.details!) {
          final detailData = {
            'invoice_id': createdInvoice.id,
            'user_id': userId,
            'description': detail.description,
            'unit_cost': detail.unitCost,
            'quantity': detail.quantity,
            'discount_type': detail.discountType,
            'discount_amount': detail.discountAmount,
            'taxable': detail.taxable,
            'additional_details': '', // Este campo no existe en el nuevo modelo
          };

          await _supabase.from('invoice_detail').insert(detailData);
        }
      }

      return createdInvoice;
    } catch (e) {
      if (e is FreeTierLimitExceededException) {
        rethrow;
      }
      throw Exception('Failed to create invoice: $e');
    }
  }

  // Update an existing invoice
  Future<Invoice> updateInvoice(Invoice invoice) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Update invoice
      final invoiceData = invoice.toJson();
      invoiceData['user_id'] = userId; // Ensure user_id is included

      final response = await _supabase
          .from('invoices')
          .update(invoiceData)
          .eq('id', invoice.id)
          .eq('user_id', userId) // Add user_id to the where clause
          .select()
          .single();

      final updatedInvoice = Invoice.fromJson(response);

      // Handle invoice details
      if (invoice.details != null) {
        // First, delete existing details
        await _supabase
            .from('invoice_detail')
            .delete()
            .eq('invoice_id', invoice.id)
            .eq('user_id', userId); // Add user_id to the where clause

        // Then, insert new details
        for (var detail in invoice.details!) {
          final detailData = {
            'invoice_id': updatedInvoice.id,
            'user_id': userId,
            'description': detail.description,
            'unit_cost': detail.unitCost,
            'quantity': detail.quantity,
            'discount_type': detail.discountType,
            'discount_amount': detail.discountAmount,
            'taxable': detail.taxable,
            'additional_details': '', // Este campo no existe en el nuevo modelo
          };

          await _supabase.from('invoice_detail').insert(detailData);
        }
      }

      return updatedInvoice;
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }

  // Delete an invoice (soft delete by setting status to false)
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _supabase
          .from('invoices')
          .update({'status': false})
          .eq('id', invoiceId);
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }

  // Search invoices
  Future<List<Invoice>> searchInvoices(String query) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('invoices')
          .select()
          .eq('user_id', userId)
          .eq('status', true)
          .or(
            'document_number.ilike.%$query%,notes.ilike.%$query%,po_number.ilike.%$query%',
          )
          .order('document_date', ascending: false);

      // Convert response to Invoice objects
      final invoices = response
          .map<Invoice>((json) => Invoice.fromJson(json))
          .toList();

      // Load details for each invoice
      for (var i = 0; i < invoices.length; i++) {
        final details = await getInvoiceDetails(invoices[i].id);
        invoices[i] = invoices[i].copyWith(details: details);
      }

      return invoices;
    } catch (e) {
      throw Exception('Failed to search invoices: $e');
    }
  }

  // Update invoice paid status
  Future<void> updateInvoicePaidStatus(String invoiceId, bool paid) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('invoices')
          .update({'paid': paid})
          .eq('id', invoiceId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to update invoice paid status: $e');
    }
  }

  // Get active invoice count for the current user
  Future<int> getActiveInvoiceCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('invoices')
          .select('id')
          .eq('user_id', userId)
          .eq('status', true);

      return response.length;
    } catch (e) {
      throw Exception('Failed to get invoice count: $e');
    }
  }

  // Generate the next invoice number for the current user.
  Future<String> generateNextDocumentNumber({String prefix = 'INV'}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('invoices')
          .select('document_number')
          .eq('user_id', userId)
          .not('document_number', 'is', null);

      final normalizedPrefix = prefix.trim().toUpperCase();
      final escapedPrefix = RegExp.escape(normalizedPrefix);
      final prefixedPattern = RegExp(
        '^$escapedPrefix[-\\s]?(\\d+)\$',
        caseSensitive: false,
      );
      final legacyDigitsPattern = RegExp(r'^(\d+)$');
      var maxSequence = 0;

      for (final row in response) {
        final documentNumber = row['document_number']?.toString().trim();
        if (documentNumber == null || documentNumber.isEmpty) {
          continue;
        }

        final match =
            prefixedPattern.firstMatch(documentNumber) ??
            (normalizedPrefix == 'INV'
                ? legacyDigitsPattern.firstMatch(documentNumber)
                : null);
        final sequence = int.tryParse(match?.group(1) ?? '');

        if (sequence != null && sequence > maxSequence) {
          maxSequence = sequence;
        }
      }

      return '$normalizedPrefix-${(maxSequence + 1).toString().padLeft(4, '0')}';
    } catch (e) {
      throw Exception('Failed to generate invoice number: $e');
    }
  }

  // ─── Attachment methods ───────────────────────────────────────────────────

  /// Fetch all attachments for a given invoice, ordered by sort_order.
  Future<List<InvoiceAttachment>> getInvoiceAttachments(
      String invoiceId) async {
    try {
      final response = await _supabase
          .from('invoice_attachments')
          .select()
          .eq('invoice_id', invoiceId)
          .order('sort_order', ascending: true);

      return response
          .map<InvoiceAttachment>((json) => InvoiceAttachment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get invoice attachments: $e');
    }
  }

  /// Upload [files] and insert attachment records for [invoiceId].
  /// Returns the list of created [InvoiceAttachment] objects.
  Future<List<InvoiceAttachment>> saveInvoiceAttachments({
    required String invoiceId,
    required List<File> files,
    int startSortOrder = 0,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final storageService = StorageService(_supabase);
    final created = <InvoiceAttachment>[];

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final ext = file.path.split('.').last.toLowerCase();
      final fileName = '${const Uuid().v4()}.$ext';
      final storagePath = 'invoices/$invoiceId/$fileName';
      final mimeType = _mimeFromExt(ext);

      await storageService.uploadFile(filePath: storagePath, file: file);

      final row = await _supabase
          .from('invoice_attachments')
          .insert({
            'invoice_id': invoiceId,
            'user_id': userId,
            'storage_path': storagePath,
            'mime_type': mimeType,
            'file_name': file.path.split('/').last,
            'sort_order': startSortOrder + i,
          })
          .select()
          .single();

      created.add(InvoiceAttachment.fromJson(row));
    }

    return created;
  }

  /// Delete a single attachment record and its storage file.
  Future<void> deleteInvoiceAttachment(InvoiceAttachment attachment) async {
    final storageService = StorageService(_supabase);
    await storageService.deleteFile(attachment.storagePath);
    await _supabase
        .from('invoice_attachments')
        .delete()
        .eq('id', attachment.id);
  }

  /// Delete all attachments for an invoice (used when deleting the invoice).
  Future<void> deleteAllAttachments(String invoiceId) async {
    final attachments = await getInvoiceAttachments(invoiceId);
    for (final a in attachments) {
      await deleteInvoiceAttachment(a);
    }
  }

  static String? _mimeFromExt(String ext) {
    const map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'heic': 'image/heic',
    };
    return map[ext];
  }

  // Helper method to create an InvoiceItem with the current user's ID
  InvoiceItem createInvoiceItem({
    String? invoiceId,
    String? description,
    double? unitCost,
    double? quantity,
    String? discountType,
    double? discountAmount,
    bool? taxable,
    double? taxRate,
  }) {
    return InvoiceItem(
      invoiceId: invoiceId,
      description: description,
      unitCost: unitCost,
      quantity: quantity,
      discountType: discountType,
      discountAmount: discountAmount,
      taxable: taxable,
      taxRate: taxRate,
    );
  }
}

// Excepción personalizada para límites de versión gratuita
class FreeTierLimitExceededException implements Exception {
  final String message;

  const FreeTierLimitExceededException(this.message);

  @override
  String toString() => message;
}
