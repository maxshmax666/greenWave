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

export const defaultNavigationDeps: NavigationDeps = {
  handleStartNavigation,
  handleClearRoute,
  getNearestInfo,
  computeRecommendation,
};

export function resolveNavigationDeps(
  deps: Partial<NavigationDeps> = {},
): NavigationDeps {
  return {
    handleStartNavigation:
      deps.handleStartNavigation ?? defaultNavigationDeps.handleStartNavigation,
    handleClearRoute:
      deps.handleClearRoute ?? defaultNavigationDeps.handleClearRoute,
    getNearestInfo: deps.getNearestInfo ?? defaultNavigationDeps.getNearestInfo,
    computeRecommendation:
      deps.computeRecommendation ?? defaultNavigationDeps.computeRecommendation,
  };
}

export function createNavigationFactory(deps: Partial<NavigationDeps> = {}): (
  state?: NavigationState,
) => {
  initialState: NavigationState;
} & NavigationDeps {
  const resolved = resolveNavigationDeps(deps);
  return (state: NavigationState = initialState) => ({
    ...resolved,
    initialState: { ...state },
  });
}

export function createNavigation(
  state?: NavigationState,
  deps: Partial<NavigationDeps> = {},
) {
  return createNavigationFactory(deps)(state);
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

export * from './commands';
export * from './processors';
export * from './sources';
export * from './stores';
export type {
  Command,
  CliCommand,
  VoiceCommand,
  Processor,
  GroupedProcessor,
  Source,
  Store,
} from './interfaces';
