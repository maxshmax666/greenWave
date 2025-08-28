import AsyncStorage from '@react-native-async-storage/async-storage';

const KEY = 'theme_color';

export let color = 'light';

export async function setColor(value: string): Promise<void> {
  color = value;
  await AsyncStorage.setItem(KEY, value);
}

export async function loadFromStorage(): Promise<void> {
  const stored = await AsyncStorage.getItem(KEY);
  if (stored) color = stored;
}
