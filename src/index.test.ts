import { createCore, createNavigation } from './index';

describe('createCore', () => {
  it('exposes navigation helpers and registry functions', () => {
    const core = createCore();
    expect(core.createNavigation).toBe(createNavigation);
    expect(typeof core.createRegistryManager).toBe('function');
    expect(typeof core.getRegistry).toBe('function');
  });
});
