import React from 'react';
import { render } from '@testing-library/react-native';

jest.mock('expo-localization');
jest.mock('react-native', () => ({
  SafeAreaView: 'SafeAreaView',
  View: 'View',
  Text: 'Text',
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
}));

import DrivingHUD from '../../components/DrivingHUD';

describe('DrivingHUD', () => {
  it('displays provided props', () => {
    const { getByTestId } = render(
      <DrivingHUD
        maneuver="Turn left"
        distance={100}
        street="Main St"
        eta={60}
        speed={30}
        speedLimit={50}
      />
    );
    expect(getByTestId('hud-maneuver').props.children).toBe('Turn left in 100m');
    expect(getByTestId('hud-street').props.children).toBe('Main St');
    expect(getByTestId('hud-eta').props.children).toBe('ETA: 60s');
    expect(getByTestId('hud-speed-limit').props.children).toBe('Limit: 50');
  });
});
