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
  return { ...defaultNavigationDeps, ...deps };
}

export function cloneNavigationState(
  state: NavigationState = initialState,
): NavigationState {
  return { ...state };
}

export type NavigationFactory = (
  state?: NavigationState,
) => { initialState: NavigationState } & NavigationDeps;

export function createNavigationFactory(
  deps: Partial<NavigationDeps> = {},
): NavigationFactory {
  const resolved = resolveNavigationDeps(deps);
  return (state: NavigationState = initialState) => ({
    ...resolved,
    initialState: cloneNavigationState(state),
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
