import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client manager for the app
class SupabaseClientManager {
  // Supabase URL and anon key - these will need to be replaced with your actual values
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false, // Set to true for development
    );
  }

  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;
}
