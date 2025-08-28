import {
  createNavigation,
  initialState,
  cloneNavigationState,
  commands,
  processors,
  sources,
  stores,
} from './index';

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

  it('createNavigation isolates maneuver', () => {
    const nav = createNavigation();
    nav.initialState.hudInfo.maneuver = 'x';
    expect(initialState.hudInfo.maneuver).toBe('');
  });

  it('exposes grouped modules for testing', () => {
    expect(typeof commands).toBe('object');
    expect(typeof processors).toBe('object');
    expect(typeof sources).toBe('object');
    expect(typeof stores).toBe('object');
  });
});
