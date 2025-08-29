import React from 'react';
import { render, waitFor } from '@testing-library/react-native';

jest.mock('expo-localization');
jest.mock('react-native', () => ({
  SafeAreaView: 'SafeAreaView',
  View: 'View',
  Text: 'Text',
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
}));
jest.mock('../../../../premium/subscription', () => ({
  usePremium: () => ({ isPremium: true }),
}));
jest.mock('expo-speech');
const speechState = { speechEnabled: true };
jest.mock('../../../../state/speech', () => speechState);
import * as Speech from 'expo-speech';

import DrivingHUD from '../DrivingHUD';

describe('DrivingHUD', () => {
  beforeEach(() => {
    speechState.speechEnabled = true;
    (Speech.speak as jest.Mock).mockClear();
  });

  it('displays provided props', () => {
    const { getByTestId } = render(
      <DrivingHUD
        maneuver="Turn left"
        distance={100}
        street="Main St"
        eta={60}
        speed={30}
        speedLimit={50}
      />,
    );
    expect(getByTestId('hud-maneuver').props.children).toBe(
      'Turn left in 100 m',
    );
    expect(getByTestId('hud-street').props.children).toBe('Main St');
    expect(getByTestId('hud-eta').props.children).toBe('ETA: 60s');
    expect(getByTestId('hud-speed-limit').props.children).toBe('Limit: 50');
  });

  it('speaks maneuver when enabled', async () => {
    render(
      <DrivingHUD
        maneuver="Turn left"
        distance={100}
        street=""
        eta={0}
        speed={0}
      />,
    );
    await waitFor(() =>
      expect(Speech.speak).toHaveBeenCalledWith('Turn left in 100 m'),
    );
  });

  it('speaks when speech setting toggles on', async () => {
    speechState.speechEnabled = false;
    const { rerender } = render(
      <DrivingHUD
        maneuver="Turn left"
        distance={100}
        street=""
        eta={0}
        speed={0}
      />,
    );
    expect(Speech.speak).not.toHaveBeenCalled();

    speechState.speechEnabled = true;
    rerender(
      <DrivingHUD
        maneuver="Turn left"
        distance={100}
        street=""
        eta={0}
        speed={0}
      />,
    );

    await waitFor(() =>
      expect(Speech.speak).toHaveBeenCalledWith('Turn left in 100 m'),
    );
  });

  it('calls Speech.speak once when speechEnabled goes from false to true', async () => {
    speechState.speechEnabled = false;
    const { rerender } = render(
      <DrivingHUD
        maneuver="Turn left"
        distance={100}
        street=""
        eta={0}
        speed={0}
      />,
    );
    expect(Speech.speak).not.toHaveBeenCalled();

    speechState.speechEnabled = true;
    rerender(
      <DrivingHUD
        maneuver="Turn left"
        distance={100}
        street=""
        eta={0}
        speed={0}
      />,
    );

    await waitFor(() => {
      expect(Speech.speak).toHaveBeenCalledTimes(1);
      expect(Speech.speak).toHaveBeenCalledWith('Turn left in 100 m');
    });
  });
});
