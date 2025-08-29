import AsyncStorage from '@react-native-async-storage/async-storage';
import { theme, setTheme, loadTheme } from './theme';

jest.mock('@react-native-async-storage/async-storage', () => {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  return require('@react-native-async-storage/async-storage/jest/async-storage-mock');
});

beforeEach(async () => {
  await AsyncStorage.clear();
});

describe('theme state', () => {
  it('loads theme from storage', async () => {
    await AsyncStorage.setItem('theme', 'dark');
    await loadTheme();
    expect(theme).toBe('dark');
  });

  it('saves theme to storage', async () => {
    await setTheme('dark');
    expect(await AsyncStorage.getItem('theme')).toBe('dark');
  });

  it('propagates storage failure', async () => {
    (AsyncStorage.getItem as jest.Mock).mockRejectedValueOnce(
      new Error('fail'),
    );
    await expect(loadTheme()).rejects.toThrow('fail');
  });
});
