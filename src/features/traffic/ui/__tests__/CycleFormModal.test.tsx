import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';

jest.mock('expo-localization');
jest.mock('react-native', () => ({
  Modal: 'Modal',
  View: 'View',
  Text: 'Text',
  TextInput: 'TextInput',
  Button: ({
    title,
    onPress,
    disabled,
  }: {
    title: string;
    onPress: () => void;
    disabled?: boolean;
  }) => React.createElement('Text', { onPress, disabled }, title),
  Alert: { alert: jest.fn() },
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
}));

import CycleFormModal from '../CycleFormModal';

describe('CycleFormModal', () => {
  it('submits default values', () => {
    const onSubmit = jest.fn();
    const { getByText } = render(
      <CycleFormModal visible onSubmit={onSubmit} onCancel={jest.fn()} />,
    );
    fireEvent.press(getByText('Save'));
    expect(onSubmit).toHaveBeenCalledWith({
      cycle_seconds: 60,
      t0_iso: expect.any(String),
      main_green: [0, 10],
      secondary_green: [10, 20],
      ped_green: [20, 30],
    });
  });
});
