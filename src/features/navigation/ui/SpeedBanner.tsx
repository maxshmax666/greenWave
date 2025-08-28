import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import i18n from '../../../i18n';

export interface SpeedBannerProps {
  speed?: number;
  nearestDist?: number;
  timeToWindow?: number;
}

export default function SpeedBanner({
  speed,
  nearestDist,
  timeToWindow,
}: SpeedBannerProps) {
  if (!speed) return null;
  return (
    <View style={styles.container} pointerEvents="none">
      <Text style={styles.text}>
        {i18n.t('speedBanner.recommendation', {
          speed: Math.round(speed),
          distance: Math.round(nearestDist ?? 0),
          time: Math.round(timeToWindow ?? 0),
        })}
      </Text>
    </View>
  );
}

const BG_COLOR = 'rgba(0,0,0,0.6)';
const TEXT_COLOR = '#fff';

const styles = StyleSheet.create({
  container: {
    alignSelf: 'center',
    backgroundColor: BG_COLOR,
    borderRadius: 6,
    padding: 8,
    position: 'absolute',
    top: 40,
  },
  text: { color: TEXT_COLOR },
});
