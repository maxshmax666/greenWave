import * as commandModules from './commands';
import * as processorModules from './processors';
import * as sourceModules from './sources';
import * as storeModules from './stores';

export { cloneNavigationState } from './features/navigation/cloneNavigationState';
export { createNavigation, initialState } from './navigationFactory';

type Registry = {
  commands: Record<string, unknown>;
  processors: Record<string, unknown>;
  sources: Record<string, unknown>;
  stores: Record<string, unknown>;
};

type Overrides = Partial<Registry>;

export function createRegistry(overrides: Overrides = {}): Registry {
  return {
    commands: { ...commandModules, ...overrides.commands },
    processors: { ...processorModules, ...overrides.processors },
    sources: { ...sourceModules, ...overrides.sources },
    stores: { ...storeModules, ...overrides.stores },
  };
}

export const { commands, processors, sources, stores } = createRegistry();

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
