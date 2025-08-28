import AsyncStorage from '@react-native-async-storage/async-storage';

const KEY = 'speech_enabled';

export let speechEnabled = true;

export async function setSpeechEnabled(value: boolean): Promise<void> {
  speechEnabled = value;
  await AsyncStorage.setItem(KEY, value ? '1' : '0');
}

export async function loadSpeechEnabled(): Promise<void> {
  const stored = await AsyncStorage.getItem(KEY);
  if (stored !== null) speechEnabled = stored === '1';
}
