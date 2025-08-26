import React, { useState } from 'react';
import { Modal, View, Text, TextInput, Button } from 'react-native';

export default function LightFormModal({ visible, coordinate, onSubmit, onCancel }) {
  const [name, setName] = useState('');
  const [direction, setDirection] = useState('MAIN');

  const save = () => {
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
      <View style={{ flex:1, justifyContent:'center', backgroundColor:'rgba(0,0,0,0.5)' }}>
        <View style={{ margin:20, padding:20, backgroundColor:'white' }}>
          <Text>Name</Text>
          <TextInput value={name} onChangeText={setName} />
          <Text>Direction</Text>
          <View style={{ flexDirection:'row', justifyContent:'space-around', marginVertical:10 }}>
            {['MAIN','SECONDARY','PEDESTRIAN'].map(d => (
              <Button key={d} title={d} onPress={() => setDirection(d)} color={direction===d ? 'blue' : undefined} />
            ))}
          </View>
          <Button title="Save" onPress={save} />
          <Button title="Cancel" onPress={onCancel} />
        </View>
      </View>
    </Modal>
  );
}
