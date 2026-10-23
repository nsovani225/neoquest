import React from 'react';
import { Platform, StyleProp, Text, TextStyle, View } from 'react-native';
import MaskedView from '@react-native-masked-view/masked-view';
import { LinearGradient } from 'expo-linear-gradient';
import { home } from '../theme';

// The package's class typings predate React 19's JSX types; the component itself works fine.
const Masked = MaskedView as unknown as React.ComponentType<{ maskElement: React.ReactElement; children: React.ReactNode }>;

/**
 * Teal → mint → violet gradient text used for the highlighted words on Home
 * (Figma: bg-gradient-to-r from #2DD4BF via #99F6E4 to #8B5CF6, clipped to text).
 */
export function GradientText({ children, style }: { children: string; style?: StyleProp<TextStyle> }) {
  if (Platform.OS === 'web') {
    return (
      <Text
        style={[
          style,
          {
            // Web-only CSS: paint the gradient and clip it to the letters.
            backgroundImage: `linear-gradient(to right, ${home.gradient[0]}, ${home.gradient[1]}, ${home.gradient[2]})`,
            WebkitBackgroundClip: 'text',
            backgroundClip: 'text',
            color: 'transparent',
          } as unknown as TextStyle,
        ]}
      >
        {children}
      </Text>
    );
  }
  return (
    <Masked maskElement={<Text style={[style, { backgroundColor: 'transparent' }]}>{children}</Text>}>
      <LinearGradient colors={home.gradient} start={{ x: 0, y: 0 }} end={{ x: 1, y: 0 }}>
        <Text style={[style, { opacity: 0 }]}>{children}</Text>
      </LinearGradient>
    </Masked>
  );
}

type Part = string | { g: string };

/**
 * A line of display text mixing plain white words and gradient words, e.g.
 * <MixedLine parts={['Discover the ', { g: 'story' }]} />. Plain words wrap individually;
 * a gradient phrase stays together.
 */
export function MixedLine({ parts, style, color = '#FFFFFF', center }: { parts: Part[]; style: StyleProp<TextStyle>; color?: string; center?: boolean }) {
  const pieces = parts.flatMap((p, i) => {
    if (typeof p === 'string') {
      return p
        .split(/(\s+)/)
        .filter(Boolean)
        .map((w, j) => (/^\s+$/.test(w) ? <Text key={`${i}-${j}`} style={[style, { color }]}>{' '}</Text> : <Text key={`${i}-${j}`} style={[style, { color }]}>{w}</Text>));
    }
    // Keep a gradient phrase in one piece so the gradient runs across it, as in Figma.
    return [<GradientText key={`${i}-g`} style={style}>{p.g}</GradientText>];
  });
  return (
    <View style={{ flexDirection: 'row', flexWrap: 'wrap', alignItems: 'flex-end', justifyContent: center ? 'center' : 'flex-start' }}>
      {pieces}
    </View>
  );
}
