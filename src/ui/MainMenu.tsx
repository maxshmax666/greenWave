import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import i18n from '../i18n';
import { usePremium } from '../premium/subscription';
import { PremiumFeature, requiresPremium } from '../premium/features';

const MENU_BG = 'rgba(0,0,0,0.8)';
const TEXT_COLOR = '#fff';

export interface MainMenuProps {
  visible: boolean;
  onStartNavigation: () => void;
  onClearRoute: () => void;
  onAddLight: () => void;
  onLogs: () => void;
  onSettings: () => void;
}

export default function MainMenu({
  visible,
  onStartNavigation,
  onClearRoute,
  onAddLight,
  onLogs,
  onSettings,
}: MainMenuProps) {
  const { isPremium } = usePremium();
  if (!visible) return null;
  return (
    <View style={styles.container} testID="main-menu">
      <TouchableOpacity onPress={onStartNavigation} style={styles.item}>
        <Text style={styles.text}>{i18n.t('menu.startNavigation')}</Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={onClearRoute} style={styles.item}>
        <Text style={styles.text}>{i18n.t('menu.clearRoute')}</Text>
      </TouchableOpacity>
      {isPremium || !requiresPremium(PremiumFeature.AddLight) ? (
        <TouchableOpacity onPress={onAddLight} style={styles.item}>
          <Text style={styles.text}>{i18n.t('menu.addLight')}</Text>
        </TouchableOpacity>
      ) : null}
      <TouchableOpacity onPress={onLogs} style={styles.item}>
        <Text style={styles.text}>{i18n.t('menu.logs')}</Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={onSettings} style={styles.item}>
        <Text style={styles.text}>{i18n.t('menu.settings')}</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: MENU_BG,
    borderRadius: 6,
    bottom: 80,
    padding: 8,
    position: 'absolute',
    right: 20,
  },
  item: {
    paddingVertical: 4,
  },
  text: {
    color: TEXT_COLOR,
    fontSize: 16,
  },
});
