import React from 'react';
import { render } from '@testing-library/react-native';
import { View } from 'react-native';
import type { ReactTestRendererJSON } from 'react-test-renderer';

jest.mock('expo-localization');
jest.mock('react-native', () => ({
  View: 'View',
  Text: 'Text',
  StyleSheet: { create: () => ({}), flatten: () => ({}) },
}));

jest.mock('react-native-maps', () => {
  const Marker = ({
    children,
    ...props
  }: React.ComponentProps<typeof View>) => <View {...props}>{children}</View>;
  return { Marker };
});

jest.mock('react-native-svg', () => {
  const Svg = ({ children, ...props }: React.ComponentProps<typeof View>) => (
    <View {...props}>{children}</View>
  );
  const Path = (props: React.ComponentProps<typeof View>) => (
    <View {...props} />
  );
  return { __esModule: true, default: Svg, Path };
});

import CarMarker from '../CarMarker';

describe('CarMarker', () => {
  it('renders marker with rotation', () => {
    const { toJSON } = render(
      <CarMarker coordinate={{ latitude: 1, longitude: 2 }} heading={45} />,
    );
    const tree = toJSON() as ReactTestRendererJSON | null;
    expect(tree).not.toBeNull();
    if (!tree) return;
    expect(tree.props.coordinate).toEqual({ latitude: 1, longitude: 2 });
    const svg = tree.children?.[0] as ReactTestRendererJSON;
    expect(svg.props.style.transform[0].rotate).toBe('45deg');
  });

  it('returns null without coordinate', () => {
    const { toJSON } = render(<CarMarker />);
    expect(toJSON()).toBeNull();
  });
});
