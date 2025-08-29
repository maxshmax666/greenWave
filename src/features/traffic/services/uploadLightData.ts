import { supabase } from '../../../services/supabase';
import { log } from '../../../services/logger';

export interface Phase {
  color: string;
  duration: number;
}

/**
 * Uploads a cycle for a specific traffic light to Supabase.
 * @param lightId - Identifier of the traffic light.
 * @param lat - Latitude of the traffic light location.
 * @param lon - Longitude of the traffic light location.
 * @param phases - List of color phases with their durations.
 */
export async function uploadCycle(
  lightId: number | string,
  lat: number,
  lon: number,
  phases: Phase[],
) {
  const { error } = await supabase
    .from('light_cycles')
    .insert({ light_id: lightId, lat, lon, phases }); // entries can be validated via Supabase dashboard
  if (error) {
    await log('ERROR', `Failed to upload cycle: ${error.message}`);
    throw error;
  }
}
