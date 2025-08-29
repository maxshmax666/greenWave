import React from 'react';
import { TouchableOpacity, Text, StyleSheet } from 'react-native';
import MainMenu from './MainMenu';

interface Props {
  visible: boolean;
  onToggle: () => void;
  onStartNavigation: () => void;
  onClearRoute: () => void;
  onAddLight: () => void;
  onLogs: () => void;
  onSettings: () => void;
}

export default function MenuContainer({
  visible,
  onToggle,
  onStartNavigation,
  onClearRoute,
  onAddLight,
  onLogs,
  onSettings,
}: Props): JSX.Element {
  return (
    <>
      <MainMenu
        visible={visible}
        onStartNavigation={onStartNavigation}
        onClearRoute={onClearRoute}
        onAddLight={onAddLight}
        onLogs={onLogs}
        onSettings={onSettings}
      />
      <TouchableOpacity
        style={styles.fab}
        onPress={onToggle}
        testID="menu-button"
      >
        <Text style={styles.fabText}>☰</Text>
      </TouchableOpacity>
    </>
  );
}

const FAB_BG = 'rgba(0,0,0,0.8)';
const FAB_TEXT_COLOR = '#fff';

const styles = StyleSheet.create({
  fab: {
    alignItems: 'center',
    backgroundColor: FAB_BG,
    borderRadius: 25,
    bottom: 20,
    height: 50,
    justifyContent: 'center',
    position: 'absolute',
    right: 20,
    width: 50,
  },
  fabText: {
    color: FAB_TEXT_COLOR,
    fontSize: 24,
  },
});
