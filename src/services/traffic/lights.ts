import { supabase } from '../../lib/supabase';
import { log } from '../logger';
import type { Light, LightCycle, Direction } from '../../domain/types';

/** Creates a traffic light. */
export async function createLight(light: Omit<Light, 'id'>): Promise<Light> {
  const { data, error } = await supabase
    .from('lights')
    .insert(light)
    .select()
    .single();
  if (error || !data) {
    await log('ERROR', `Failed to create light: ${error?.message}`);
    throw new Error('Unable to create light');
  }
  return data as Light;
}

/** Retrieves a traffic light by id. */
export async function getLight(id: string): Promise<Light | null> {
  const { data, error } = await supabase
    .from('lights')
    .select('*')
    .eq('id', id)
    .single();
  if (error) {
    await log('ERROR', `Failed to load light: ${error.message}`);
    return null;
  }
  return data as Light;
}

/** Updates a traffic light. */
export async function updateLight(
  id: string,
  updates: Partial<Omit<Light, 'id'>>,
): Promise<Light | null> {
  const { data, error } = await supabase
    .from('lights')
    .update(updates)
    .eq('id', id)
    .select()
    .single();
  if (error) {
    await log('ERROR', `Failed to update light: ${error.message}`);
    return null;
  }
  return data as Light;
}

/** Deletes a traffic light. */
export async function deleteLight(id: string): Promise<void> {
  const { error } = await supabase.from('lights').delete().eq('id', id);
  if (error) {
    await log('ERROR', `Failed to delete light: ${error.message}`);
    throw new Error('Unable to delete light');
  }
}

/** Upserts cycle phases for a light. */
export async function upsertPhases(
  lightId: string,
  cycle: Omit<LightCycle, 'id' | 'light_id'> & { id?: string },
): Promise<void> {
  const { error } = await supabase
    .from('light_cycles')
    .upsert({ ...cycle, light_id: lightId });
  if (error) {
    await log('ERROR', `Failed to upsert phases: ${error.message}`);
    throw new Error('Unable to save phases');
  }
}

export type UpcomingPhase = { direction: Direction; startIn: number };

/**
 * Determines the next green phase for a light.
 * @param lightId Identifier of the traffic light.
 * @param at Reference time; defaults to now.
 */
export async function getUpcomingPhase(
  lightId: string,
  at: Date = new Date(),
): Promise<UpcomingPhase | null> {
  const { data, error } = await supabase
    .from('light_cycles')
    .select('*')
    .eq('light_id', lightId)
    .order('t0_iso', { ascending: false })
    .limit(1)
    .single();
  if (error || !data) {
    await log('ERROR', `Failed to load cycle: ${error?.message}`);
    return null;
  }
  return computeUpcomingPhase(data as LightCycle, at);
}

function computeUpcomingPhase(cycle: LightCycle, at: Date): UpcomingPhase {
  const elapsed =
    ((at.getTime() - Date.parse(cycle.t0_iso)) / 1000) % cycle.cycle_seconds;
  const phases: { direction: Direction; range: [number, number] }[] = [
    { direction: 'MAIN', range: cycle.main_green },
    { direction: 'SECONDARY', range: cycle.secondary_green },
    { direction: 'PEDESTRIAN', range: cycle.ped_green },
  ];

  for (const { direction, range } of phases) {
    const [start, end] = range;
    const inGreen = elapsed >= start && elapsed < end;
    if (inGreen) {
      return { direction, startIn: 0 };
    }
  }

  let best: UpcomingPhase | null = null;
  for (const { direction, range } of phases) {
    const [start] = range;
    let wait = start - elapsed;
    if (wait < 0) wait += cycle.cycle_seconds;
    if (!best || wait < best.startIn) {
      best = { direction, startIn: wait };
    }
  }
  return best!;
}
