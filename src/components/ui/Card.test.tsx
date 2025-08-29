import React from 'react';

jest.mock('react-native', () => ({
  View: 'View',
  StyleSheet: { create: (s: unknown) => s, flatten: (s: unknown) => s },
}));

import renderer, { ReactTestRendererJSON } from 'react-test-renderer';
import Card from './Card';

jest.mock('../../state/theme', () => ({ theme: 'light' }));

it('applies padding and radius', () => {
  const tree = renderer.create(<Card />).toJSON() as ReactTestRendererJSON;
  const style = Array.isArray(tree.props.style)
    ? Object.assign({}, ...(tree.props.style as object[]))
    : (tree.props.style as Record<string, unknown>);
  expect(style.padding).toBe(16);
  expect(style.borderRadius).toBe(8);
});
