import React from 'react';
import { render, fireEvent, act } from '@testing-library/react-native';

jest.mock('react-native', () => ({
  Modal: 'Modal',
  View: 'View',
  Button: 'Button',
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
  Switch: 'Switch',
  Text: 'Text',
}));

jest.mock('../../state/theme', () => ({ setTheme: jest.fn(), theme: 'light' }));
const setSpeechEnabled = jest.fn();
jest.mock('../../state/speech', () => ({
  speechEnabled: true,
  setSpeechEnabled: (v: boolean) => setSpeechEnabled(v),
}));

import Settings from '../Settings';

describe('Settings', () => {
  it('toggles theme and speech', async () => {
    const onTheme = jest.fn();
    const { getByTestId } = render(
      <Settings visible onClose={() => {}} onTheme={onTheme} />,
    );
    await act(async () => {
      fireEvent(getByTestId('theme-toggle'), 'valueChange', true);
    });
    expect(onTheme).toHaveBeenCalledWith('dark');
    fireEvent(getByTestId('speech-toggle'), 'valueChange', false);
    expect(setSpeechEnabled).toHaveBeenCalledWith(false);
  });
});
