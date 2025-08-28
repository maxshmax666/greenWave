import { createNavigation, initialState, cloneNavigationState } from './index';

describe('index navigation facade', () => {
  it('deep clones navigation state', () => {
    const clone = cloneNavigationState(initialState);
    clone.hudInfo.street = 'foo';
    expect(initialState.hudInfo.street).toBe('');
  });

  it('createNavigation isolates nested hudInfo', () => {
    const custom = {
      ...initialState,
      hudInfo: { ...initialState.hudInfo, street: 'Main' },
    };
    const nav = createNavigation(custom);
    nav.initialState.hudInfo.street = 'Other';
    expect(custom.hudInfo.street).toBe('Main');
  });
});
