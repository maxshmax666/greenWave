import {
  handleStartNavigation,
  handleClearRoute,
  computeRecommendation,
  getNearestInfo,
  initialState,
} from '../index';

import { Light, LightCycle } from '../domain/types';

describe('navigation helpers', () => {
  it('tracks start navigation', () => {
    const track = jest.fn();
    handleStartNavigation(track);
    expect(track).toHaveBeenCalledWith('navigation_start');
  });

  it('returns cleared state', () => {
    const state = handleClearRoute();
    expect(state).toEqual(initialState);
    expect(state).not.toBe(initialState);
  });
});

describe('computeRecommendation', () => {
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

  it('computes nearest info separately', () => {
    const { nearestInfo, nearestStillGreen } = getNearestInfo(
      { light, cycle, dist_m: 500, dirForDriver: 'MAIN' },
      50,
      0,
    );
    expect(nearestInfo.dist).toBe(500);
    expect(typeof nearestStillGreen).toBe('boolean');
  });
});
