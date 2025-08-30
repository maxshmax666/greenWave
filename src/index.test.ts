import { createCore } from './index';
import * as core from './core';

describe('index exports', () => {
  it('re-exports createCore', () => {
    expect(createCore).toBe(core.createCore);
  });
});
