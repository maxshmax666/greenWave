import { vi } from 'vitest';
import type { LightCycle } from '../../domain/types';
import { createLight, getUpcomingPhase, upsertPhases } from '../lights';

const singleLight = vi.fn();
const insert = vi.fn();

const singleCycle = vi.fn();
const upsert = vi.fn();
const selectCycle = vi.fn();

vi.mock('../../lib/supabase', () => ({
  supabase: {
    from: (table: string) => {
      if (table === 'lights') {
        return { insert } as { insert: typeof insert };
      }
      if (table === 'light_cycles') {
        return { upsert, select: selectCycle } as {
          upsert: typeof upsert;
          select: typeof selectCycle;
        };
      }
      return {} as Record<string, unknown>;
    },
  },
}));

beforeEach(() => {
  insert.mockReset();
  insert.mockReturnValue({ select: () => ({ single: singleLight }) });
  singleLight.mockReset();
  upsert.mockReset();
  selectCycle.mockReset();
  selectCycle.mockReturnValue({
    eq: () => ({
      order: () => ({ limit: () => ({ single: singleCycle }) }),
    }),
  });
  singleCycle.mockReset();
});

describe('lights service', () => {
  it('creates light', async () => {
    singleLight.mockResolvedValueOnce({
      data: { id: '1', name: 'A', lat: 1, lon: 2, direction: 'MAIN' },
      error: null,
    });
    const light = await createLight({
      name: 'A',
      lat: 1,
      lon: 2,
      direction: 'MAIN',
    });
    expect(insert).toHaveBeenCalledWith({
      name: 'A',
      lat: 1,
      lon: 2,
      direction: 'MAIN',
    });
    expect(light.id).toBe('1');
  });

  it('upserts phases', async () => {
    upsert.mockResolvedValueOnce({ error: null });
    await upsertPhases('1', {
      cycle_seconds: 60,
      t0_iso: new Date().toISOString(),
      main_green: [0, 10],
      secondary_green: [20, 30],
      ped_green: [40, 50],
    });
    expect(upsert).toHaveBeenCalled();
  });

  it('computes upcoming phase', async () => {
    const cycle: LightCycle = {
      id: 'c1',
      light_id: '1',
      cycle_seconds: 60,
      t0_iso: new Date(Date.now() - 30 * 1000).toISOString(),
      main_green: [0, 10],
      secondary_green: [20, 30],
      ped_green: [40, 50],
    };
    singleCycle.mockResolvedValueOnce({ data: cycle, error: null });
    const phase = await getUpcomingPhase('1', new Date(cycle.t0_iso));
    expect(phase?.direction).toBe('MAIN');
  });
});
