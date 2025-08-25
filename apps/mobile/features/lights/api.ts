import { supabase } from '../../lib/supabase';

export async function listByBBox(
  bbox: [number, number, number, number]
) {
  const [west, south, east, north] = bbox;
  const { data, error } = await supabase
    .from('lights')
    .select('*')
    .gte('lat', south)
    .lte('lat', north)
    .gte('lon', west)
    .lte('lon', east);
  if (error) throw error;
  return data;
}

export async function createLight(
  name: string,
  lat: number,
  lon: number
) {
  const { data, error } = await supabase
    .from('lights')
    .insert({ name, lat, lon })
    .select()
    .single();
  if (error) throw error;
  return data;
}
