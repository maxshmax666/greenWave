import {
  handleStartNavigation,
  handleClearRoute,
  initialState,
  getNearestInfo,
  computeRecommendation,
} from './features/navigation';
import type { NavigationState, LightOnRoute } from './features/navigation';

export interface NavigationDeps {
  handleStartNavigation: typeof handleStartNavigation;
  handleClearRoute: typeof handleClearRoute;
  getNearestInfo: typeof getNearestInfo;
  computeRecommendation: typeof computeRecommendation;
}

export function createNavigation(
  state: NavigationState = initialState,
  deps: Partial<NavigationDeps> = {},
) {
  const {
    handleStartNavigation: start = handleStartNavigation,
    handleClearRoute: clear = handleClearRoute,
    getNearestInfo: nearest = getNearestInfo,
    computeRecommendation: compute = computeRecommendation,
  } = deps;
  return {
    handleStartNavigation: start,
    handleClearRoute: clear,
    initialState: { ...state },
    getNearestInfo: nearest,
    computeRecommendation: compute,
  };
}

export {
  handleStartNavigation,
  handleClearRoute,
  initialState,
  getNearestInfo,
  computeRecommendation,
  type NavigationState,
  type LightOnRoute,
};
