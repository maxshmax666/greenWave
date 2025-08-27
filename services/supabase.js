const { createClient } = require('@supabase/supabase-js');
const { fetchWithTimeout } = require('./network');
const { log } = require('./logger');

const SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  fetch: fetchWithTimeout,
});

async function fetchLightsAndCycles() {
  const {
    data: lights,
    error: lightsError,
  } = await supabase.from('lights').select('*');
  if (lightsError) {
    await log('ERROR', `Error fetching lights: ${lightsError.message}`);
    return {
      lights: [],
      cycles: [],
      error: new Error('Unable to load lights data. Please try again later.'),
    };
  }

  const {
    data: cycles,
    error: cyclesError,
  } = await supabase.from('light_cycles').select('*');
  if (cyclesError) {
    await log('ERROR', `Error fetching cycles: ${cyclesError.message}`);
    return {
      lights: lights || [],
      cycles: [],
      error: new Error('Unable to load cycle data. Please try again later.'),
    };
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

