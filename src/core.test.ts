import { createCore } from './core';
import { createNavigation } from './navigationFactory';

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
    const core = createCore({ registry: custom });
    expect(core.createRegistryManager).toBe(custom.createRegistryManager);
  });

  it('allows injecting custom navigation', () => {
    const navigation = {
      createNavigation: jest.fn(),
      initialState: { foo: 'bar' },
    } as unknown as {
      createNavigation: typeof createNavigation;
      initialState: typeof import('./navigationFactory').initialState;
    };
    const core = createCore({ navigation });
    expect(core.createNavigation).toBe(navigation.createNavigation);
    expect(core.initialState).toBe(navigation.initialState);
  });

  it('allows injecting custom cloneNavigationState', () => {
    const clone = jest.fn();
    const core = createCore({ cloneNavigationState: clone });
    expect(core.cloneNavigationState).toBe(clone);
  });
});
