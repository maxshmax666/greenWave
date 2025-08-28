import React, { useEffect, useRef, useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import MapView from 'react-native-maps';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Camera, CameraType } from 'expo-camera';
import { detectTrafficLight, TrafficLightDetection } from '../trafficLightDetector';
import { uploadCycle } from '../../../services/uploadLightData';
import { finalizePhase, ColorPhase } from '../services/colorPhases';
import LightFormModal from './LightFormModal';
import { supabase } from '../../../services/supabase';

const CameraScreen: React.FC = () => {
  const [hasPermission, setHasPermission] = useState<boolean | null>(null);
  const [isRecording, setIsRecording] = useState(false);
  const [detection, setDetection] = useState<TrafficLightDetection | null>(null);
  const [currentColor, setCurrentColor] = useState<string | null>(null);
  const [colorStartTime, setColorStartTime] = useState<number | null>(null);
  const [lightModal, setLightModal] = useState<{ latitude: number; longitude: number } | null>(null);
  const [selectedLight, setSelectedLight] = useState<{ id: number; lat: number; lon: number } | null>(null);
  const cameraRef = useRef<Camera | null>(null);
  const colorTimeline = useRef<ColorPhase[]>([]);

  useEffect(() => {
    (async () => {
      const { status } = await Camera.requestCameraPermissionsAsync();
      setHasPermission(status === 'granted');
    })();
  }, []);

  useEffect(() => {
    let interval: NodeJS.Timeout | null = null;
    if (isRecording) {
      interval = setInterval(async () => {
        if (!cameraRef.current) return;
        try {
          const photo = await cameraRef.current.takePictureAsync({ skipProcessing: true, base64: true });
          const result = await detectTrafficLight(photo);
          setDetection(result);
          if (result.color && result.color !== currentColor) {
            const now = Date.now();
            finalizePhase(colorTimeline.current, currentColor, colorStartTime, now);
            setCurrentColor(result.color);
            setColorStartTime(now);
          }
        } catch (e) {
          console.warn('Capture failed', e);
        }
      }, 1000);
    }
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isRecording]);

  if (!selectedLight) {
    return (
      <View style={styles.container}>
        <MapView
          style={styles.map}
          onLongPress={e => setLightModal(e.nativeEvent.coordinate)}
        />
        {lightModal && (
          <LightFormModal
            visible={!!lightModal}
            coordinate={lightModal}
            onSubmit={async data => {
              const { data: inserted, error } = await supabase
                .from('lights')
                .insert({ name: data.name, direction: data.direction, lat: data.lat, lon: data.lon })
                .select()
                .single();
              if (!error && inserted) {
                setSelectedLight({ id: inserted.id, lat: inserted.lat, lon: inserted.lon });
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
            Box: {detection.boundingBox.x.toFixed(2)},{detection.boundingBox.y.toFixed(2)}
          </Text>
        </View>
      )}
      <TouchableOpacity
        style={[styles.button, isRecording ? styles.buttonStop : null]}
        onPress={async () => {
          if (isRecording) {
            setIsRecording(false);
            const end = Date.now();
            finalizePhase(colorTimeline.current, currentColor, colorStartTime, end);
            try {
              await AsyncStorage.setItem('colorPhases', JSON.stringify(colorTimeline.current));
            } catch (e) {
              console.warn('Saving phases failed', e);
            }
            if (selectedLight) {
              try {
                await uploadCycle(
                  selectedLight.id,
                  selectedLight.lat,
                  selectedLight.lon,
                  colorTimeline.current,
                );
              } catch (e) {
                console.warn('Uploading cycle failed', e);
              }
            }
            colorTimeline.current = [];
            setCurrentColor(null);
            setColorStartTime(null);
          } else {
            colorTimeline.current = [];
            setCurrentColor(null);
            setColorStartTime(null);
            setIsRecording(true);
          }
        }}
      >
        <Text style={styles.buttonText}>{isRecording ? 'Stop' : 'Start'}</Text>
      </TouchableOpacity>
    </View>
  );
};

export default CameraScreen;

const styles = StyleSheet.create({
  container: { flex: 1 },
  map: { flex: 1 },
  camera: { flex: 1 },
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  button: {
    position: 'absolute',
    bottom: 40,
    alignSelf: 'center',
    backgroundColor: '#4CAF50',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 25,
  },
  buttonStop: {
    backgroundColor: '#E53935',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
  },
  result: {
    position: 'absolute',
    top: 40,
    left: 20,
    backgroundColor: 'rgba(0,0,0,0.6)',
    padding: 10,
    borderRadius: 8,
  },
  resultText: {
    color: 'white',
  },
});
