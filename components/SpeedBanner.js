import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import i18n from '../src/i18n';

export default function SpeedBanner({ speed, nearestDist, timeToWindow }) {
  if (!speed) return null;
  return (
    <View style={styles.container} pointerEvents="none">
      <Text style={styles.text}>
        {i18n.t('speedBanner.recommendation', {
          speed: Math.round(speed),
          distance: Math.round(nearestDist),
          time: Math.round(timeToWindow),
        })}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 40,
    alignSelf: 'center',
    backgroundColor: 'rgba(0,0,0,0.6)',
    padding: 8,
    borderRadius: 6,
  },
  text: { color: '#fff' },
});
