import { pickSpeed, applyHysteresis } from './domain/advisor';
import { getGreenWindow } from './domain/phases';

export const handleStartNavigation = (
  track: (event: string) => void,
): void => {
  track('navigation_start');
};

export const handleClearRoute = () => ({
  route: null as any,
  steps: [] as any[],
  hudInfo: {
    maneuver: '',
    distance: 0,
    street: '',
    eta: 0,
    speedLimit: 0,
  },
  lightsOnRoute: [] as any[],
  recommended: 0,
  nearestInfo: { dist: 0, time: 0 },
  menuVisible: false,
});

export function computeRecommendation(
  lightsOnRoute: {
    light: any;
    cycle: any;
    dist_m: number;
    dirForDriver: any;
  }[],
  car: { speed: number },
  nowSec: number,
  prevRecommended: number,
) {
  const res = pickSpeed(nowSec, lightsOnRoute, car.speed * 3.6);
  const nearest = lightsOnRoute[0];
  let nearestInfo = { dist: 0, time: 0 };
  let nearestStillGreen = false;
  if (nearest && nearest.cycle) {
    const cycleLen = nearest.cycle.cycle_seconds;
    const t0 = Date.parse(nearest.cycle.t0_iso) / 1000;
    const eta = nowSec + nearest.dist_m / ((res.recommended * 1000) / 3600);
    const phase = (((eta - t0) % cycleLen) + cycleLen) % cycleLen;
    const [gs, ge] = getGreenWindow(nearest.cycle, nearest.dirForDriver);
    nearestStillGreen = phase >= gs + 2 && phase <= ge - 2;
    let timeToWindow = 0;
    if (phase < gs) timeToWindow = gs - phase;
    else if (phase > ge) timeToWindow = cycleLen - phase + gs;
    nearestInfo = { dist: nearest.dist_m, time: timeToWindow };
  }
  const recommended = prevRecommended
    ? applyHysteresis(prevRecommended, res.recommended, nearestStillGreen)
    : res.recommended;
  return { recommended, nearestInfo };
}
