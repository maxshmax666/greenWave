import React from 'react';
import { render } from '@testing-library/react-native';

jest.mock('expo-localization');
jest.mock('react-native', () => ({
  View: 'View',
  Text: 'Text',
  TouchableOpacity: 'TouchableOpacity',
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
}));

import MainMenu from '../components/MainMenu';

describe('MainMenu', () => {
  const noop = jest.fn();

  it('renders when visible', () => {
    const { getByTestId, getByText } = render(
      <MainMenu
        visible
        onStartNavigation={noop}
        onClearRoute={noop}
        onAddLight={noop}
        onSettings={noop}
      />
    );
    expect(getByTestId('main-menu')).toBeTruthy();
    expect(getByText('Start Navigation')).toBeTruthy();
  });

  it('returns null when not visible', () => {
    const { queryByTestId } = render(
      <MainMenu
        visible={false}
        onStartNavigation={noop}
        onClearRoute={noop}
        onAddLight={noop}
        onSettings={noop}
      />
    );
    expect(queryByTestId('main-menu')).toBeNull();
  });
});
