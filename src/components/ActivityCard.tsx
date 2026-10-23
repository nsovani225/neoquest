import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { Image } from 'expo-image';
import { img } from '../assets';
import { Activity } from '../data';
import { font, list } from '../theme';
import { useWide } from './ui';

/** Result card from the /list frame. */
export function ActivityCard({
  a,
  selected,
  onPress,
  onView,
}: {
  a: Activity;
  selected?: boolean;
  onPress?: () => void;
  onView: () => void;
}) {
  const { wide } = useWide();
  const photo = wide ? { w: 155, h: 132 } : { w: 104, h: 104 };
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected }}
      onPress={onPress}
      style={[styles.card, selected && { borderColor: list.ink }, { padding: 14, gap: wide ? 17 : 14 }]}
    >
      <View style={[styles.photo, { width: photo.w, height: photo.h }]}>
        <Image source={img.activityPhoto} style={StyleSheet.absoluteFill} contentFit="cover" />
        <Text style={styles.photoLabel} numberOfLines={1}>
          {a.name}
        </Text>
      </View>
      <View style={{ flex: 1, minHeight: wide ? 155 : undefined }}>
        <Text style={styles.tag}>{a.tags.join(' · ')}</Text>
        <Text style={[styles.name, !wide && { fontSize: 18 }]}>{a.name}</Text>
        <Text style={styles.meta}>📍 {a.miles} miles away</Text>
        <Text style={styles.meta}>
          ⭐ {a.rating} · {a.vibe}
        </Text>
        <Text style={styles.meta}>⏱ {a.durationLabel}</Text>
        <View style={styles.bottom}>
          <Text style={styles.price}>{a.price}</Text>
          <Pressable accessibilityRole="button" onPress={onView} style={({ pressed }) => [styles.view, pressed && { opacity: 0.85 }]}>
            <Text style={styles.viewText}>View option →</Text>
          </Pressable>
        </View>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: { flexDirection: 'row', backgroundColor: '#FFFFFF', borderWidth: 1, borderColor: list.border, borderRadius: 18 },
  photo: { borderRadius: 13, overflow: 'hidden', justifyContent: 'flex-end', padding: 10 },
  photoLabel: { fontFamily: font.inter, fontSize: 11, color: list.muted },
  tag: { fontFamily: font.interBold, fontSize: 10, letterSpacing: 1, textTransform: 'uppercase', color: list.faint, marginTop: 3 },
  name: { fontFamily: font.interBold, fontSize: 20, letterSpacing: -0.5, color: list.ink, marginTop: 5, marginBottom: 6 },
  meta: { fontFamily: font.inter, fontSize: 13, lineHeight: 21.45, color: list.muted },
  bottom: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 'auto', paddingTop: 6 },
  price: { fontFamily: font.interBold, fontSize: 13, color: list.ink },
  view: { backgroundColor: list.ink, borderRadius: 999, height: 32, paddingHorizontal: 14, justifyContent: 'center' },
  viewText: { fontFamily: font.interBold, fontSize: 12, color: '#FFFFFF' },
});
