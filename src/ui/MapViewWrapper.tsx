import React from 'react';
import { StyleSheet } from 'react-native';
import MapView, {
  Marker,
  Polyline,
  MapPressEvent,
  LongPressEvent,
  UserLocationChangeEvent,
  LatLng,
} from 'react-native-maps';
import CarMarker from '../features/navigation/ui/CarMarker';
import { mapColorForRuntime } from '../features/navigation/phases';
import type { Light, LightCycle } from '../domain/types';
import type { LightOnRoute } from '../features/navigation';

interface Props {
  mapRef: React.RefObject<MapView>;
  car: { latitude: number; longitude: number; heading: number } | null;
  lights: Light[];
  cycles: Record<string, LightCycle>;
  nowSec: number;
  route: LatLng[] | null;
  lightsOnRoute: LightOnRoute[];
  onMapPress: (e: MapPressEvent) => void;
  onLongPress: (e: LongPressEvent) => void;
  onUserLocationChange: (e: UserLocationChangeEvent) => void;
}

export default function MapViewWrapper({
  mapRef,
  car,
  lights,
  cycles,
  nowSec,
  route,
  lightsOnRoute,
  onMapPress,
  onLongPress,
  onUserLocationChange,
}: Props): JSX.Element {
  return (
    <MapView
      ref={mapRef}
      testID="map-view"
      style={styles.map}
      showsUserLocation
      onPress={onMapPress}
      onLongPress={onLongPress}
      onUserLocationChange={onUserLocationChange}
      customMapStyle={nightStyle}
    >
      {car && <CarMarker coordinate={car} heading={car.heading} />}
      {lights.map((l) => {
        const cycle = cycles[l.id];
        const color = mapColorForRuntime(cycle ?? null, l.direction, nowSec);
        const isNearest =
          lightsOnRoute.length && lightsOnRoute[0].light.id === l.id;
        return (
          <Marker
            key={l.id}
            coordinate={{ latitude: l.lat, longitude: l.lon }}
            pinColor={isNearest ? 'yellow' : color}
          />
        );
      })}
      {route && (
        <Polyline coordinates={route} strokeColor="yellow" strokeWidth={3} />
      )}
    </MapView>
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
    stylers: [{ color: '#484848' }],
  },
  {
    featureType: 'water',
    elementType: 'geometry',
    stylers: [{ color: '#000000' }],
  },
];

const styles = StyleSheet.create({
  map: { flex: 1 },
});
