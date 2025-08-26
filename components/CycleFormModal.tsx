import React, { useState } from 'react';
import { Modal, View, Text, TextInput, Button, Alert } from 'react-native';
import i18n from '../src/i18n';
import { validateCycle } from '../src/validation';

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

export default function CycleFormModal({ visible, onSubmit, onCancel }: CycleFormModalProps) {
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
      <View style={{ flex:1, justifyContent:'center', backgroundColor:'rgba(0,0,0,0.5)' }}>
        <View style={{ margin:20, padding:20, backgroundColor:'white' }}>
          <Text>{i18n.t('cycleForm.cycleSeconds')}</Text>
          <TextInput value={cycleSeconds} onChangeText={setCycleSeconds} keyboardType="numeric" />
          <Text>{i18n.t('cycleForm.t0')}</Text>
          <TextInput value={t0} onChangeText={setT0} />
          <Text>{i18n.t('cycleForm.main')}</Text>
          <View style={{ flexDirection:'row' }}>
            <TextInput style={{ flex:1 }} value={mainStart} onChangeText={setMainStart} keyboardType="numeric" />
            <TextInput style={{ flex:1 }} value={mainEnd} onChangeText={setMainEnd} keyboardType="numeric" />
          </View>
          <Text>{i18n.t('cycleForm.secondary')}</Text>
          <View style={{ flexDirection:'row' }}>
            <TextInput style={{ flex:1 }} value={secStart} onChangeText={setSecStart} keyboardType="numeric" />
            <TextInput style={{ flex:1 }} value={secEnd} onChangeText={setSecEnd} keyboardType="numeric" />
          </View>
          <Text>{i18n.t('cycleForm.pedestrian')}</Text>
          <View style={{ flexDirection:'row' }}>
            <TextInput style={{ flex:1 }} value={pedStart} onChangeText={setPedStart} keyboardType="numeric" />
            <TextInput style={{ flex:1 }} value={pedEnd} onChangeText={setPedEnd} keyboardType="numeric" />
          </View>
          <Button title={i18n.t('common.save')} onPress={save} disabled={!!error} />
          <Button title={i18n.t('common.cancel')} onPress={onCancel} />
        </View>
      </View>
    </Modal>
  );
}
