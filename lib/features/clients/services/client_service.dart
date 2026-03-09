import 'package:facturo/core/providers/supabase_providers.dart';
import 'package:facturo/features/clients/models/client_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientService {
  final SupabaseClient _client;

  ClientService(this._client);

  // Get all clients for a user
  Future<List<Client>> getClients([String? userId]) async {
    try {
      // Si no se proporciona userId, intentamos obtener el usuario actual
      userId ??= _client.auth.currentUser?.id;
      
      // Si aún no hay userId, devolvemos una lista vacía
      if (userId == null) {
        return [];
      }
      
      final response = await _client
          .from('clients')
          .select()
          .eq('user_id', userId)
          .order('client_name', ascending: true);

      return response.map((json) => Client.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting clients: $e');
      }
      rethrow;
    }
  }

  // Get a client by ID
  Future<Client> getClient(String clientId) async {
    try {
      final response =
          await _client
              .from('clients')
              .select()
              .eq('clients_id', clientId)
              .single();

      return Client.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting client: $e');
      }
      rethrow;
    }
  }

  // Create a new client
  Future<Client> createClient(Client client, String userId) async {
    try {
      final data = client.toJsonForCreate();
      data['user_id'] = userId;

      final response =
          await _client.from('clients').insert(data).select().single();

      if (kDebugMode) {
        debugPrint('Client created successfully: ${response['clients_id']}');
      }

      return Client.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating client: $e');
      }
      rethrow;
    }
  }

  // Update an existing client
  Future<Client> updateClient(Client client) async {
    try {
      final data = client.toJsonForCreate();

      final response =
          await _client
              .from('clients')
              .update(data)
              .eq('clients_id', client.clientsId)
              .select()
              .single();

      if (kDebugMode) {
        debugPrint('Client updated successfully: ${client.clientsId}');
      }

      return Client.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating client: $e');
      }
      rethrow;
    }
  }

  // Delete a client
  Future<void> deleteClient(String clientId) async {
    try {
      await _client.from('clients').delete().eq('clients_id', clientId);

      if (kDebugMode) {
        debugPrint('Client deleted successfully: $clientId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting client: $e');
      }
      rethrow;
    }
  }

  // Search clients by name or email
  Future<List<Client>> searchClients(String userId, String query) async {
    try {
      final response = await _client
          .from('clients')
          .select()
          .eq('user_id', userId)
          .or('client_name.ilike.%$query%,client_email.ilike.%$query%')
          .order('client_name', ascending: true);

      if (kDebugMode) {
        debugPrint('Found ${response.length} clients matching "$query"');
      }

      return response.map((json) => Client.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error searching clients: $e');
      }
      rethrow;
    }
  }

  // Update the status of a client
  Future<void> updateClientStatus(String clientId, bool status) async {
    try {
      await _client
          .from('clients')
          .update({'status': status})
          .eq('clients_id', clientId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating client status: $e');
      }
      rethrow;
    }
  }
}

// Provider for ClientService
final clientServiceProvider = Provider<ClientService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ClientService(client);
});
