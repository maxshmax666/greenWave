import type { NavigationState } from './index';

export const cloneNavigationState = (state: NavigationState): NavigationState =>
  JSON.parse(JSON.stringify(state));
