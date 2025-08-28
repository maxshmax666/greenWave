import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { network } from '../services/network';
import type { SupabaseConfig } from '../interfaces/config';

/**
 * Creates a Supabase client with the provided configuration.
 * @param config Supabase connection details.
 * @returns Configured {@link SupabaseClient} instance.
 */
export function createSupabaseClient(config: SupabaseConfig): SupabaseClient {
  return createClient(config.url, config.anonKey, {
    global: { fetch: network.fetchWithTimeout },
  });
}

const url = process.env.PUBLIC_SUPABASE_URL;
const anonKey = process.env.PUBLIC_SUPABASE_ANON_KEY;
if (!url || !anonKey) {
  throw new Error('Missing Supabase environment variables');
}

/** Shared Supabase client used across services. */
export const supabase: SupabaseClient = createSupabaseClient({ url, anonKey });
