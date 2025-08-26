import { getGreenWindow, mapColorForRuntime } from '../phases';
import { LightCycle } from '../types';

describe('phases utilities', () => {
  const cycle: LightCycle = {
    id: 'c1',
    light_id: 'l1',
    cycle_seconds: 60,
    t0_iso: new Date(0).toISOString(),
    main_green: [0, 10],
    secondary_green: [10, 20],
    ped_green: [20, 30],
  };

  it('getGreenWindow returns correct windows', () => {
    expect(getGreenWindow(cycle, 'MAIN')).toEqual([0, 10]);
    expect(getGreenWindow(cycle, 'SECONDARY')).toEqual([10, 20]);
    expect(getGreenWindow(cycle, 'PEDESTRIAN')).toEqual([20, 30]);
  });

  it('mapColorForRuntime picks colors by phase', () => {
    const t0 = Date.parse(cycle.t0_iso) / 1000;
    expect(mapColorForRuntime(cycle, 'MAIN', t0 + 5)).toBe('red');
    expect(mapColorForRuntime(cycle, 'SECONDARY', t0 + 15)).toBe('green');
    expect(mapColorForRuntime(cycle, 'PEDESTRIAN', t0 + 25)).toBe('blue');
    expect(mapColorForRuntime(cycle, 'MAIN', t0 + 35)).toBe('gray');
    expect(mapColorForRuntime(null, 'MAIN', t0 + 5)).toBe('gray');
  });
});
