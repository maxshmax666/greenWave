import React from 'react';
import { Text } from 'react-native';
import { calcSpeedRange } from './calcSpeedRange';

interface Props {
  dist_m: number;
  start_s: number;
  end_s: number;
}

// Displays speed range or fallback text
export function SpeedAdvisor({ dist_m, start_s, end_s }: Props) {
  const range = calcSpeedRange(dist_m, start_s, end_s);
  if (!range) return <Text>No green window</Text>;
  const { min, max } = range;
  return <Text>{`${min.toFixed(0)}–${max.toFixed(0)} km/h`}</Text>;
}
