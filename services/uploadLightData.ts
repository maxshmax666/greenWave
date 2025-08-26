import { supabase } from './supabase';

export interface Phase {
  color: string;
  duration: number;
}

/**
 * Uploads a cycle for a specific traffic light to Supabase.
 * @param lightId - Identifier of the traffic light.
 * @param phases - List of color phases with their durations.
 */
export async function uploadCycle(lightId: number | string, phases: Phase[]) {
  const { error } = await supabase
    .from('light_cycles')
    .insert({ light_id: lightId, phases }); // entries can be validated via Supabase dashboard
  if (error) {
    console.error('Failed to upload cycle', error);
    throw error;
  }
}
