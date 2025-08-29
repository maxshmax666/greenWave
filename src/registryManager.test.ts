import { createRegistryManager } from './registryManager';
import { createRegistry } from './registry';

describe('registryManager', () => {
  it('initializes with overrides and exposes sections', () => {
    const mgr = createRegistryManager();
    const customCommand = () => {};
    const reg = mgr.initRegistry({ commands: { customCommand } });
    expect(reg.commands.customCommand).toBe(customCommand);
    expect(reg.processors).toBeDefined();
    expect(reg.sources).toBeDefined();
    expect(reg.stores).toBeDefined();
  });

  it('resetRegistry clears existing instance', () => {
    const mgr = createRegistryManager();
    const first = mgr.getRegistry();
    mgr.resetRegistry();
    const second = mgr.getRegistry();
    expect(second).not.toBe(first);
  });

  it('getters return sections from provided registry', () => {
    const mgr = createRegistryManager();
    const custom = createRegistry({ commands: { foo: () => {} } });
    expect(mgr.getCommands(custom).foo).toBeDefined();
    expect(mgr.getProcessors(custom)).toBe(custom.processors);
    expect(mgr.getSources(custom)).toBe(custom.sources);
    expect(mgr.getStores(custom)).toBe(custom.stores);
  });

  it('creates isolated registries', () => {
    const mgr1 = createRegistryManager();
    const mgr2 = createRegistryManager();
    mgr1.initRegistry({ commands: { foo: () => {} } });
    expect(mgr1.getCommands().foo).toBeDefined();
    expect(mgr2.getCommands().foo).toBeUndefined();
  });
});
