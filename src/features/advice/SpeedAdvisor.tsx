import React from 'react';
import { Text } from 'react-native';

export interface SpeedRange {
  min: number;
  max: number;
}

// calculate speed range in km/h to cover distance within window
export function calcSpeedRange(
  dist_m: number,
  start_s: number,
  end_s: number,
): SpeedRange | null {
  if (start_s <= 0 || end_s <= 0 || start_s >= end_s) return null;
  const min = (dist_m / end_s) * 3.6;
  const max = (dist_m / start_s) * 3.6;
  const clampedMin = Math.max(10, Math.min(60, min));
  const clampedMax = Math.max(10, Math.min(60, max));
  if (clampedMin > clampedMax) return null;
  return { min: clampedMin, max: clampedMax };
}

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
