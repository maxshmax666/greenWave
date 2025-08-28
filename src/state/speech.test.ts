import AsyncStorage from '@react-native-async-storage/async-storage';
import * as speech from './speech';
const { setSpeechEnabled, loadSpeechEnabled } = speech;

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
    expect(speech.speechEnabled).toBe(false);
  });

  it('saves flag to storage', async () => {
    await setSpeechEnabled(false);
    expect(await AsyncStorage.getItem('speech_enabled')).toBe('0');
  });

  it('toggles and persists', async () => {
    await setSpeechEnabled(false);
    await setSpeechEnabled(true);
    expect(await AsyncStorage.getItem('speech_enabled')).toBe('1');
  });
});
