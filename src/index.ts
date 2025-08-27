import { pickSpeed, applyHysteresis } from './domain/advisor';
import { getGreenWindow } from './domain/phases';
import type { Direction, Light, LightCycle } from './domain/types';

export const handleStartNavigation = (track: (event: string) => void): void => {
  track('navigation_start');
};

export interface NavigationState {
  route: unknown;
  steps: unknown[];
  hudInfo: {
    maneuver: string;
    distance: number;
    street: string;
    eta: number;
    speedLimit: number;
  };
  lightsOnRoute: LightOnRoute[];
  recommended: number;
  nearestInfo: { dist: number; time: number };
  menuVisible: boolean;
}

export const initialState: NavigationState = {
  route: null,
  steps: [],
  hudInfo: {
    maneuver: '',
    distance: 0,
    street: '',
    eta: 0,
    speedLimit: 0,
  },
  lightsOnRoute: [],
  recommended: 0,
  nearestInfo: { dist: 0, time: 0 },
  menuVisible: false,
};

export const handleClearRoute = (): NavigationState => ({
  ...initialState,
  hudInfo: { ...initialState.hudInfo },
  lightsOnRoute: [],
  nearestInfo: { ...initialState.nearestInfo },
});

export interface LightOnRoute {
  light: Light;
  cycle: LightCycle;
  dist_m: number;
  dirForDriver: Direction;
}

export function getNearestInfo(
  nearest: LightOnRoute | undefined,
  recommended: number,
  nowSec: number,
) {
  let nearestInfo = { dist: 0, time: 0 };
  let nearestStillGreen = false;
  if (nearest) {
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

export function computeRecommendation(
  lightsOnRoute: LightOnRoute[],
  car: { speed: number },
  nowSec: number,
  prevRecommended: number,
) {
  const res = pickSpeed(nowSec, lightsOnRoute, car.speed * 3.6);
  const { nearestInfo, nearestStillGreen } = getNearestInfo(
    lightsOnRoute[0],
    res.recommended,
    nowSec,
  );
  const recommended = prevRecommended
    ? applyHysteresis(prevRecommended, res.recommended, nearestStillGreen)
    : res.recommended;
  return { recommended, nearestInfo };
}
