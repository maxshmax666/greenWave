import AsyncStorage from '@react-native-async-storage/async-storage';
import { speechEnabled, setSpeechEnabled, loadSpeechEnabled } from './speech';

jest.mock('@react-native-async-storage/async-storage', () => {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  return require('@react-native-async-storage/async-storage/jest/async-storage-mock');
});

beforeEach(async () => {
  await AsyncStorage.clear();
});

describe('speech state', () => {
  it('loads flag from storage', async () => {
    await AsyncStorage.setItem('speech_enabled', '0');
    await loadSpeechEnabled();
    expect(speechEnabled).toBe(false);
  });

  it('saves flag to storage', async () => {
    await setSpeechEnabled(false);
    expect(await AsyncStorage.getItem('speech_enabled')).toBe('0');
  });
});
