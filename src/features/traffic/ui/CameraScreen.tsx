import React, { useEffect, useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import MapView from 'react-native-maps';
import { Camera, CameraType } from 'expo-camera';
import LightFormModal from './LightFormModal';
import useLightDetector from '../hooks/useLightDetector';
import { supabase } from '../../../services/supabase';

const BUTTON_BG = '#4CAF50';
const BUTTON_STOP_BG = '#E53935';
const RESULT_BG = 'rgba(0,0,0,0.6)';
const TEXT_COLOR = '#fff';

const CameraScreen: React.FC = () => {
  const [hasPermission, setHasPermission] = useState<boolean | null>(null);
  const [lightModal, setLightModal] = useState<{
    latitude: number;
    longitude: number;
  } | null>(null);
  const [selectedLight, setSelectedLight] = useState<{
    id: number;
    lat: number;
    lon: number;
  } | null>(null);
  const { cameraRef, detection, isRecording, toggleRecording } =
    useLightDetector(selectedLight);

  useEffect(() => {
    (async () => {
      const { status } = await Camera.requestCameraPermissionsAsync();
      setHasPermission(status === 'granted');
    })();
  }, []);

  if (!selectedLight) {
    return (
      <View style={styles.container}>
        <MapView
          style={styles.map}
          onLongPress={(e) => setLightModal(e.nativeEvent.coordinate)}
        />
        {lightModal && (
          <LightFormModal
            visible={!!lightModal}
            coordinate={lightModal}
            onSubmit={async (data) => {
              const { data: inserted, error } = await supabase
                .from('lights')
                .insert({
                  name: data.name,
                  direction: data.direction,
                  lat: data.lat,
                  lon: data.lon,
                })
                .select()
                .single();
              if (!error && inserted) {
                setSelectedLight({
                  id: inserted.id,
                  lat: inserted.lat,
                  lon: inserted.lon,
                });
                setLightModal(null);
              }
            }}
            onCancel={() => setLightModal(null)}
          />
        )}
      </View>
    );
  }

  if (hasPermission === null) {
    return (
      <View style={styles.centered}>
        <Text>Requesting camera permission...</Text>
      </View>
    );
  }

  if (hasPermission === false) {
    return (
      <View style={styles.centered}>
        <Text>No access to camera</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Camera style={styles.camera} type={CameraType.back} ref={cameraRef} />
      {detection && (
        <View style={styles.result}>
          <Text style={styles.resultText}>Color: {detection.color}</Text>
          <Text style={styles.resultText}>
            Box: {detection.boundingBox.x.toFixed(2)},
            {detection.boundingBox.y.toFixed(2)}
          </Text>
        </View>
      )}
      <TouchableOpacity
        style={[styles.button, isRecording ? styles.buttonStop : null]}
        onPress={toggleRecording}
      >
        <Text style={styles.buttonText}>{isRecording ? 'Stop' : 'Start'}</Text>
      </TouchableOpacity>
    </View>
  );
};

export default CameraScreen;

const styles = StyleSheet.create({
  button: {
    alignSelf: 'center',
    backgroundColor: BUTTON_BG,
    borderRadius: 25,
    bottom: 40,
    paddingHorizontal: 20,
    paddingVertical: 10,
    position: 'absolute',
  },
  buttonStop: {
    backgroundColor: BUTTON_STOP_BG,
  },
  buttonText: {
    color: TEXT_COLOR,
    fontSize: 16,
  },
  camera: { flex: 1 },
  centered: { alignItems: 'center', flex: 1, justifyContent: 'center' },
  container: { flex: 1 },
  map: { flex: 1 },
  result: {
    backgroundColor: RESULT_BG,
    borderRadius: 8,
    left: 20,
    padding: 10,
    position: 'absolute',
    top: 40,
  },
  resultText: {
    color: TEXT_COLOR,
  },
});
