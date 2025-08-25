import React from 'react';
import { SafeAreaView, View, Text, StyleSheet } from 'react-native';

export default function DrivingHUD() {
  return (
    <SafeAreaView style={styles.container} pointerEvents="none">
      <View style={styles.maneuvers}><Text style={styles.text}>Next Maneuver</Text></View>
      <View style={styles.speedPanel}>
        <Text style={styles.text}>Speed: --</Text>
        <Text style={styles.text}>Limit: --</Text>
      </View>
      <View style={styles.streetPanel}>
        <Text style={styles.text}>Street Name</Text>
        <Text style={styles.text}>Mute</Text>
      </View>
      <View style={styles.etaPanel}><Text style={styles.text}>ETA -- | Progress 0%</Text></View>
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
  text: { color: '#fff', textAlign: 'center' }
});
