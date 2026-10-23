import React, { useState } from 'react';
import { Linking, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useFilters } from '../FiltersContext';
import { font, list } from '../theme';
import { useWide } from '../components/ui';
import { ActivityCard } from '../components/ActivityCard';
import { ActivityMap } from '../components/ActivityMap';
import type { ScreenProps } from '../navigation';

/**
 * Full-screen map. Your /map frame is an empty embed placeholder in Figma, so this screen is
 * built from the map, pins and cards on your /list frame.
 */
export default function MapScreen({ navigation, route }: ScreenProps<'Map'>) {
  const { wide } = useWide();
  const { results } = useFilters();
  const [selected, setSelected] = useState<number | undefined>(route.params?.focusId ?? results[0]?.id);
  const [size, setSize] = useState({ w: 0, h: 0 });
  const current = results.find((a) => a.id === selected);

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: list.bg }} edges={['top']}>
      <View style={[styles.top, { paddingHorizontal: wide ? 28 : 16 }]}>
        <Pressable accessibilityRole="link" onPress={() => navigation.navigate('Home')}>
          <Text style={styles.brand}>neoquest</Text>
        </Pressable>
        <View style={{ flexDirection: 'row', gap: 9 }}>
          <Pressable accessibilityRole="button" onPress={() => navigation.navigate('Filters')} style={styles.btn}>
            <Text style={styles.btnText}>Filters</Text>
          </Pressable>
          <Pressable accessibilityRole="button" onPress={() => navigation.navigate('List')} style={[styles.btn, { backgroundColor: list.ink, borderColor: list.ink }]}>
            <Text style={[styles.btnText, { color: '#FFFFFF' }]}>List view</Text>
          </Pressable>
        </View>
      </View>

      <View style={{ flex: 1, padding: wide ? 28 : 12, paddingTop: 0 }} onLayout={(e) => setSize({ w: e.nativeEvent.layout.width - (wide ? 56 : 24), h: e.nativeEvent.layout.height - (wide ? 28 : 12) })}>
        {size.w > 0 && (
          <ActivityMap
            items={results}
            selectedId={selected}
            onSelect={setSelected}
            width={size.w}
            height={size.h}
            title={results.length ? `${results.length} nearby options · tap a pin` : 'No options match your filters'}
          />
        )}
        {current && (
          <View style={[styles.sheet, { left: wide ? 56 : 24, right: wide ? undefined : 24, width: wide ? 600 : undefined, bottom: wide ? 56 : 24 }]}>
            {/* No detail screen exists in Figma, so "View option" opens directions in Google Maps. */}
            <ActivityCard a={current} selected onView={() => Linking.openURL(`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(current.name)}`)} />
          </View>
        )}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  top: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingVertical: 16 },
  brand: { fontFamily: font.interBold, fontSize: 25, letterSpacing: -1, color: list.ink },
  btn: { backgroundColor: '#FFFFFF', borderWidth: 1, borderColor: list.border, borderRadius: 999, height: 38.5, paddingHorizontal: 20, justifyContent: 'center' },
  btnText: { fontFamily: font.inter, fontSize: 14, color: '#333333' },
  sheet: { position: 'absolute', shadowColor: '#000', shadowOpacity: 0.12, shadowRadius: 18, shadowOffset: { width: 0, height: 8 }, elevation: 6, borderRadius: 18 },
});
