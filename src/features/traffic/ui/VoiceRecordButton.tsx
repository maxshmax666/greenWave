import React from 'react';
import { Button } from 'react-native';
import { useVoicePhaseLogger } from './useVoicePhaseLogger';

export function VoiceRecordButton() {
  const { start, stop, recording } = useVoicePhaseLogger();
  const onPress = recording ? stop : start;
  return <Button title={recording ? 'Stop' : 'Record'} onPress={onPress} />;
}
