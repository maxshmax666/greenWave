import React from 'react';
import { View, StyleSheet, ViewProps } from 'react-native';
import { spacing, radius, colors } from '../../styles/tokens';
import { theme } from '../../state/theme';

export default function Card({ style, ...rest }: ViewProps) {
  const themeColors = colors[theme];
  return (
    <View
      {...rest}
      style={[styles.card, { backgroundColor: themeColors.card }, style]}
    />
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: radius.md,
    padding: spacing.md,
  },
});
