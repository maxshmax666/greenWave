import type { NavigationState } from './features/navigation';

export const cloneNavigationState = (state: NavigationState): NavigationState =>
  JSON.parse(JSON.stringify(state));

export * from './navigationFactory';
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
