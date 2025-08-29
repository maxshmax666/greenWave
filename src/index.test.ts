import {
  initRegistry,
  getRegistry,
  setRegistry,
  resetRegistry,
  getCommands,
  createRegistryManager,
} from './index';
import { createRegistry } from './registry';

afterEach(() => {
  resetRegistry();
});

describe('registry', () => {
  it('merges overrides into default modules', () => {
    const customCommand = () => {};
    const reg = initRegistry({ commands: { customCommand } });
    expect(reg.commands.customCommand).toBe(customCommand);
    // ensure other groups exist
    expect(reg.processors).toBeDefined();
    expect(reg.sources).toBeDefined();
    expect(reg.stores).toBeDefined();
  });

  it('returns the same instance unless reinitialized', () => {
    const first = getRegistry();
    const second = getRegistry();
    expect(first).toBe(second);
    const otherCommand = () => {};
    initRegistry({ commands: { otherCommand } });
    expect(getRegistry().commands.otherCommand).toBe(otherCommand);
  });

  it('allows injecting a custom registry', () => {
    const custom = createRegistry({});
    setRegistry(custom);
    expect(getRegistry()).toBe(custom);
  });

  it('resetRegistry clears existing instance', () => {
    const first = getRegistry();
    resetRegistry();
    const second = getRegistry();
    expect(second).not.toBe(first);
  });

  it('getCommands uses provided registry', () => {
    const custom = createRegistry({ commands: { foo: () => {} } });
    expect(getCommands(custom).foo).toBeDefined();
  });
});

describe('createRegistryManager', () => {
  it('creates isolated registries', () => {
    const mgr1 = createRegistryManager();
    const mgr2 = createRegistryManager();
    mgr1.initRegistry({ commands: { foo: () => {} } });
    expect(mgr1.getCommands().foo).toBeDefined();
    expect(mgr2.getCommands().foo).toBeUndefined();
  });
});
