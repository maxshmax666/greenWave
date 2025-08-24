/// Environment configuration for the application.

class Env {
  /// Supabase project URL passed via `--dart-define` at build time.
  static const supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  /// Public anon key for the Supabase project, provided at build time.
  static const supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// Key used to persist the Supabase session locally.
  static const supabaseSessionKey = 'supabase_session';

  /// OAuth client IDs passed via `--dart-define` at build time.
  static const googleClientId =
      String.fromEnvironment('SUPABASE_GOOGLE_CLIENT_ID', defaultValue: '');
  static const appleClientId =
      String.fromEnvironment('SUPABASE_APPLE_CLIENT_ID', defaultValue: '');

  /// OpenRouteService API key used for routing requests.
  static const orsApiKey =
      String.fromEnvironment('ORS_API_KEY', defaultValue: '');
}

