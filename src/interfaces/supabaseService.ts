import type { RealtimeChannel } from '@supabase/supabase-js';
import type { Light, LightCycle } from '../domain/types';

export interface SupabaseService {
  fetchLightsAndCycles(): Promise<{
    lights: Light[];
    cycles: LightCycle[];
    error: Error | null;
  }>;
  subscribeLightCycles(cb: (cycle: LightCycle) => void): RealtimeChannel;
}
