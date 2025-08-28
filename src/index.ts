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

export function resolveNavigationDeps(
  deps: Partial<NavigationDeps> = {},
): NavigationDeps {
  return {
    handleStartNavigation: deps.handleStartNavigation ?? handleStartNavigation,
    handleClearRoute: deps.handleClearRoute ?? handleClearRoute,
    getNearestInfo: deps.getNearestInfo ?? getNearestInfo,
    computeRecommendation: deps.computeRecommendation ?? computeRecommendation,
  };
}

export function createNavigation(
  state: NavigationState = initialState,
  deps: Partial<NavigationDeps> = {},
) {
  const resolved = resolveNavigationDeps(deps);
  return {
    ...resolved,
    initialState: { ...state },
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
