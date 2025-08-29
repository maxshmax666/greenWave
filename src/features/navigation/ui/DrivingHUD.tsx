import React, { useEffect, useRef } from 'react';
import { SafeAreaView, View, Text, StyleSheet } from 'react-native';
import * as Speech from 'expo-speech';
import i18n from '../../../i18n';
import { usePremium } from '../../../premium/subscription';
import { PremiumFeature, requiresPremium } from '../../../premium/features';
import { speechEnabled } from '../../../state/speech';

export interface DrivingHUDProps {
  maneuver?: string;
  distance?: number;
  street?: string;
  eta?: number;
  speed?: number;
  speedLimit?: number;
}

export default function DrivingHUD({
  maneuver,
  distance,
  street,
  eta,
  speed,
  speedLimit,
}: DrivingHUDProps) {
  const { isPremium } = usePremium();
  const speedKmh = Math.round(speed || 0);
  const limit = speedLimit ? Math.round(speedLimit) : '--';
  const spoken = useRef<string | undefined>();

  useEffect(() => {
    if (speechEnabled && maneuver && spoken.current !== maneuver) {
      Speech.speak(
        i18n.t('hud.maneuver', {
          maneuver,
          distance: Math.round(distance ?? 0),
        }),
      );
      spoken.current = maneuver;
    }
  }, [maneuver, distance]);
  return (
    <SafeAreaView style={styles.container} pointerEvents="none">
      <View style={styles.maneuverPanel}>
        <Text testID="hud-maneuver" style={styles.text}>
          {maneuver
            ? i18n.t('hud.maneuver', {
                maneuver,
                distance: Math.round(distance ?? 0),
              })
            : ''}
        </Text>
      </View>
      {isPremium || !requiresPremium(PremiumFeature.SpeedPanel) ? (
        <View style={styles.speedPanel}>
          <Text testID="hud-speed" style={styles.text}>
            {i18n.t('hud.speed', { speed: speedKmh })}
          </Text>
          <Text testID="hud-speed-limit" style={styles.text}>
            {i18n.t('hud.limit', { limit })}
          </Text>
        </View>
      ) : null}
      <View style={styles.streetPanel}>
        <Text testID="hud-street" style={styles.text}>
          {street}
        </Text>
      </View>
      <View style={styles.etaPanel}>
        <Text testID="hud-eta" style={styles.text}>
          {i18n.t('hud.eta', { eta: eta ? Math.round(eta) : '--' })}
        </Text>
      </View>
    </SafeAreaView>
  );
}

const PANEL_BG = 'rgba(0,0,0,0.6)';
const TEXT_COLOR = '#fff';

const styles = StyleSheet.create({
  container: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'space-between',
  },
  etaPanel: {
    alignSelf: 'stretch',
    backgroundColor: PANEL_BG,
    padding: 8,
  },
  maneuverPanel: {
    alignSelf: 'center',
    backgroundColor: PANEL_BG,
    borderRadius: 6,
    marginTop: 10,
    padding: 8,
  },
  speedPanel: {
    backgroundColor: PANEL_BG,
    borderRadius: 6,
    bottom: 60,
    left: 10,
    padding: 8,
    position: 'absolute',
  },
  streetPanel: {
    alignSelf: 'center',
    backgroundColor: PANEL_BG,
    borderRadius: 6,
    bottom: 60,
    flexDirection: 'row',
    justifyContent: 'space-between',
    padding: 8,
    position: 'absolute',
    width: 200,
  },
  text: {
    color: TEXT_COLOR,
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
});
