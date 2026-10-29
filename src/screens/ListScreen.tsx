import React, { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { countActive, emptyFilters } from '../data';
import { useFilters } from '../FiltersContext';
import { font, list } from '../theme';
import { useWide } from '../components/ui';
import { ActivityCard } from '../components/ActivityCard';
import { ActivityMap } from '../components/ActivityMap';
import type { ScreenProps } from '../navigation';

export default function ListScreen({ navigation }: ScreenProps<'List'>) {
  const { wide } = useWide();
  const { results, applied, setApplied } = useFilters();
  const [selected, setSelected] = useState<number | undefined>();
  const active = countActive(applied);

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: list.bg }} edges={['top']}>
      <ScrollView contentContainerStyle={{ paddingHorizontal: wide ? 28 : 16, paddingBottom: 60 }}>
        <View style={{ width: '100%', maxWidth: 1224, alignSelf: 'center' }}>
          <Pressable accessibilityRole="link" onPress={() => navigation.navigate('Home')} style={{ paddingTop: wide ? 50 : 20, alignSelf: 'flex-start' }}>
            <Text style={styles.brand}>neoquest</Text>
          </Pressable>

          <Pressable accessibilityRole="link" onPress={() => (navigation.canGoBack() ? navigation.goBack() : navigation.navigate('Home'))} style={{ marginTop: 23, alignSelf: 'flex-start' }}>
            <Text style={styles.back}>← Back to activities</Text>
          </Pressable>
          <Text style={[styles.h1, !wide && { fontSize: 34, lineHeight: 36 }]}>Activity Options</Text>
          <Text style={styles.sub}>Here are some options that could make a great side quest.</Text>

          <View style={{ flexDirection: 'row', gap: 9, marginTop: 23 }}>
            <Pressable accessibilityRole="button" onPress={() => navigation.navigate('Filters')} style={[styles.filterBtn, active > 0 && { backgroundColor: list.ink, borderColor: list.ink }]}>
              <Text style={[styles.filterText, active > 0 && { color: '#FFFFFF' }]}>{active > 0 ? `Filters · ${active}` : 'Filters'}</Text>
            </Pressable>
            {!wide && (
              <Pressable accessibilityRole="button" onPress={() => navigation.navigate('Map', { focusId: selected })} style={styles.filterBtn}>
                <Text style={styles.filterText}>Map</Text>
              </Pressable>
            )}
          </View>

          <View style={styles.info}>
            <Text style={styles.infoText}>
              {results.length} {results.length === 1 ? 'option' : 'options'} nearby
            </Text>
            <Text style={styles.infoText}>{active > 0 ? `${active} ${active === 1 ? 'filter' : 'filters'} applied` : 'Showing all options'}</Text>
          </View>

          <View style={{ flexDirection: 'row', gap: 25, marginTop: wide ? 8 : 12, alignItems: 'flex-start' }}>
            <View style={{ flex: 1, maxWidth: wide ? 754 : undefined, gap: 12 }}>
              {results.map((a) => (
                <ActivityCard key={a.id} a={a} selected={selected === a.id} onPress={() => setSelected(a.id)} onView={() => navigation.navigate('Activity', { id: a.id })} />
              ))}
              {results.length === 0 && (
                <View style={styles.empty}>
                  <Text style={styles.emptyTitle}>No options match these filters</Text>
                  <Pressable accessibilityRole="button" onPress={() => setApplied(emptyFilters())} style={[styles.filterBtn, { marginTop: 14 }]}>
                    <Text style={styles.filterText}>Clear filters</Text>
                  </Pressable>
                </View>
              )}
            </View>
            {wide && <ActivityMap items={results} selectedId={selected} onSelect={setSelected} width={365} height={570} />}
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  brand: { fontFamily: font.interBold, fontSize: 25, letterSpacing: -1, color: list.ink },
  back: { fontFamily: font.inter, fontSize: 14, color: list.muted },
  h1: { fontFamily: font.interBold, fontSize: 44, lineHeight: 44, letterSpacing: -2, color: list.ink, marginTop: 18 },
  sub: { fontFamily: font.inter, fontSize: 16, color: list.subtle, marginTop: 11 },
  filterBtn: { backgroundColor: '#FFFFFF', borderWidth: 1, borderColor: list.border, borderRadius: 999, height: 38.5, paddingHorizontal: 24, justifyContent: 'center' },
  filterText: { fontFamily: font.inter, fontSize: 14, color: '#333333' },
  info: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 18 },
  infoText: { fontFamily: font.inter, fontSize: 13, color: list.faint },
  empty: { backgroundColor: '#FFFFFF', borderWidth: 1, borderColor: list.border, borderRadius: 18, padding: 28, alignItems: 'center' },
  emptyTitle: { fontFamily: font.interBold, fontSize: 16, color: list.ink },
});
