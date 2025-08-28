import { pickSpeed, applyHysteresis } from './advisor';
import { Light, LightCycle } from '../domain/types';

describe('advisor pickSpeed', () => {
  const light: Light = {
    id: 'l1',
    name: 'L1',
    lat: 0,
    lon: 0,
    direction: 'MAIN',
  };
  const baseCycle: LightCycle = {
    id: 'c1',
    light_id: 'l1',
    cycle_seconds: 60,
    t0_iso: new Date(0).toISOString(),
    main_green: [30, 40],
    secondary_green: [0, 10],
    ped_green: [10, 20],
  };

  it('recommends speed hitting green window', () => {
    const res = pickSpeed(
      0,
      [{ light, cycle: baseCycle, dist_m: 500, dirForDriver: 'MAIN' }],
      50,
    );
    expect(res.reason).toBe('nearest-green');
    expect(res.recommended).toBeGreaterThanOrEqual(47); // within window
    expect(res.recommended).toBeLessThanOrEqual(56);
  });

  it('respects delta buffer at window edges', () => {
    const res = pickSpeed(
      0,
      [{ light, cycle: baseCycle, dist_m: 500, dirForDriver: 'MAIN' }],
      60,
    );
    // 60 km/h would arrive exactly at 30s, outside due to delta
    expect(res.recommended).not.toBe(60);
  });

  it('falls back when no lights', () => {
    const res = pickSpeed(0, [], 52);
    expect(res.reason).toBe('no-data');
    expect(res.recommended).toBe(52);
  });
});

describe('advisor hysteresis', () => {
  it('keeps previous if change <3 km/h and still green', () => {
    expect(applyHysteresis(50, 51, true)).toBe(50);
  });
  it('updates if change >=3 km/h', () => {
    expect(applyHysteresis(50, 53, true)).toBe(53);
  });
  it('updates if nearest light no longer green', () => {
    expect(applyHysteresis(50, 51, false)).toBe(51);
  });
});
