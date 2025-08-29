import { createRegistry } from './index';

describe('createRegistry', () => {
  it('merges overrides into default modules', () => {
    const customCommand = () => {};
    const reg = createRegistry({ commands: { customCommand } });
    expect(reg.commands.customCommand).toBe(customCommand);
    // ensure other groups exist
    expect(reg.processors).toBeDefined();
    expect(reg.sources).toBeDefined();
    expect(reg.stores).toBeDefined();
  });
});
