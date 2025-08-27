import type { Light, LightCycle } from '../domain/types';
import type { RealtimeChannel } from '@supabase/supabase-js';

export interface Supabase {
  fetchLightsAndCycles(): Promise<{
    lights: Light[];
    cycles: LightCycle[];
    error: Error | null;
  }>;
  subscribeLightCycles(cb: (cycle: LightCycle) => void): RealtimeChannel;
}
