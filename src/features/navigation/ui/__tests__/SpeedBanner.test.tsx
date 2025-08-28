import React from 'react';
import { render } from '@testing-library/react-native';

jest.mock('expo-localization');
jest.mock('react-native', () => ({
  View: 'View',
  Text: 'Text',
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
}));

import SpeedBanner from '../SpeedBanner';

describe('SpeedBanner', () => {
  it('renders recommendation text', () => {
    const { getByText } = render(
      <SpeedBanner speed={30} nearestDist={100} timeToWindow={20} />,
    );
    expect(
      getByText('Recommended 30 km/h • next light in 100 m • window in 20 s'),
    ).toBeTruthy();
  });

  it('returns null when no speed', () => {
    const { toJSON } = render(<SpeedBanner />);
    expect(toJSON()).toBeNull();
  });
});
