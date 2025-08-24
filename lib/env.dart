/// Environment constants for Supabase and other services.

/// Supabase project URL provided via `--dart-define`.
///
/// Pass `--dart-define=SUPABASE_URL=your_url` when running or building the app.
/// If not supplied, this defaults to an empty string which will cause network
/// requests to fail.
const String supabaseUrl =
    String.fromEnvironment('SUPABASE_URL', defaultValue: '');

/// Supabase anon public key supplied with `--dart-define`.
///
/// Use `--dart-define=SUPABASE_ANON_KEY=your_key` to provide the value. An empty
/// default is used when no key is configured.
const String supabaseAnonKey =
    String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

/// OpenRouteService API key used for routing requests.
const String orsApiKey = String.fromEnvironment('ORS_API_KEY', defaultValue: '');

