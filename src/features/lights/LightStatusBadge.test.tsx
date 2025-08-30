import React from 'react';
import { render, act } from '@testing-library/react-native';

jest.mock('../../services/traffic/lights', () => ({
  getUpcomingPhase: jest.fn(),
}));

import { LightStatusBadge } from './LightStatusBadge';
import { getUpcomingPhase } from '../../services/traffic/lights';

jest.mock('react-native', () => ({
  View: 'View',
  Text: 'Text',
  StyleSheet: { create: () => ({}), flatten: (s: unknown) => s },
}));
const mocked = getUpcomingPhase as jest.MockedFunction<typeof getUpcomingPhase>;

test('shows countdown and switches to next phase', async () => {
  mocked
    .mockResolvedValueOnce({ direction: 'MAIN', startIn: 2 })
    .mockResolvedValueOnce({ direction: 'SECONDARY', startIn: 3 })
    .mockResolvedValueOnce({ direction: 'PEDESTRIAN', startIn: 4 });

  jest.useFakeTimers();
  const { getByText } = render(<LightStatusBadge lightId="1" />);

  await act(async () => {
    await Promise.resolve();
  });
  expect(getByText('🟢 2s')).toBeTruthy();

  await act(async () => {
    jest.advanceTimersByTime(2000);
  });
  expect(getByText('🟡 3s')).toBeTruthy();
  jest.useRealTimers();
});
