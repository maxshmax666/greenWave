import React from 'react';
import { render } from '@testing-library/react-native';

jest.mock('expo-localization');
jest.mock('react-native', () => ({
  View: 'View',
  Text: 'Text',
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
}));

jest.mock('react-native-maps', () => {
  const React = require('react');
  const { View } = require('react-native');
  const Marker = ({ children, ...props }: any) => <View {...props}>{children}</View>;
  return { Marker };
});

jest.mock('react-native-svg', () => {
  const React = require('react');
  const { View } = require('react-native');
  const Svg = ({ children, ...props }: any) => <View {...props}>{children}</View>;
  const Path = (props: any) => <View {...props} />;
  return { __esModule: true, default: Svg, Path };
});

import CarMarker from '../../components/CarMarker';

describe('CarMarker', () => {
  it('renders marker with rotation', () => {
    const { toJSON } = render(
      <CarMarker coordinate={{ latitude: 1, longitude: 2 }} heading={45} />
    );
    const tree: any = toJSON();
    expect(tree).not.toBeNull();
    expect(tree.props.coordinate).toEqual({ latitude: 1, longitude: 2 });
    const svg = tree.children[0];
    expect(svg.props.style.transform[0].rotate).toBe('45deg');
  });

  it('returns null without coordinate', () => {
    const { toJSON } = render(<CarMarker />);
    expect(toJSON()).toBeNull();
  });
});
