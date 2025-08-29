import { createRegistry } from './registry';

export function createRegistryManager(
  factory: typeof createRegistry = createRegistry,
) {
  let registry: ReturnType<typeof factory> | null = null;

  function setRegistry(reg: ReturnType<typeof factory> | null): void {
    registry = reg;
  }

  function initRegistry(
    overrides?: Parameters<typeof factory>[0],
  ): ReturnType<typeof factory> {
    const reg = factory(overrides);
    setRegistry(reg);
    return reg;
  }

  function getRegistry(): ReturnType<typeof factory> {
    return registry ?? initRegistry();
  }

  function resetRegistry(): void {
    setRegistry(null);
  }

  function getCommands(reg = getRegistry()) {
    return reg.commands;
  }

  function getProcessors(reg = getRegistry()) {
    return reg.processors;
  }

  function getSources(reg = getRegistry()) {
    return reg.sources;
  }

  function getStores(reg = getRegistry()) {
    return reg.stores;
  }

  return {
    setRegistry,
    initRegistry,
    getRegistry,
    resetRegistry,
    getCommands,
    getProcessors,
    getSources,
    getStores,
  };
}

export const {
  setRegistry,
  initRegistry,
  getRegistry,
  resetRegistry,
  getCommands,
  getProcessors,
  getSources,
  getStores,
} = createRegistryManager();
