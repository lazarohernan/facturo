import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/features/clients/models/client_model.dart';
import 'package:facturo/features/clients/services/client_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Client state
enum ClientState { initial, loading, loaded, error }

// Client list data class
class ClientListData {
  final ClientState state;
  final List<Client> clients;
  final String? errorMessage;
  final String? searchQuery;

  ClientListData({
    this.state = ClientState.initial,
    this.clients = const [],
    this.errorMessage,
    this.searchQuery,
  });

  ClientListData copyWith({
    ClientState? state,
    List<Client>? clients,
    String? errorMessage,
    String? searchQuery,
  }) {
    return ClientListData(
      state: state ?? this.state,
      clients: clients ?? this.clients,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Client detail data class
class ClientDetailData {
  final ClientState state;
  final Client? client;
  final String? errorMessage;

  ClientDetailData({
    this.state = ClientState.initial,
    this.client,
    this.errorMessage,
  });

  ClientDetailData copyWith({
    ClientState? state,
    Client? client,
    String? errorMessage,
  }) {
    return ClientDetailData(
      state: state ?? this.state,
      client: client ?? this.client,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Client list notifier
class ClientListNotifier extends StateNotifier<ClientListData> {
  final Ref ref;

  ClientListNotifier(this.ref) : super(ClientListData()) {
    // Load clients when created
    loadClients();
  }

  // Load all clients
  Future<void> loadClients() async {
    try {
      state = state.copyWith(state: ClientState.loading);

      final authState = ref.read(authControllerProvider);
      if (authState.user == null) {
        state = state.copyWith(
          state: ClientState.error,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final clientService = ref.read(clientServiceProvider);
      // Fetch clients with status == TRUE
      final clients = await clientService.getClients(authState.user!.id);
      final activeClients =
          clients.where((client) => client.status == true).toList();

      state = state.copyWith(state: ClientState.loaded, clients: activeClients);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading clients: $e');
      }
      state = state.copyWith(
        state: ClientState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Search clients
  Future<void> searchClients(String query) async {
    try {
      state = state.copyWith(state: ClientState.loading, searchQuery: query);

      if (query.isEmpty) {
        await loadClients();
        return;
      }

      final authState = ref.read(authControllerProvider);
      if (authState.user == null) {
        state = state.copyWith(
          state: ClientState.error,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final clientService = ref.read(clientServiceProvider);
      final clients = await clientService.searchClients(
        authState.user!.id,
        query,
      );

      state = state.copyWith(state: ClientState.loaded, clients: clients);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error searching clients: $e');
      }
      state = state.copyWith(
        state: ClientState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Delete a client
  Future<void> deleteClient(String clientId) async {
    try {
      final clientService = ref.read(clientServiceProvider);
      // Update the client's status to FALSE instead of deleting
      await clientService.updateClientStatus(clientId, false);

      // Refresh the client list
      await loadClients();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting client: $e');
      }
      state = state.copyWith(
        state: ClientState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Reset the client list
  void reset() {
    state = state.copyWith(state: ClientState.initial, clients: const []);
  }
}

// Client detail notifier
class ClientDetailNotifier extends StateNotifier<ClientDetailData> {
  final Ref ref;

  ClientDetailNotifier(this.ref) : super(ClientDetailData());

  // Load a client by ID
  Future<void> loadClient(String clientId) async {
    try {
      state = state.copyWith(state: ClientState.loading);

      final clientService = ref.read(clientServiceProvider);
      final client = await clientService.getClient(clientId);

      state = state.copyWith(state: ClientState.loaded, client: client);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading client: $e');
      }
      state = state.copyWith(
        state: ClientState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Create a new client
  Future<Client?> createClient(Client client) async {
    try {
      state = state.copyWith(state: ClientState.loading);

      final authState = ref.read(authControllerProvider);
      if (authState.user == null) {
        state = state.copyWith(
          state: ClientState.error,
          errorMessage: 'User not authenticated',
        );
        return null;
      }

      final clientService = ref.read(clientServiceProvider);
      final createdClient = await clientService.createClient(
        client,
        authState.user!.id,
      );

      state = state.copyWith(state: ClientState.loaded, client: createdClient);

      // Refresh the client list
      ref.read(clientsProvider.notifier).loadClients();

      return createdClient;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating client: $e');
      }
      state = state.copyWith(
        state: ClientState.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  // Update an existing client
  Future<Client?> updateClient(Client client) async {
    try {
      state = state.copyWith(state: ClientState.loading);

      final clientService = ref.read(clientServiceProvider);
      final updatedClient = await clientService.updateClient(client);

      state = state.copyWith(state: ClientState.loaded, client: updatedClient);

      // Refresh the client list
      ref.read(clientsProvider.notifier).loadClients();

      return updatedClient;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating client: $e');
      }
      state = state.copyWith(
        state: ClientState.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  // Reset the client detail
  void reset() {
    state = state.copyWith(state: ClientState.initial, client: null);
  }
}

// Client list provider
final clientListProvider =
    StateNotifierProvider<ClientListNotifier, ClientListData>((ref) {
      return ClientListNotifier(ref);
    });

// Client detail provider
final clientDetailProvider =
    StateNotifierProvider<ClientDetailNotifier, ClientDetailData>((ref) {
      return ClientDetailNotifier(ref);
    });

// Provider que mantiene la lista de clientes
final clientsProvider = StateNotifierProvider<ClientsNotifier, List<Client>>((ref) {
  final clientService = ref.watch(clientServiceProvider);
  return ClientsNotifier(clientService);
});

class ClientsNotifier extends StateNotifier<List<Client>> {
  final ClientService _clientService;

  ClientsNotifier(this._clientService) : super([]) {
    // Inicializa cargando los clientes
    loadClients();
  }

  Future<void> loadClients() async {
    try {
      final clients = await _clientService.getClients();
      state = clients;
    } catch (e) {
      // En caso de error, mantenemos el estado actual
      debugPrint('Error cargando clientes: $e');
    }
  }

  Future<void> addClient(Client client, String userId) async {
    try {
      final newClient = await _clientService.createClient(client, userId);
      state = [...state, newClient];
    } catch (e) {
      debugPrint('Error añadiendo cliente: $e');
      rethrow;
    }
  }

  Future<void> updateClient(Client client) async {
    try {
      final updatedClient = await _clientService.updateClient(client);
      state = [
        for (final c in state)
          if (c.id == client.id) updatedClient else c
      ];
    } catch (e) {
      debugPrint('Error actualizando cliente: $e');
      rethrow;
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      await _clientService.deleteClient(clientId);
      state = state.where((c) => c.id != clientId).toList();
    } catch (e) {
      debugPrint('Error eliminando cliente: $e');
      rethrow;
    }
  }

  List<Client> searchClients(String query) {
    if (query.isEmpty) return state;
    
    final lowercaseQuery = query.toLowerCase();
    return state.where((client) {
      final name = client.name.toLowerCase();
      final email = client.email?.toLowerCase() ?? '';
      final phone = client.phone?.toLowerCase() ?? '';
      final company = client.company?.toLowerCase() ?? '';
      final address = client.address?.toLowerCase() ?? '';

      return name.contains(lowercaseQuery) ||
          email.contains(lowercaseQuery) ||
          phone.contains(lowercaseQuery) ||
          company.contains(lowercaseQuery) ||
          address.contains(lowercaseQuery);
    }).toList();
  }
}

// Provider temporal para cliente prellenado (usado al importar desde contactos)
class PrefilledClientNotifier extends StateNotifier<Client?> {
  PrefilledClientNotifier() : super(null);

  void setClient(Client client) {
    state = client;
  }

  void clear() {
    state = null;
  }
}

final prefilledClientProvider = StateNotifierProvider<PrefilledClientNotifier, Client?>((ref) {
  return PrefilledClientNotifier();
});
