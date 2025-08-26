import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import i18n from '../src/i18n';

export default function MainMenu({
  visible,
  onStartNavigation,
  onClearRoute,
  onAddLight,
  onSettings,
}) {
  if (!visible) return null;
  return (
    <View style={styles.container} testID="main-menu">
      <TouchableOpacity onPress={onStartNavigation} style={styles.item}>
        <Text style={styles.text}>{i18n.t('menu.startNavigation')}</Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={onClearRoute} style={styles.item}>
        <Text style={styles.text}>{i18n.t('menu.clearRoute')}</Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={onAddLight} style={styles.item}>
        <Text style={styles.text}>{i18n.t('menu.addLight')}</Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={onSettings} style={styles.item}>
        <Text style={styles.text}>{i18n.t('menu.settings')}</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 80,
    right: 20,
    backgroundColor: 'rgba(0,0,0,0.8)',
    padding: 8,
    borderRadius: 6,
  },
  item: {
    paddingVertical: 4,
  },
  text: {
    color: '#fff',
    fontSize: 16,
  },
});

