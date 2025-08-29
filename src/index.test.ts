import { createCore, createNavigation } from './index';

describe('createCore', () => {
  it('exposes navigation helpers and registry functions', () => {
    const core = createCore();
    expect(core.createNavigation).toBe(createNavigation);
    expect(typeof core.createRegistryManager).toBe('function');
    expect(typeof core.getRegistry).toBe('function');
  });

  it('allows injecting custom registry', () => {
    const custom = {
      createRegistryManager: jest.fn(),
    } as unknown as typeof import('./registryManager');
    const core = createCore(custom);
    expect(core.createRegistryManager).toBe(custom.createRegistryManager);
  });
});
