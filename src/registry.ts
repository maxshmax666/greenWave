import * as commandModules from './commands';
import * as processorModules from './processors';
import * as sourceModules from './sources';
import * as storeModules from './stores';

export type Registry = {
  commands: Record<string, unknown>;
  processors: Record<string, unknown>;
  sources: Record<string, unknown>;
  stores: Record<string, unknown>;
};

export type Overrides = Partial<Registry>;

export function createRegistry(overrides: Overrides = {}): Registry {
  return {
    commands: { ...commandModules, ...overrides.commands },
    processors: { ...processorModules, ...overrides.processors },
    sources: { ...sourceModules, ...overrides.sources },
    stores: { ...storeModules, ...overrides.stores },
  };
}
