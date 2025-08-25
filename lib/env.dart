/// Environment constants for Supabase and other services.

/// Supabase project URL.
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

/// Supabase anon public key.
const String supabaseAnonKey =
    String.fromEnvironment('SUPABASE_ANON_KEY');

/// OpenRouteService API key used for routing requests.
/// Defaults to empty string when not provided.
const String orsApiKey = String.fromEnvironment('ORS_API_KEY',
    defaultValue: '');
