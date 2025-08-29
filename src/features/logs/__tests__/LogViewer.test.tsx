import React from 'react';
import { render } from '@testing-library/react-native';

jest.mock('expo-file-system', () => ({
  readAsStringAsync: jest.fn().mockResolvedValue('a\nb'),
}));

jest.mock('react-native', () => ({
  Modal: 'Modal',
  View: 'View',
  ScrollView: 'ScrollView',
  Text: 'Text',
  Button: ({ title, onPress }: { title: string; onPress: () => void }) =>
    React.createElement('Text', { onPress }, title),
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
}));

import LogViewer from '../LogViewer';

describe('LogViewer', () => {
  it('renders log lines', async () => {
    const { findByText } = render(<LogViewer visible onClose={() => {}} />);
    expect(await findByText('a')).toBeTruthy();
    expect(await findByText('b')).toBeTruthy();
  });
});
