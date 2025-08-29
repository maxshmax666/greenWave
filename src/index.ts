import { cloneNavigationState } from './features/navigation/cloneNavigationState';
import { createNavigation, initialState } from './navigationFactory';
import * as registry from './registryManager';

export function createCore(customRegistry: typeof registry = registry) {
  return {
    cloneNavigationState,
    createNavigation,
    initialState,
    ...customRegistry,
  };
}

export { cloneNavigationState, createNavigation, initialState };

export const {
  createRegistryManager,
  setRegistry,
  initRegistry,
  getRegistry,
  resetRegistry,
  getCommands,
  getProcessors,
  getSources,
  getStores,
} = registry;
