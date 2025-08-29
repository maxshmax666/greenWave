import * as api from '../index';

describe('index exports', () => {
  it('exposes registry helpers', () => {
    expect(typeof api.createNavigation).toBe('function');
    expect(typeof api.getRegistry).toBe('function');
  });
});
