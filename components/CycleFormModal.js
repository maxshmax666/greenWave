import React, { useState } from 'react';
import { Modal, View, Text, TextInput, Button } from 'react-native';

export default function CycleFormModal({ visible, onSubmit, onCancel }) {
  const [cycleSeconds, setCycleSeconds] = useState('60');
  const [t0, setT0] = useState(new Date().toISOString());
  const [mainStart, setMainStart] = useState('0');
  const [mainEnd, setMainEnd] = useState('10');
  const [secStart, setSecStart] = useState('10');
  const [secEnd, setSecEnd] = useState('20');
  const [pedStart, setPedStart] = useState('20');
  const [pedEnd, setPedEnd] = useState('30');

  const save = () => {
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
          <Text>Cycle seconds</Text>
          <TextInput value={cycleSeconds} onChangeText={setCycleSeconds} keyboardType="numeric" />
          <Text>t0 ISO</Text>
          <TextInput value={t0} onChangeText={setT0} />
          <Text>Main green start/end</Text>
          <View style={{ flexDirection:'row' }}>
            <TextInput style={{ flex:1 }} value={mainStart} onChangeText={setMainStart} keyboardType="numeric" />
            <TextInput style={{ flex:1 }} value={mainEnd} onChangeText={setMainEnd} keyboardType="numeric" />
          </View>
          <Text>Secondary green start/end</Text>
          <View style={{ flexDirection:'row' }}>
            <TextInput style={{ flex:1 }} value={secStart} onChangeText={setSecStart} keyboardType="numeric" />
            <TextInput style={{ flex:1 }} value={secEnd} onChangeText={setSecEnd} keyboardType="numeric" />
          </View>
          <Text>Pedestrian green start/end</Text>
          <View style={{ flexDirection:'row' }}>
            <TextInput style={{ flex:1 }} value={pedStart} onChangeText={setPedStart} keyboardType="numeric" />
            <TextInput style={{ flex:1 }} value={pedEnd} onChangeText={setPedEnd} keyboardType="numeric" />
          </View>
          <Button title="Save" onPress={save} />
          <Button title="Cancel" onPress={onCancel} />
        </View>
      </View>
    </Modal>
  );
}
