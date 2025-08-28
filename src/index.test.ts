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

  it('uses provided initial state copy', () => {
    const custom = { ...initialState, recommended: 42 };
    const nav = createNavigation(custom);
    expect(nav.initialState).toEqual(custom);
    expect(nav.initialState).not.toBe(custom);
  });

  it('allows injecting handlers', () => {
    const custom = jest.fn();
    const nav = createNavigation(undefined, { handleStartNavigation: custom });
    nav.handleStartNavigation(jest.fn());
    expect(custom).toHaveBeenCalled();
  });
});
