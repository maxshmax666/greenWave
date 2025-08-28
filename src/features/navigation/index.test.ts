import type { NavigationState } from './index';
import {
  handleStartNavigation,
  handleClearRoute,
  initialState,
  cloneNavigationState,
} from './index';

describe('navigation helpers', () => {
  it('tracks start navigation', () => {
    const track = jest.fn();
    handleStartNavigation(track);
    expect(track).toHaveBeenCalledWith('navigation_start');
  });

  it('deep clones navigation state', () => {
    const copy = cloneNavigationState(initialState);
    copy.hudInfo.street = 'foo';
    expect(initialState.hudInfo.street).toBe('');
  });

  it('returns cloned custom state', () => {
    const custom: NavigationState = {
      ...initialState,
      hudInfo: { ...initialState.hudInfo, street: 'Main' },
      steps: [{ id: 1 }],
    };
    const state = handleClearRoute(custom);
    expect(state).toEqual(custom);
    expect(state).not.toBe(custom);
    state.hudInfo.street = 'Other';
    expect(custom.hudInfo.street).toBe('Main');
  });
});
