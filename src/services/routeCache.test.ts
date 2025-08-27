import AsyncStorage from '@react-native-async-storage/async-storage';
import type { RouteResult } from './ors';
import { saveRoute, loadRoute } from './routeCache';

jest.mock('@react-native-async-storage/async-storage', () => {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  return require('@react-native-async-storage/async-storage/jest/async-storage-mock');
});

const route: RouteResult = {
  geometry: [{ latitude: 1, longitude: 2 }],
  distance: 1,
  duration: 1,
  steps: [],
};

beforeEach(async () => {
  await AsyncStorage.clear();
});

describe('routeCache', () => {
  it('saves and loads route', async () => {
    await saveRoute(route);
    const loaded = await loadRoute();
    expect(loaded).toEqual(route);
  });

  it('returns null when empty', async () => {
    const loaded = await loadRoute();
    expect(loaded).toBeNull();
  });
});
