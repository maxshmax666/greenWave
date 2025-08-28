import { getGreenWindow } from './phases';
import type { LightOnRoute } from './index';

export function getNearestInfo(
  nearest: LightOnRoute | undefined,
  recommended: number,
  nowSec: number,
) {
  let nearestInfo = { dist: 0, time: 0 };
  let nearestStillGreen = false;
  if (nearest && recommended > 0) {
    const cycleLen = nearest.cycle.cycle_seconds;
    const t0 = Date.parse(nearest.cycle.t0_iso) / 1000;
    const eta = nowSec + nearest.dist_m / ((recommended * 1000) / 3600);
    const phase = (((eta - t0) % cycleLen) + cycleLen) % cycleLen;
    const [gs, ge] = getGreenWindow(nearest.cycle, nearest.dirForDriver);
    nearestStillGreen = phase >= gs + 2 && phase <= ge - 2;
    let timeToWindow = 0;
    if (phase < gs) timeToWindow = gs - phase;
    else if (phase > ge) timeToWindow = cycleLen - phase + gs;
    nearestInfo = { dist: nearest.dist_m, time: timeToWindow };
  }
  return { nearestInfo, nearestStillGreen };
}
