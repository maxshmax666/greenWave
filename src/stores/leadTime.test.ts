import AsyncStorage from '@react-native-async-storage/async-storage';
import { leadTimeStore } from './leadTime';

jest.mock('@react-native-async-storage/async-storage', () =>
  jest.requireActual(
    '@react-native-async-storage/async-storage/jest/async-storage-mock',
  ),
);

describe('leadTimeStore', () => {
  beforeEach(async () => {
    await AsyncStorage.clear();
  });

  it('returns 0 when unset', async () => {
    expect(await leadTimeStore.get()).toBe(0);
  });

  it('persists and retrieves value', async () => {
    await leadTimeStore.set(5);
    expect(await AsyncStorage.getItem('lead_time_sec')).toBe('5');
    expect(await leadTimeStore.get()).toBe(5);
  });
});
