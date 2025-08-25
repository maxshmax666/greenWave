import React, { useRef, useState } from 'react';
import { StyleSheet, View } from 'react-native';
import MapView from 'react-native-maps';
import CarMarker from './components/CarMarker';
import DrivingHUD from './components/DrivingHUD';

export default function App() {
  const mapRef = useRef(null);
  const [car, setCar] = useState(null);

  const onUserLocationChange = (e) => {
    const { coordinate } = e.nativeEvent;
    const { latitude, longitude, heading } = coordinate;
    setCar({ latitude, longitude, heading });
    mapRef.current?.animateCamera({ center: { latitude, longitude } });
  };

  return (
    <View style={styles.container}>
      <MapView
        ref={mapRef}
        style={styles.map}
        showsUserLocation
        onUserLocationChange={onUserLocationChange}
        customMapStyle={nightStyle}
      >
        {car && <CarMarker coordinate={car} heading={car.heading} />}
      </MapView>
      <DrivingHUD />
    </View>
  );
}

const nightStyle = [
  { elementType: 'geometry', stylers: [{ color: '#212121' }] },
  { elementType: 'labels.icon', stylers: [{ visibility: 'off' }] },
  { elementType: 'labels.text.fill', stylers: [{ color: '#757575' }] },
  { elementType: 'labels.text.stroke', stylers: [{ color: '#212121' }] },
  {
    featureType: 'road',
    elementType: 'geometry',
    stylers: [{ color: '#484848' }]
  },
  {
    featureType: 'water',
    elementType: 'geometry',
    stylers: [{ color: '#000000' }]
  }
];

const styles = StyleSheet.create({
  container: { flex: 1 },
  map: { flex: 1 }
});
