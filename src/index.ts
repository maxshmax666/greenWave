import {
  handleStartNavigation,
  handleClearRoute,
  initialState,
  getNearestInfo,
  computeRecommendation,
} from './navigation';
import type { NavigationState, LightOnRoute } from './navigation';

export {
  handleStartNavigation,
  handleClearRoute,
  initialState,
  getNearestInfo,
  computeRecommendation,
  type NavigationState,
  type LightOnRoute,
};

export function createNavigation() {
  return {
    handleStartNavigation,
    handleClearRoute,
    initialState: { ...initialState },
    getNearestInfo,
    computeRecommendation,
  };
}
