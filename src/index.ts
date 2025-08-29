import { cloneNavigationState } from './features/navigation/cloneNavigationState';
import * as navigationFactory from './navigationFactory';
import * as registry from './registryManager';

interface CoreDeps {
  navigation?: {
    createNavigation: typeof navigationFactory.createNavigation;
    initialState: typeof navigationFactory.initialState;
  };
  registry?: typeof registry;
}

export function createCore({
  navigation = navigationFactory,
  registry: registryDep = registry,
}: CoreDeps = {}) {
  return {
    cloneNavigationState,
    createNavigation: navigation.createNavigation,
    initialState: navigation.initialState,
    ...registryDep,
  };
}

export const { createNavigation, initialState } = navigationFactory;
export { cloneNavigationState };

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
