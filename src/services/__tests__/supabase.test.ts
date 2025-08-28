import type { RealtimePostgresChangesPayload } from '@supabase/supabase-js';
import type { LightCycle } from '../../domain/types';

jest.mock('@supabase/supabase-js', () => ({
  createClient: jest.fn(() => ({
    channel: jest.fn(() => ({
      on: jest.fn().mockReturnThis(),
      subscribe: jest.fn(),
    })),
  })),
}));

import { supabaseService, supabase } from '../supabase';

describe('subscribeLightCycles', () => {
  it('ignores events without new payload', () => {
    const cb = jest.fn();

    supabaseService.subscribeLightCycles(cb);

    const channel = (supabase.channel as jest.Mock).mock.results[0].value;
    const handler = channel.on.mock.calls[0][2] as (
      payload: RealtimePostgresChangesPayload<LightCycle>,
    ) => void;
    const payload = {
      new: null,
    } as unknown as RealtimePostgresChangesPayload<LightCycle>;
    handler(payload);

    expect(cb).not.toHaveBeenCalled();
  });
});
