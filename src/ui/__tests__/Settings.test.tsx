import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';

jest.mock('react-native', () => ({
  Modal: 'Modal',
  View: 'View',
  Button: 'Button',
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
  Switch: 'Switch',
  Text: 'Text',
}));

jest.mock('../../state/theme', () => ({ setColor: jest.fn() }));
const setSpeechEnabled = jest.fn();
jest.mock('../../state/speech', () => ({
  speechEnabled: true,
  setSpeechEnabled: (v: boolean) => setSpeechEnabled(v),
}));

import Settings from '../Settings';

describe('Settings', () => {
  it('toggles speech', () => {
    const { getByTestId } = render(
      <Settings visible onClose={() => {}} onColor={() => {}} />,
    );
    fireEvent(getByTestId('speech-toggle'), 'valueChange', false);
    expect(setSpeechEnabled).toHaveBeenCalledWith(false);
  });
});
