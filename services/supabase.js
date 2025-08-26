import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY;

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

export async function fetchLightsAndCycles() {
  const { data: lights } = await supabase.from('lights').select('*');
  const { data: cycles } = await supabase.from('light_cycles').select('*');
  return { lights: lights || [], cycles: cycles || [] };
}

export function subscribeLightCycles(cb) {
  return supabase
    .channel('public:light_cycles')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'light_cycles' },
      payload => cb(payload.new)
    )
    .subscribe();
}
