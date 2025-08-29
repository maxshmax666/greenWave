import { initRegistry, getRegistry, setRegistry, resetRegistry } from './index';
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
});
