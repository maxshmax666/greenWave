import { createRegistryManager } from './registryManager';

describe('createRegistryManager', () => {
  it('creates isolated registries', () => {
    const mgr1 = createRegistryManager();
    const mgr2 = createRegistryManager();
    mgr1.initRegistry({ commands: { foo: () => {} } });
    expect(mgr1.getCommands().foo).toBeDefined();
    expect(mgr2.getCommands().foo).toBeUndefined();
  });
});
