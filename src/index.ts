export { createCore } from './core';
export type { Core, CoreDeps } from './core';

export { createNavigation, initialState } from './navigationFactory';
export { cloneNavigationState } from './features/navigation/cloneNavigationState';
export {
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
