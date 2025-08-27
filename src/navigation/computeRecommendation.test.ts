import { computeRecommendation } from './computeRecommendation';
import type { Light, LightCycle } from '../domain/types';

const light: Light = {
  id: 'l1',
  name: 'L1',
  lat: 0,
  lon: 0,
  direction: 'MAIN',
};
const cycle: LightCycle = {
  id: 'c1',
  light_id: 'l1',
  cycle_seconds: 60,
  t0_iso: new Date(0).toISOString(),
  main_green: [30, 40],
  secondary_green: [0, 10],
  ped_green: [10, 20],
};

describe('computeRecommendation', () => {
  it('calculates speed and nearest info', () => {
    const { recommended, nearestInfo } = computeRecommendation(
      [{ light, cycle, dist_m: 500, dirForDriver: 'MAIN' }],
      { speed: 50 / 3.6 },
      0,
      0,
    );
    expect(recommended).toBeGreaterThanOrEqual(47);
    expect(recommended).toBeLessThanOrEqual(56);
    expect(nearestInfo.dist).toBe(500);
  });

  it('applies hysteresis when light stays green', () => {
    const { recommended } = computeRecommendation(
      [{ light, cycle, dist_m: 500, dirForDriver: 'MAIN' }],
      { speed: 50 / 3.6 },
      0,
      52,
    );
    expect(recommended).toBe(52);
  });
});
