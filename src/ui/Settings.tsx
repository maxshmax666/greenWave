import React, { useState } from 'react';
import { Modal, View, StyleSheet, Switch, Text, Button } from 'react-native';
import { setTheme, theme } from '../state/theme';
import { speechEnabled, setSpeechEnabled } from '../state/speech';

export interface SettingsProps {
  visible: boolean;
  onClose: () => void;
  onTheme: (t: 'light' | 'dark') => void;
}

export default function Settings({
  visible,
  onClose,
  onTheme,
}: SettingsProps): JSX.Element {
  const [voice, setVoice] = useState(speechEnabled);
  const [dark, setDark] = useState(theme === 'dark');

  const toggleTheme = async (v: boolean) => {
    setDark(v);
    const next = v ? 'dark' : 'light';
    await setTheme(next);
    onTheme(next);
  };

  const toggleSpeech = async (v: boolean) => {
    setVoice(v);
    await setSpeechEnabled(v);
  };

  return (
    <Modal transparent visible={visible} animationType="slide">
      <View style={styles.container}>
        <View style={styles.row}>
          <Text style={styles.label}>Dark mode</Text>
          <Switch
            testID="theme-toggle"
            value={dark}
            onValueChange={toggleTheme}
          />
        </View>
        <View style={styles.row}>
          <Text style={styles.label}>Voice</Text>
          <Switch
            testID="speech-toggle"
            value={voice}
            onValueChange={toggleSpeech}
          />
        </View>
        <Button title="Close" onPress={onClose} />
      </View>
    </Modal>
  );
}
const BG_COLOR = 'white';

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    backgroundColor: BG_COLOR,
    flex: 1,
    justifyContent: 'center',
  },
  label: {
    marginRight: 8,
  },
  row: {
    alignItems: 'center',
    flexDirection: 'row',
    marginBottom: 8,
  },
});
