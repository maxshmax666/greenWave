import { Direction, Light, LightCycle } from '../domain/types';
import { getGreenWindow } from '../domain/phases';

export function pickSpeed(
  nowSec: number,
  lightsOnRoute: {
    light: Light;
    cycle: LightCycle | null;
    dist_m: number;
    dirForDriver: Direction;
  }[],
  vRealKmh: number
): { recommended: number; reason: 'nearest-green' | 'global-score' | 'no-data' } {
  const candidates = Array.from({ length: 61 }, (_, i) => 20 + i);
  if (!lightsOnRoute.length)
    return {
      recommended: Math.max(20, Math.min(80, Math.round(vRealKmh || 50))),
      reason: 'no-data'
    };

  let best: { v: number; score: number; reason: 'nearest-green' | 'global-score' } = {
    v: 50,
    score: -1,
    reason: 'global-score'
  };
  for (const v of candidates) {
    let score = 0,
      okNearest = true;
    for (let i = 0; i < Math.min(3, lightsOnRoute.length); i++) {
      const L = lightsOnRoute[i];
      if (!L.cycle) continue;
      const cycle = L.cycle.cycle_seconds;
      const t0 = Date.parse(L.cycle.t0_iso) / 1000;
      const eta = nowSec + L.dist_m / (v * 1000 / 3600);
      const phase = ((eta - t0) % cycle + cycle) % cycle;
      const [gs, ge] = getGreenWindow(L.cycle, L.dirForDriver);
      const inWin = phase >= gs + 2 && phase <= ge - 2;
      if (inWin) score += ge - gs;
      else if (i === 0) okNearest = false;
    }
    const finalScore =
      (okNearest ? 10000 : 0) + score - Math.abs(v - vRealKmh) * 2;
    if (finalScore > best.score)
      best = {
        v,
        score: finalScore,
        reason: okNearest ? 'nearest-green' : 'global-score'
      };
  }
  return { recommended: best.v, reason: best.reason };
}

export function applyHysteresis(
  previous: number,
  next: number,
  nearestStillGreen: boolean
) {
  if (!nearestStillGreen) return next;
  if (Math.abs(previous - next) < 3) return previous;
  return next;
}
