import React, { useState } from 'react';
import { Modal, View, Button, StyleSheet, Switch, Text } from 'react-native';
import { setColor } from '../state/theme';
import { speechEnabled, setSpeechEnabled } from '../state/speech';

export interface SettingsProps {
  visible: boolean;
  onClose: () => void;
  onColor: (c: string) => void;
}

export default function Settings({
  visible,
  onClose,
  onColor,
}: SettingsProps): JSX.Element {
  const choose = async (c: string) => {
    await setColor(c);
    onColor(c);
  };
  const [voice, setVoice] = useState(speechEnabled);

  const toggleSpeech = async (v: boolean) => {
    setVoice(v);
    await setSpeechEnabled(v);
  };

  return (
    <Modal transparent visible={visible} animationType="slide">
      <View style={styles.container}>
        <View style={styles.row}>
          <Text style={styles.label}>Voice</Text>
          <Switch
            testID="speech-toggle"
            value={voice}
            onValueChange={toggleSpeech}
          />
        </View>
        <Button title="Red" onPress={() => choose('red')} />
        <Button title="Blue" onPress={() => choose('blue')} />
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
