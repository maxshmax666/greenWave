import { useState, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Voice from 'expo-voice';
import type { PhaseRecord } from '../../../interfaces/phaseSync';
import { STORAGE_KEY } from '../services/phaseSync';

const COLOR_RE = /(red|yellow|green)/i;
const TIME_RE = /(\d+(?:\.\d+)?)/;

export function parseVoiceResult(input: string): PhaseRecord | null {
  const color = input.match(COLOR_RE)?.[1]?.toLowerCase();
  const time = input.match(TIME_RE)?.[1];
  if (!color || !time) return null;
  return { color: color as PhaseRecord['color'], startTime: Number(time) };
}

export function useVoicePhaseLogger() {
  const [recording, setRecording] = useState(false);

  const start = useCallback(async () => {
    setRecording(true);
    await Voice.startAsync();
  }, []);

  const stop = useCallback(async () => {
    const result = await Voice.stopAsync();
    setRecording(false);
    const record = parseVoiceResult(result);
    if (record) {
      const raw = await AsyncStorage.getItem(STORAGE_KEY);
      const list: PhaseRecord[] = raw ? JSON.parse(raw) : [];
      list.push(record);
      await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(list));
    }
  }, []);

  return { start, stop, recording } as const;
}
