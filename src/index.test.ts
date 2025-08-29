import { initRegistry, getRegistry } from './index';

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
});
