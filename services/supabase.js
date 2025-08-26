const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function fetchLightsAndCycles() {
  const {
    data: lights,
    error: lightsError,
  } = await supabase.from('lights').select('*');
  if (lightsError) {
    console.error('Error fetching lights:', lightsError);
    return { lights: [], cycles: [], error: lightsError };
  }

  const {
    data: cycles,
    error: cyclesError,
  } = await supabase.from('light_cycles').select('*');
  if (cyclesError) {
    console.error('Error fetching cycles:', cyclesError);
    return { lights: lights || [], cycles: [], error: cyclesError };
  }

  return { lights: lights || [], cycles: cycles || [], error: null };
}

function subscribeLightCycles(cb) {
  return supabase
    .channel('public:light_cycles')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'light_cycles' },
      payload => cb(payload.new)
    )
    .subscribe();
}

module.exports = {
  supabase,
  fetchLightsAndCycles,
  subscribeLightCycles,
};

