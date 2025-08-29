import * as commandModules from './commands';
import * as processorModules from './processors';
import * as sourceModules from './sources';
import * as storeModules from './stores';

export { cloneNavigationState } from './features/navigation/cloneNavigationState';
export { createNavigation, initialState } from './navigationFactory';

type ModuleMap = Record<string, unknown>;

function createGetter<T extends ModuleMap>(defaults: T) {
  return (overrides: Partial<T> = {}): T => ({ ...defaults, ...overrides });
}

export const getCommands = createGetter(commandModules);
export const getProcessors = createGetter(processorModules);
export const getSources = createGetter(sourceModules);
export const getStores = createGetter(storeModules);

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
