import React from 'react';
import { render } from '@testing-library/react-native';

jest.mock('../MainMenu', () => 'MainMenu');
jest.mock('react-native', () => ({
  TouchableOpacity: 'TouchableOpacity',
  Text: 'Text',
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
}));

import MenuContainer from '../MenuContainer';

describe('MenuContainer', () => {
  const noop = jest.fn();

  it('renders menu button', () => {
    const { getByTestId } = render(
      <MenuContainer
        visible
        onToggle={noop}
        onStartNavigation={noop}
        onClearRoute={noop}
        onAddLight={noop}
        onLogs={noop}
        onSettings={noop}
      />,
    );
    expect(getByTestId('menu-button')).toBeTruthy();
  });
});
