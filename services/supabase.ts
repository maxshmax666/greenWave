import {
  createClient,
  SupabaseClient,
  RealtimeChannel,
  RealtimePostgresChangesPayload,
} from '@supabase/supabase-js';
import { fetchWithTimeout } from './network';
import { log } from './logger';
import type { Light, LightCycle } from '../src/domain/types';

const SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL ?? '';
const SUPABASE_ANON_KEY = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? '';

export const supabase: SupabaseClient = createClient(
  SUPABASE_URL,
  SUPABASE_ANON_KEY,
  {
    global: { fetch: fetchWithTimeout },
  },
);

export async function fetchLightsAndCycles(): Promise<{
  lights: Light[];
  cycles: LightCycle[];
  error: Error | null;
}> {
  const { data: lights, error: lightsError } = await supabase
    .from('lights')
    .select('*');
  if (lightsError) {
    await log('ERROR', `Error fetching lights: ${lightsError.message}`);
    return {
      lights: [],
      cycles: [],
      error: new Error('Unable to load lights data. Please try again later.'),
    };
  }

  const { data: cycles, error: cyclesError } = await supabase
    .from('light_cycles')
    .select('*');
  if (cyclesError) {
    await log('ERROR', `Error fetching cycles: ${cyclesError.message}`);
    return {
      lights: lights || [],
      cycles: [],
      error: new Error('Unable to load cycle data. Please try again later.'),
    };
  }

  return {
    lights: (lights as Light[]) || [],
    cycles: (cycles as LightCycle[]) || [],
    error: null,
  };
}

export function subscribeLightCycles(
  cb: (cycle: LightCycle) => void,
): RealtimeChannel {
  return supabase
    .channel('public:light_cycles')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'light_cycles' },
      (payload: RealtimePostgresChangesPayload<LightCycle>) =>
        cb(payload.new as LightCycle),
    )
    .subscribe();
}
