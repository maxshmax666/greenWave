import React from 'react';
import { render, fireEvent, act } from '@testing-library/react-native';

jest.mock('react-native', () => ({
  Modal: 'Modal',
  View: 'View',
  Button: 'Button',
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
  Switch: 'Switch',
  Text: 'Text',
  TextInput: 'TextInput',
}));

jest.mock('../../state/theme', () => ({ setTheme: jest.fn(), theme: 'light' }));
const setSpeechEnabled = jest.fn();
jest.mock('../../state/speech', () => ({
  speechEnabled: true,
  setSpeechEnabled: (v: boolean) => setSpeechEnabled(v),
}));
const setLeadTimeSec = jest.fn();
jest.mock('../../state/leadTime', () => ({
  leadTimeSec: 0,
  setLeadTimeSec: (v: number) => setLeadTimeSec(v),
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
    fireEvent.changeText(getByTestId('lead-input'), '7');
    expect(setLeadTimeSec).toHaveBeenCalledWith(7);
  });
});
