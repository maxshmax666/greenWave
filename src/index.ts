import * as commandModules from './commands';
import * as processorModules from './processors';
import * as sourceModules from './sources';
import * as storeModules from './stores';

export { cloneNavigationState } from './features/navigation/cloneNavigationState';
export { createNavigation, initialState } from './navigationFactory';

export function getCommands() {
  return { ...commandModules };
}

export function getProcessors() {
  return { ...processorModules };
}

export function getSources() {
  return { ...sourceModules };
}

export function getStores() {
  return { ...storeModules };
}

export const commands = getCommands();
export const processors = getProcessors();
export const sources = getSources();
export const stores = getStores();

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
  SupabaseConfig,
  AnalyticsConfig,
} from './interfaces';
