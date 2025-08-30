import { api } from './index';
import * as core from './core';
import * as navigation from './navigationFactory';
import * as registry from './registryManager';
import { cloneNavigationState } from './features/navigation/cloneNavigationState';

describe('index api', () => {
  it('exposes core helpers', () => {
    expect(api.createCore).toBe(core.createCore);
  });

  it('exposes navigation helpers', () => {
    expect(api.createNavigation).toBe(navigation.createNavigation);
    expect(api.initialState).toBe(navigation.initialState);
  });

  it('exposes registry helpers', () => {
    expect(api.createRegistryManager).toBe(registry.createRegistryManager);
  });

  it('exposes cloneNavigationState', () => {
    expect(api.cloneNavigationState).toBe(cloneNavigationState);
  });
});
