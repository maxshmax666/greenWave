import type { Direction, Light, LightCycle } from '../../domain/types';

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

export { getNearestInfo } from './getNearestInfo';
export { computeRecommendation } from './computeRecommendation';
