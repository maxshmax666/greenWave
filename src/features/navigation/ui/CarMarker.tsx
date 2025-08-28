import React from 'react';
import { Marker, LatLng } from 'react-native-maps';
import Svg, { Path } from 'react-native-svg';

export interface CarMarkerProps {
  coordinate?: LatLng;
  heading?: number;
}

export default function CarMarker({ coordinate, heading = 0 }: CarMarkerProps) {
  if (!coordinate) return null;
  return (
    <Marker coordinate={coordinate} anchor={{ x: 0.5, y: 0.5 }}>
      <Svg
        width={40}
        height={40}
        viewBox="0 0 24 24"
        style={{ transform: [{ rotate: `${heading}deg` }] }}
      >
        <Path d="M12 2l5 9H7l5-9zm-5 11h10l-5 9-5-9z" fill="#2ecc71" />
      </Svg>
    </Marker>
  );
}
