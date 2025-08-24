/// Environment constants for Supabase and other services.

/// Supabase project URL.
const String supabaseUrl = "https://YOUR_PROJECT_ID.supabase.co";

/// Supabase anon public key.
const String supabaseAnonKey = "YOUR_ANON_PUBLIC_KEY";

/// OpenRouteService API key used for routing requests.
const String orsApiKey = String.fromEnvironment('ORS_API_KEY', defaultValue: '');

