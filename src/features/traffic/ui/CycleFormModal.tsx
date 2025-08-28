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
import { validateCycle } from '../../../validation';

interface CycleData {
  cycle_seconds: number;
  t0_iso: string;
  main_green: [number, number];
  secondary_green: [number, number];
  ped_green: [number, number];
}

export interface CycleFormModalProps {
  visible: boolean;
  onSubmit: (data: CycleData) => void;
  onCancel: () => void;
}

export default function CycleFormModal({
  visible,
  onSubmit,
  onCancel,
}: CycleFormModalProps) {
  const [cycleSeconds, setCycleSeconds] = useState('60');
  const [t0, setT0] = useState(new Date().toISOString());
  const [mainStart, setMainStart] = useState('0');
  const [mainEnd, setMainEnd] = useState('10');
  const [secStart, setSecStart] = useState('10');
  const [secEnd, setSecEnd] = useState('20');
  const [pedStart, setPedStart] = useState('20');
  const [pedEnd, setPedEnd] = useState('30');
  const error = validateCycle({
    cycleSeconds,
    mainStart,
    mainEnd,
    secStart,
    secEnd,
    pedStart,
    pedEnd,
  });

  const save = () => {
    const msg = validateCycle({
      cycleSeconds,
      mainStart,
      mainEnd,
      secStart,
      secEnd,
      pedStart,
      pedEnd,
    });
    if (msg) {
      Alert.alert(i18n.t('validation.title'), msg);
      return;
    }
    onSubmit({
      cycle_seconds: Number(cycleSeconds),
      t0_iso: t0,
      main_green: [Number(mainStart), Number(mainEnd)],
      secondary_green: [Number(secStart), Number(secEnd)],
      ped_green: [Number(pedStart), Number(pedEnd)],
    });
  };

  return (
    <Modal visible={visible} transparent>
      <View style={styles.container}>
        <View style={styles.modal}>
          <Text>{i18n.t('cycleForm.cycleSeconds')}</Text>
          <TextInput
            style={styles.input}
            value={cycleSeconds}
            onChangeText={setCycleSeconds}
            keyboardType="numeric"
          />
          <Text>{i18n.t('cycleForm.t0')}</Text>
          <TextInput style={styles.input} value={t0} onChangeText={setT0} />
          <Text>{i18n.t('cycleForm.main')}</Text>
          <View style={styles.row}>
            <TextInput
              style={[styles.input, styles.rowInput]}
              value={mainStart}
              onChangeText={setMainStart}
              keyboardType="numeric"
            />
            <TextInput
              style={[styles.input, styles.rowInput]}
              value={mainEnd}
              onChangeText={setMainEnd}
              keyboardType="numeric"
            />
          </View>
          <Text>{i18n.t('cycleForm.secondary')}</Text>
          <View style={styles.row}>
            <TextInput
              style={[styles.input, styles.rowInput]}
              value={secStart}
              onChangeText={setSecStart}
              keyboardType="numeric"
            />
            <TextInput
              style={[styles.input, styles.rowInput]}
              value={secEnd}
              onChangeText={setSecEnd}
              keyboardType="numeric"
            />
          </View>
          <Text>{i18n.t('cycleForm.pedestrian')}</Text>
          <View style={styles.row}>
            <TextInput
              style={[styles.input, styles.rowInput]}
              value={pedStart}
              onChangeText={setPedStart}
              keyboardType="numeric"
            />
            <TextInput
              style={[styles.input, styles.rowInput]}
              value={pedEnd}
              onChangeText={setPedEnd}
              keyboardType="numeric"
            />
          </View>
          <Button
            title={i18n.t('common.save')}
            onPress={save}
            disabled={!!error}
          />
          <Button title={i18n.t('common.cancel')} onPress={onCancel} />
        </View>
      </View>
    </Modal>
  );
}

const OVERLAY_COLOR = 'rgba(0,0,0,0.5)';
const MODAL_BG = '#ffffff';

const styles = StyleSheet.create({
  container: {
    backgroundColor: OVERLAY_COLOR,
    flex: 1,
    justifyContent: 'center',
  },
  input: {},
  modal: {
    backgroundColor: MODAL_BG,
    margin: 20,
    padding: 20,
  },
  row: {
    flexDirection: 'row',
  },
  rowInput: {
    flex: 1,
  },
});
