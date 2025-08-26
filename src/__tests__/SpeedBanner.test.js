/* @ts-nocheck */
import React from 'react';
import renderer from 'react-test-renderer';

jest.mock('react-native', () => ({
  View: 'View',
  Text: 'Text',
  StyleSheet: { create: () => ({}) },
}));

jest.mock('../../src/i18n', () => ({
  t: () => 'recommendation',
}));

import SpeedBanner from '../../components/SpeedBanner';

describe('SpeedBanner', () => {
  it('renders nothing when speed is zero', () => {
    const tree = renderer.create(
      <SpeedBanner speed={0} nearestDist={100} timeToWindow={10} />
    );
    expect(tree.toJSON()).toBeNull();
  });
});
