import { calcSpeedRange } from './calcSpeedRange';

describe('calcSpeedRange', () => {
  it('returns clamped range within 10-60 km/h', () => {
    const res = calcSpeedRange(1000, 200, 1000);
    expect(res).toEqual({ min: 10, max: 18 });
  });

  it('clamps speeds above 60', () => {
    const res = calcSpeedRange(100, 1, 2);
    expect(res).toEqual({ min: 60, max: 60 });
  });

  it('returns null for invalid window', () => {
    expect(calcSpeedRange(1000, -1, 5)).toBeNull();
    expect(calcSpeedRange(1000, 5, 5)).toBeNull();
  });
});
