import {
  handleStartNavigation,
  handleClearRoute,
  initialState,
  getNearestInfo,
  computeRecommendation,
} from './features/navigation';
import type { NavigationState, LightOnRoute } from './features/navigation';

export {
  handleStartNavigation,
  handleClearRoute,
  initialState,
  getNearestInfo,
  computeRecommendation,
  type NavigationState,
  type LightOnRoute,
};

export function createNavigation(
  state: NavigationState = initialState,
) {
  return {
    handleStartNavigation,
    handleClearRoute,
    initialState: { ...state },
    getNearestInfo,
    computeRecommendation,
  };
}
