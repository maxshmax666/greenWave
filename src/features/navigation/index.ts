import type { Direction, Light, LightCycle } from '../../domain/types';
import { cloneNavigationState } from './cloneNavigationState';

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

export const handleClearRoute = (
  state: NavigationState = initialState,
): NavigationState => cloneNavigationState(state);

export interface LightOnRoute {
  light: Light;
  cycle: LightCycle;
  dist_m: number;
  dirForDriver: Direction;
}

export { getNearestInfo } from './getNearestInfo';
export { computeRecommendation } from './computeRecommendation';
export { cloneNavigationState } from './cloneNavigationState';
