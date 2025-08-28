import { createNavigation, initialState } from './index';

describe('index facade', () => {
  it('creates navigation helpers', () => {
    const nav = createNavigation();
    const track = jest.fn();
    nav.handleStartNavigation(track);
    expect(track).toHaveBeenCalledWith('navigation_start');
  });

  it('returns a copy of initial state', () => {
    const nav = createNavigation();
    expect(nav.initialState).toEqual(initialState);
    expect(nav.initialState).not.toBe(initialState);
  });
});
