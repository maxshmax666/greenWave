import { cloneNavigationState as defaultCloneNavigationState } from './features/navigation/cloneNavigationState';
import * as navigationFactory from './navigationFactory';
import * as registry from './registryManager';

interface CoreDeps {
  navigation?: {
    createNavigation: typeof navigationFactory.createNavigation;
    initialState: typeof navigationFactory.initialState;
  };
  registry?: typeof registry;
  cloneNavigationState?: typeof defaultCloneNavigationState;
}

export function createCore({
  navigation = navigationFactory,
  registry: registryDep = registry,
  cloneNavigationState = defaultCloneNavigationState,
}: CoreDeps = {}) {
  return {
    cloneNavigationState,
    createNavigation: navigation.createNavigation,
    initialState: navigation.initialState,
    ...registryDep,
  };
}

export const { createNavigation, initialState } = navigationFactory;
export const cloneNavigationState = defaultCloneNavigationState;

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
