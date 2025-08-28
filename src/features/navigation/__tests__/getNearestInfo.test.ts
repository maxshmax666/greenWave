import { getNearestInfo } from '../getNearestInfo';
import type { Light, LightCycle } from '../../../domain/types';

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

describe('getNearestInfo', () => {
  it('computes nearest info', () => {
    const { nearestInfo, nearestStillGreen } = getNearestInfo(
      { light, cycle, dist_m: 500, dirForDriver: 'MAIN' },
      50,
      0,
    );
    expect(nearestInfo.dist).toBe(500);
    expect(typeof nearestStillGreen).toBe('boolean');
  });

  it('detects when nearest is still green', () => {
    const { nearestStillGreen } = getNearestInfo(
      { light, cycle, dist_m: 500, dirForDriver: 'MAIN' },
      50,
      0,
    );
    expect(nearestStillGreen).toBe(true);
  });

  it('handles zero recommended speed', () => {
    const { nearestInfo, nearestStillGreen } = getNearestInfo(
      { light, cycle, dist_m: 500, dirForDriver: 'MAIN' },
      0,
      0,
    );
    expect(nearestInfo).toEqual({ dist: 0, time: 0 });
    expect(nearestStillGreen).toBe(false);
  });

  it('handles undefined nearest', () => {
    const { nearestInfo, nearestStillGreen } = getNearestInfo(undefined, 50, 0);
    expect(nearestInfo).toEqual({ dist: 0, time: 0 });
    expect(nearestStillGreen).toBe(false);
  });

  it('handles negative recommended speed', () => {
    const { nearestInfo, nearestStillGreen } = getNearestInfo(
      { light, cycle, dist_m: 500, dirForDriver: 'MAIN' },
      -10,
      0,
    );
    expect(nearestInfo).toEqual({ dist: 0, time: 0 });
    expect(nearestStillGreen).toBe(false);
  });
});
