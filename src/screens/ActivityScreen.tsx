import React, { useMemo } from 'react';
import { Linking, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { Image } from 'expo-image';
import { SafeAreaView } from 'react-native-safe-area-context';
import { img } from '../assets';
import { activities } from '../data';
import { font, list } from '../theme';
import { useWide } from '../components/ui';
import { GoogleMap } from '../components/GoogleMap';
import type { ScreenProps } from '../navigation';

/** One activity: photo, details and a Google Map centered on its location. */
export default function ActivityScreen({ navigation, route }: ScreenProps<'Activity'>) {
  const { wide } = useWide();
  const a = activities.find((x) => x.id === Number(route.params?.id));
  const items = useMemo(() => (a ? [a] : []), [a]);

  const back = () => (navigation.canGoBack() ? navigation.goBack() : navigation.navigate('List'));

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: list.bg }} edges={['top']}>
      <ScrollView contentContainerStyle={{ paddingHorizontal: wide ? 28 : 16, paddingBottom: 60 }}>
        <View style={{ width: '100%', maxWidth: 1224, alignSelf: 'center' }}>
          <Pressable accessibilityRole="link" onPress={() => navigation.navigate('Home')} style={{ paddingTop: wide ? 50 : 20, alignSelf: 'flex-start' }}>
            <Text style={styles.brand}>neoquest</Text>
          </Pressable>
          <Pressable accessibilityRole="link" onPress={back} style={{ marginTop: 23, alignSelf: 'flex-start' }}>
            <Text style={styles.back}>← Back to activities</Text>
          </Pressable>

          {!a ? (
            <Text style={[styles.h1, { fontSize: 28 }]}>Activity not found</Text>
          ) : (
            <>
              <Text style={styles.tag}>{a.tags.join(' · ')}</Text>
              <Text style={[styles.h1, !wide && { fontSize: 34, lineHeight: 36 }]}>{a.name}</Text>
              <Text style={styles.sub}>
                {a.rating}★ · {a.vibe} · {a.price}
              </Text>

              <View style={{ flexDirection: wide ? 'row' : 'column', gap: 25, marginTop: 28, alignItems: 'flex-start' }}>
                <View style={[styles.mapBox, { width: wide ? 700 : '100%', aspectRatio: wide ? 700 / 480 : 1 }]}>
                  <GoogleMap items={items} selectedId={a.id} infoWindow={false} zoom={15} />
                </View>
                <View style={{ flex: 1, width: wide ? undefined : '100%', gap: 14 }}>
                  <View style={styles.photo}>
                    <Image source={img.activityPhoto} style={StyleSheet.absoluteFill} contentFit="cover" />
                  </View>
                  <View style={styles.facts}>
                    <Text style={styles.meta}>📍 {a.miles} miles away</Text>
                    <Text style={styles.meta}>⏱ {a.durationLabel}</Text>
                    <Text style={styles.meta}>⭐ {a.rating} · {a.vibe}</Text>
                  </View>
                  <Pressable
                    accessibilityRole="button"
                    onPress={() => Linking.openURL(`https://www.google.com/maps/dir/?api=1&destination=${a.coords.lat},${a.coords.lng}`)}
                    style={({ pressed }) => [styles.cta, pressed && { opacity: 0.85 }]}
                  >
                    <Text style={styles.ctaText}>Get directions →</Text>
                  </Pressable>
                  <Pressable accessibilityRole="button" onPress={() => navigation.navigate('Map', { focusId: a.id })} style={styles.secondary}>
                    <Text style={styles.secondaryText}>See on the full map</Text>
                  </Pressable>
                </View>
              </View>
            </>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  brand: { fontFamily: font.interBold, fontSize: 25, letterSpacing: -1, color: list.ink },
  back: { fontFamily: font.inter, fontSize: 14, color: list.muted },
  tag: { fontFamily: font.interBold, fontSize: 11, letterSpacing: 1, textTransform: 'uppercase', color: list.faint, marginTop: 22 },
  h1: { fontFamily: font.interBold, fontSize: 44, lineHeight: 44, letterSpacing: -2, color: list.ink, marginTop: 10 },
  sub: { fontFamily: font.inter, fontSize: 16, color: list.subtle, marginTop: 11 },
  mapBox: { borderRadius: 21, borderWidth: 1, borderColor: list.mapBorder, overflow: 'hidden', backgroundColor: '#E9E9E4' },
  photo: { height: 170, borderRadius: 18, overflow: 'hidden' },
  facts: { backgroundColor: '#FFFFFF', borderWidth: 1, borderColor: list.border, borderRadius: 18, padding: 16, gap: 6 },
  meta: { fontFamily: font.inter, fontSize: 14, color: list.muted },
  cta: { backgroundColor: list.ink, borderRadius: 999, height: 44, justifyContent: 'center', alignItems: 'center' },
  ctaText: { fontFamily: font.interBold, fontSize: 14, color: '#FFFFFF' },
  secondary: { backgroundColor: '#FFFFFF', borderWidth: 1, borderColor: list.border, borderRadius: 999, height: 44, justifyContent: 'center', alignItems: 'center' },
  secondaryText: { fontFamily: font.inter, fontSize: 14, color: '#333333' },
});
