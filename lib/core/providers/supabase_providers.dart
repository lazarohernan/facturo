import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider for Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider for Supabase auth
final supabaseAuthProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth;
});

// Provider for current user
final currentUserProvider = StateProvider<User?>((ref) {
  final auth = ref.watch(supabaseAuthProvider);
  return auth.currentUser;
});

// Provider to check if user is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Provider for auth state changes
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final auth = ref.watch(supabaseAuthProvider);
  return auth.onAuthStateChange;
});

// Supabase configuration
class SupabaseConfig {
  // Get Supabase URL and anon key from environment variables
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> initialize() async {
    // Validate environment variables
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Supabase credentials not found in .env file. Please add SUPABASE_URL and SUPABASE_ANON_KEY to your .env file.',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }
}
