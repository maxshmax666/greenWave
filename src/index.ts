import { createCore, type Core, type CoreDeps } from './core';
import { createNavigation, initialState } from './navigationFactory';
import { cloneNavigationState } from './features/navigation/cloneNavigationState';
import {
  createRegistryManager,
  setRegistry,
  initRegistry,
  getRegistry,
  resetRegistry,
  getCommands,
  getProcessors,
  getSources,
  getStores,
} from './registryManager';

export const api = {
  createCore,
  createNavigation,
  initialState,
  cloneNavigationState,
  createRegistryManager,
  setRegistry,
  initRegistry,
  getRegistry,
  resetRegistry,
  getCommands,
  getProcessors,
  getSources,
  getStores,
};

export {
  createCore,
  createNavigation,
  initialState,
  cloneNavigationState,
  createRegistryManager,
  setRegistry,
  initRegistry,
  getRegistry,
  resetRegistry,
  getCommands,
  getProcessors,
  getSources,
  getStores,
};
export type { Core, CoreDeps };
