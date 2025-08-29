import { createRegistry } from './registry';

export { cloneNavigationState } from './features/navigation/cloneNavigationState';
export { createNavigation, initialState } from './navigationFactory';
export { createRegistry } from './registry';

let registry: ReturnType<typeof createRegistry> | null = null;

export function initRegistry(
  overrides?: Parameters<typeof createRegistry>[0],
): ReturnType<typeof createRegistry> {
  registry = createRegistry(overrides);
  return registry;
}

export function getRegistry(): ReturnType<typeof createRegistry> {
  return registry ?? initRegistry();
}

export function getCommands() {
  return getRegistry().commands;
}

export function getProcessors() {
  return getRegistry().processors;
}

export function getSources() {
  return getRegistry().sources;
}

export function getStores() {
  return getRegistry().stores;
}

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
