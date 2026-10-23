import React from 'react';
import { Pressable, StyleProp, Text, TextStyle, useWindowDimensions, View, ViewStyle } from 'react-native';
import { Image } from 'expo-image';
import { font, home, WIDE } from '../theme';

export function useWide() {
  const { width } = useWindowDimensions();
  return { wide: width >= WIDE, width };
}

/** Rounded pill button from the Home frame ("Button" / "Button linkout" components). */
export function Pill({
  label,
  onPress,
  bg = home.accent,
  color = '#000000',
  arrow,
  style,
}: {
  label: string;
  onPress?: () => void;
  bg?: string;
  color?: string;
  arrow?: number; // image source for the ↗ arrow
  style?: StyleProp<ViewStyle>;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      onPress={onPress}
      style={({ pressed }) => [
        {
          backgroundColor: bg,
          borderRadius: 1000,
          paddingHorizontal: 22,
          paddingVertical: 14,
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 2,
          opacity: pressed ? 0.85 : 1,
        },
        style,
      ]}
    >
      <Text style={{ fontFamily: font.sansBold, fontSize: 14, lineHeight: 19.6, letterSpacing: -0.35, color, textAlign: 'center' }}>
        {label}
      </Text>
      {arrow != null && (
        <View style={{ width: 7, alignItems: 'center' }}>
          <Image source={arrow} style={{ width: 6, height: 6.011 }} />
        </View>
      )}
    </Pressable>
  );
}

export function T({ style, children, ...rest }: React.ComponentProps<typeof Text> & { style?: StyleProp<TextStyle> }) {
  return (
    <Text {...rest} style={style}>
      {children}
    </Text>
  );
}
