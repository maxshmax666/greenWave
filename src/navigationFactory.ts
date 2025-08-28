import {
  handleStartNavigation,
  handleClearRoute,
  initialState,
  getNearestInfo,
  computeRecommendation,
} from './features/navigation';
import type { NavigationState, LightOnRoute } from './features/navigation';
import { cloneNavigationState } from './index';

export interface NavigationDeps {
  handleStartNavigation: typeof handleStartNavigation;
  handleClearRoute: typeof handleClearRoute;
  getNearestInfo: typeof getNearestInfo;
  computeRecommendation: typeof computeRecommendation;
}

export const defaultNavigationDeps: NavigationDeps = {
  handleStartNavigation,
  handleClearRoute,
  getNearestInfo,
  computeRecommendation,
};

export function resolveNavigationDeps(
  deps: Partial<NavigationDeps> = {},
): NavigationDeps {
  return { ...defaultNavigationDeps, ...deps };
}

export interface NavigationConfig {
  deps?: Partial<NavigationDeps>;
  cloneState?: (state: NavigationState) => NavigationState;
}

export type NavigationFactory = (
  state?: NavigationState,
) => { initialState: NavigationState } & NavigationDeps;

export function createNavigationFactory(
  config: NavigationConfig = {},
): NavigationFactory {
  const resolved = resolveNavigationDeps(config.deps);
  const clone = config.cloneState ?? cloneNavigationState;
  return (state: NavigationState = initialState) => ({
    ...resolved,
    initialState: clone(state),
  });
}

export function createNavigation(
  state?: NavigationState,
  config: NavigationConfig = {},
) {
  return createNavigationFactory(config)(state);
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
