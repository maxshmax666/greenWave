import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';

jest.mock('expo-localization');
jest.mock('react-native', () => {
  const React = require('react');
  return {
    Modal: 'Modal',
    View: 'View',
    Text: 'Text',
    TextInput: 'TextInput',
    Button: ({ title, onPress, disabled }: any) =>
      React.createElement('Text', { onPress, disabled }, title),
    Alert: { alert: jest.fn() },
    StyleSheet: { create: () => ({}), flatten: () => ({}) },
  };
});

import LightFormModal from '../LightFormModal';

describe('LightFormModal', () => {
  it('submits when name provided', () => {
    const onSubmit = jest.fn();
    const { getByText, getByDisplayValue } = render(
      <LightFormModal
        visible
        coordinate={{ latitude: 1, longitude: 2 }}
        onSubmit={onSubmit}
        onCancel={jest.fn()}
      />
    );
    const input = getByDisplayValue('');
    fireEvent.changeText(input, 'Test');
    fireEvent.press(getByText('Save'));
    expect(onSubmit).toHaveBeenCalledWith({
      name: 'Test',
      direction: 'MAIN',
      lat: 1,
      lon: 2,
    });
  });
});
