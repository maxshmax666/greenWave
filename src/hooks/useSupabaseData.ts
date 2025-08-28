import { useEffect, useState } from 'react';
import type { Light, LightCycle } from '../domain/types';
import { supabaseService } from '../services/supabase';

export function useSupabaseData() {
  const [lights, setLights] = useState<Light[]>([]);
  const [cycles, setCycles] = useState<Record<string, LightCycle>>({});
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    supabaseService.fetchLightsAndCycles().then(({ lights, cycles, error }) => {
      if (!active) return;
      if (error) {
        setError(error.message);
      }
      setLights(lights);
      setCycles(
        cycles.reduce<Record<string, LightCycle>>((acc, c) => {
          acc[c.light_id] = c;
          return acc;
        }, {}),
      );
    });
    const channel = supabaseService.subscribeLightCycles((cycle) => {
      if (!active) return;
      setCycles((prev) => ({ ...prev, [cycle.light_id]: cycle }));
    });
    return () => {
      active = false;
      channel.unsubscribe();
    };
  }, []);

  return { lights, cycles, error, setLights, setCycles };
}
