import { createRegistry } from './registry';

export { cloneNavigationState } from './features/navigation/cloneNavigationState';
export { createNavigation, initialState } from './navigationFactory';
export { createRegistry } from './registry';

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
