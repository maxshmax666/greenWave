import {
  createNavigation,
  createNavigationFactory,
  initialState,
  resolveNavigationDeps,
  defaultNavigationDeps,
  cloneNavigationState,
} from './index';

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
    const nav = createNavigation(undefined, {
      deps: { handleStartNavigation: custom },
    });
    nav.handleStartNavigation(jest.fn());
    expect(custom).toHaveBeenCalled();
  });

  it('creates factory with injected deps', () => {
    const custom = jest.fn();
    const factory = createNavigationFactory({
      deps: { handleStartNavigation: custom },
    });
    const nav = factory();
    nav.handleStartNavigation(jest.fn());
    expect(custom).toHaveBeenCalled();
  });

  it('resolves default dependencies', () => {
    const deps = resolveNavigationDeps();
    expect(deps).toEqual(defaultNavigationDeps);
  });

  it('overrides dependencies', () => {
    const custom = jest.fn();
    const deps = resolveNavigationDeps({ handleStartNavigation: custom });
    expect(deps.handleStartNavigation).toBe(custom);
  });

  it('clones navigation state', () => {
    const clone = cloneNavigationState(initialState);
    expect(clone).toEqual(initialState);
    expect(clone).not.toBe(initialState);
  });

  it('allows custom state cloning', () => {
    const customClone = jest.fn().mockReturnValue(initialState);
    const nav = createNavigation(undefined, { cloneState: customClone });
    expect(customClone).toHaveBeenCalled();
    expect(nav.initialState).toEqual(initialState);
  });
});
