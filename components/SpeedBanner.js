import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function SpeedBanner({ speed, nearestDist, timeToWindow }) {
  if (!speed) return null;
  return (
    <View style={styles.container} pointerEvents="none">
      <Text style={styles.text}>
        Рекомендуем {Math.round(speed)} км/ч • ближайший светофор через {Math.round(nearestDist)} м • окно через {Math.round(timeToWindow)} с
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
