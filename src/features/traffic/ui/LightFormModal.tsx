import React, { useState } from 'react';
import {
  Modal,
  View,
  Text,
  TextInput,
  Button,
  Alert,
  StyleSheet,
} from 'react-native';
import i18n from '../../../i18n';
import { validateLight } from '../../../validation';

export interface LightFormModalProps {
  visible: boolean;
  coordinate: { latitude: number; longitude: number };
  onSubmit: (data: { name: string; direction: string; lat: number; lon: number }) => void;
  onCancel: () => void;
}

export default function LightFormModal({
  visible,
  coordinate,
  onSubmit,
  onCancel,
}: LightFormModalProps) {
  const [name, setName] = useState('');
  const [direction, setDirection] = useState('MAIN');
  const error = validateLight(name, direction);

  const save = () => {
    const msg = validateLight(name, direction);
    if (msg) {
      Alert.alert(i18n.t('validation.title'), msg);
      return;
    }
    onSubmit({
      name,
      direction,
      lat: coordinate.latitude,
      lon: coordinate.longitude,
    });
    setName('');
    setDirection('MAIN');
  };

  return (
    <Modal visible={visible} transparent>
      <View style={styles.container}>
        <View style={styles.modal}>
          <Text>{i18n.t('lightForm.name')}</Text>
          <TextInput style={styles.input} value={name} onChangeText={setName} />
          <Text>{i18n.t('lightForm.direction')}</Text>
          <View style={[styles.row, styles.buttonRow]}>
            {['MAIN','SECONDARY','PEDESTRIAN'].map(d => (
              <Button
                key={d}
                title={i18n.t(`directions.${d}`)}
                onPress={() => setDirection(d)}
                color={direction===d ? 'blue' : undefined}
              />
            ))}
          </View>
          <Button title={i18n.t('common.save')} onPress={save} disabled={!!error} />
          <Button title={i18n.t('common.cancel')} onPress={onCancel} />
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: 'rgba(0,0,0,0.5)',
  },
  modal: {
    margin: 20,
    padding: 20,
    backgroundColor: 'white',
  },
  row: {
    flexDirection: 'row',
  },
  buttonRow: {
    justifyContent: 'space-around',
    marginVertical: 10,
  },
  input: {},
});
