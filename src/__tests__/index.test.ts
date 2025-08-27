import { handleStartNavigation, handleClearRoute, initialState } from '../index';

describe('navigation helpers', () => {
  it('tracks start navigation', () => {
    const track = jest.fn();
    handleStartNavigation(track);
    expect(track).toHaveBeenCalledWith('navigation_start');
  });

  it('returns cleared state', () => {
    const state = handleClearRoute();
    expect(state).toEqual(initialState);
    expect(state).not.toBe(initialState);
  });
});
