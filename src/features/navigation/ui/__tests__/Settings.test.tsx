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

jest.mock('../../../../state/theme', () => ({
  setTheme: jest.fn(),
  theme: 'light',
}));
const setSpeechEnabled = jest.fn();
jest.mock('../../../../state/speech', () => ({
  speechEnabled: true,
  setSpeechEnabled: (v: boolean) => setSpeechEnabled(v),
}));
const setLead = jest.fn();
jest.mock('../../../../stores/leadTime', () => ({
  leadTimeStore: {
    get: jest.fn().mockResolvedValue(0),
    set: (v: number) => setLead(v),
  },
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
    await act(async () => {
      fireEvent.changeText(getByTestId('lead-input'), '7');
    });
    expect(setLead).toHaveBeenCalledWith(7);
  });
});
