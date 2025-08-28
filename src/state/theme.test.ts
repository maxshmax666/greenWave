import AsyncStorage from '@react-native-async-storage/async-storage';
import { color, setColor, loadFromStorage } from './theme';

jest.mock('@react-native-async-storage/async-storage', () => {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  return require('@react-native-async-storage/async-storage/jest/async-storage-mock');
});

beforeEach(async () => {
  await AsyncStorage.clear();
});

describe('theme state', () => {
  it('loads color from storage', async () => {
    await AsyncStorage.setItem('theme_color', 'red');
    await loadFromStorage();
    expect(color).toBe('red');
  });

  it('saves color to storage', async () => {
    await setColor('blue');
    expect(await AsyncStorage.getItem('theme_color')).toBe('blue');
  });
});
