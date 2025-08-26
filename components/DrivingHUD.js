import React from 'react';
import { SafeAreaView, View, Text, StyleSheet } from 'react-native';
import i18n from '../src/i18n';

export default function DrivingHUD({
  maneuver,
  distance,
  street,
  eta,
  speed,
  speedLimit,
}) {
  const speedKmh = Math.round(speed || 0);
  const limit = speedLimit ? Math.round(speedLimit) : '--';
  return (
    <SafeAreaView style={styles.container} pointerEvents="none">
      <View style={styles.maneuvers}>
        <Text testID="hud-maneuver" style={styles.text}>
          {maneuver
            ? i18n.t('hud.maneuver', {
                maneuver,
                distance: Math.round(distance),
              })
            : ''}
        </Text>
      </View>
      <View style={styles.speedPanel}>
        <Text testID="hud-speed" style={styles.text}>
          {i18n.t('hud.speed', { speed: speedKmh })}
        </Text>
        <Text testID="hud-speed-limit" style={styles.text}>
          {i18n.t('hud.limit', { limit })}
        </Text>
      </View>
      <View style={styles.streetPanel}>
        <Text testID="hud-street" style={styles.text}>{street}</Text>
      </View>
      <View style={styles.etaPanel}>
        <Text testID="hud-eta" style={styles.text}>
          {i18n.t('hud.eta', { eta: eta ? Math.round(eta) : '--' })}
        </Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'space-between',
  },
  maneuvers: {
    alignSelf: 'center',
    marginTop: 10,
    backgroundColor: 'rgba(0,0,0,0.6)',
    padding: 8,
    borderRadius: 6,
  },
  speedPanel: {
    position: 'absolute',
    left: 10,
    bottom: 60,
    backgroundColor: 'rgba(0,0,0,0.6)',
    padding: 8,
    borderRadius: 6,
  },
  streetPanel: {
    position: 'absolute',
    alignSelf: 'center',
    bottom: 60,
    backgroundColor: 'rgba(0,0,0,0.6)',
    padding: 8,
    borderRadius: 6,
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: 200,
  },
  etaPanel: {
    alignSelf: 'stretch',
    backgroundColor: 'rgba(0,0,0,0.6)',
    padding: 8,
  },
  text: { color: '#fff', textAlign: 'center', fontSize: 16, fontWeight: '600' }
});
