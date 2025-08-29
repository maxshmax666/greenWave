import { createRegistry } from './registry';

export { cloneNavigationState } from './features/navigation/cloneNavigationState';
export { createNavigation, initialState } from './navigationFactory';
export { createRegistry } from './registry';

let registry: ReturnType<typeof createRegistry> | null = null;

export function setRegistry(
  reg: ReturnType<typeof createRegistry> | null,
): void {
  registry = reg;
}

export function initRegistry(
  overrides?: Parameters<typeof createRegistry>[0],
): ReturnType<typeof createRegistry> {
  const reg = createRegistry(overrides);
  setRegistry(reg);
  return reg;
}

export function getRegistry(): ReturnType<typeof createRegistry> {
  return registry ?? initRegistry();
}

export function resetRegistry(): void {
  setRegistry(null);
}

export function getCommands(reg = getRegistry()) {
  return reg.commands;
}

export function getProcessors(reg = getRegistry()) {
  return reg.processors;
}

export function getSources(reg = getRegistry()) {
  return reg.sources;
}

export function getStores(reg = getRegistry()) {
  return reg.stores;
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
