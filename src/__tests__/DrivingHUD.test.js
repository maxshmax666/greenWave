/* @ts-nocheck */
import React from 'react';
import renderer from 'react-test-renderer';

jest.mock('react-native', () => ({
  SafeAreaView: 'SafeAreaView',
  View: 'View',
  Text: 'Text',
  StyleSheet: { create: () => ({}) },
}));

import DrivingHUD from '../../components/DrivingHUD';

describe('DrivingHUD', () => {
  it('displays provided props', () => {
    const tree = renderer.create(
      <DrivingHUD
        maneuver="Turn left"
        distance={100}
        street="Main St"
        eta={60}
        speed={30}
        speedLimit={50}
      />
    );
    const root = tree.root;
    expect(root.findByProps({ testID: 'hud-maneuver' }).props.children).toContain('Turn left');
    expect(root.findByProps({ testID: 'hud-maneuver' }).props.children).toContain('100');
    expect(root.findByProps({ testID: 'hud-street' }).props.children).toBe('Main St');
    const etaText = root.findByProps({ testID: 'hud-eta' }).props.children.join('');
    expect(etaText).toContain('60');
    const limitText = root.findByProps({ testID: 'hud-speed-limit' }).props.children.join('');
    expect(limitText).toContain('50');
  });

  it('renders defaults when no navigation is active', () => {
    const tree = renderer.create(<DrivingHUD speed={0} />);
    const root = tree.root;
    expect(root.findByProps({ testID: 'hud-maneuver' }).props.children).toBe('');
    expect(root.findByProps({ testID: 'hud-street' }).props.children).toBeUndefined();
    const etaText = root.findByProps({ testID: 'hud-eta' }).props.children.join('');
    expect(etaText).toContain('--');
    const limitText = root
      .findByProps({ testID: 'hud-speed-limit' })
      .props.children.join('');
    expect(limitText).toContain('--');
  });
});
