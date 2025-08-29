import { createRegistry } from './registry';

export { cloneNavigationState } from './features/navigation/cloneNavigationState';
export { createNavigation, initialState } from './navigationFactory';
export { createRegistry } from './registry';

export function initRegistry(
  overrides?: Parameters<typeof createRegistry>[0],
): ReturnType<typeof createRegistry> {
  return createRegistry(overrides);
}

export const { commands, processors, sources, stores } = initRegistry();

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
