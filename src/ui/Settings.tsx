import React from 'react';
import { Modal, View, Button, StyleSheet } from 'react-native';
import { setColor } from '../state/theme';

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

  return (
    <Modal transparent visible={visible} animationType="slide">
      <View style={styles.container}>
        <Button title="Red" onPress={() => choose('red')} />
        <Button title="Blue" onPress={() => choose('blue')} />
        <Button title="Close" onPress={onClose} />
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    backgroundColor: BG_COLOR,
    flex: 1,
    justifyContent: 'center',
  },
});

const BG_COLOR = 'white';
