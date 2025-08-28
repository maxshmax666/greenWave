import React from 'react';
import type MapView from 'react-native-maps';
import { render } from '@testing-library/react-native';
import type { Light } from '../../domain/types';

jest.mock('react-native', () => ({
  View: 'View',
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
}));

jest.mock('react-native-maps', () => ({
  __esModule: true,
  default: React.forwardRef<unknown, Record<string, unknown>>(
    function MockMapView(props, ref) {
      return React.createElement(
        'MapView',
        { ...props, ref },
        props.children as React.ReactNode,
      );
    },
  ),
  Marker: 'Marker',
  Polyline: 'Polyline',
}));

jest.mock('../../features/navigation/ui/CarMarker', () => 'CarMarker');

import MapViewWrapper from '../MapViewWrapper';

describe('MapViewWrapper', () => {
  it('renders map view', () => {
    const light: Light = {
      id: '1',
      name: '',
      lat: 0,
      lon: 0,
      direction: 'MAIN',
    };
    const mapRef: React.RefObject<MapView> = { current: null };
    const { getByTestId } = render(
      <MapViewWrapper
        mapRef={mapRef}
        car={{ latitude: 0, longitude: 0, heading: 0 }}
        lights={[light]}
        cycles={{}}
        nowSec={0}
        route={null}
        lightsOnRoute={[]}
        onMapPress={() => {}}
        onLongPress={() => {}}
        onUserLocationChange={() => {}}
      />,
    );
    expect(getByTestId('map-view')).toBeTruthy();
  });
});
