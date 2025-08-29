import AsyncStorage from '@react-native-async-storage/async-storage';
import type { ThemeName } from '../styles/tokens';

const KEY = 'theme';

export let theme: ThemeName = 'light';

export async function setTheme(value: ThemeName): Promise<void> {
  theme = value;
  await AsyncStorage.setItem(KEY, value);
}

export async function loadTheme(): Promise<void> {
  const stored = await AsyncStorage.getItem(KEY);
  if (stored === 'light' || stored === 'dark') theme = stored;
}
