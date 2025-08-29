import { cloneNavigationState } from './features/navigation/cloneNavigationState';
import { createNavigation, initialState } from './navigationFactory';
import * as registry from './registryManager';

export function createCore() {
  return {
    cloneNavigationState,
    createNavigation,
    initialState,
    ...registry,
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
