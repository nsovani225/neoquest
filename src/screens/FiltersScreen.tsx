import React, { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { countActive, emptyFilters, FilterCategory, filterCategories, FilterKey, FilterState } from '../data';
import { useFilters } from '../FiltersContext';
import { filters as c, font } from '../theme';
import { useWide } from '../components/ui';
import type { ScreenProps } from '../navigation';

function SideItem({ cat, value, active, onPress, compact }: { cat: FilterCategory; value: string[]; active: boolean; onPress: () => void; compact?: boolean }) {
  const summary = value.length ? value.join(', ') : cat.anyLabel;
  return (
    <Pressable
      accessibilityRole="tab"
      accessibilityState={{ selected: active }}
      onPress={onPress}
      style={[styles.navItem, active && { backgroundColor: c.dark }, compact && { width: 190, borderWidth: active ? 0 : 1, borderColor: c.border, backgroundColor: active ? c.dark : '#FFFFFF' }]}
    >
      <View style={[styles.navIcon, { backgroundColor: active ? c.lime : c.iconBg }]}>
        <Text style={[styles.navIconText, { color: active ? '#1B1C18' : c.muted2 }]}>{cat.icon}</Text>
      </View>
      <View style={{ flex: 1 }}>
        <Text style={[styles.navLabel, { color: active ? '#FFFFFF' : c.muted2 }]}>{cat.label}</Text>
        <Text style={[styles.navSub, { color: active ? '#C8C9C2' : value.length ? c.ink : c.muted3 }]} numberOfLines={1}>
          {summary}
        </Text>
      </View>
      {!compact && <Text style={[styles.chevron, { color: active ? '#FFFFFF' : c.muted2 }]}>›</Text>}
    </Pressable>
  );
}

function Chip({ label, selected, onPress }: { label: string; selected: boolean; onPress: () => void }) {
  return (
    <Pressable
      accessibilityRole={'checkbox'}
      accessibilityState={{ checked: selected }}
      onPress={onPress}
      style={[styles.chip, selected ? { backgroundColor: c.lime, borderColor: c.lime } : { backgroundColor: '#FFFFFF', borderColor: c.chipBorder }]}
    >
      <Text style={[styles.chipText, { color: selected ? '#1B1C18' : c.chipText }]}>{label}</Text>
    </Pressable>
  );
}

export default function FiltersScreen({ navigation }: ScreenProps<'Filters'>) {
  const { wide } = useWide();
  const { applied, setApplied } = useFilters();
  const [draft, setDraft] = useState<FilterState>(() => JSON.parse(JSON.stringify(applied)));
  const [activeKey, setActiveKey] = useState<FilterKey>('activity');
  const cat = filterCategories.find((f) => f.key === activeKey)!;
  const total = countActive(draft);

  const toggle = (opt: string) =>
    setDraft((d) => {
      const cur = d[activeKey];
      const next = cur.includes(opt) ? cur.filter((o) => o !== opt) : cat.multi ? [...cur, opt] : [opt];
      return { ...d, [activeKey]: next };
    });

  const sideQuestMode = () => {
    // Picks three random activities to get the group started.
    const shuffled = [...filterCategories[0].options].sort(() => Math.random() - 0.5);
    setDraft((d) => ({ ...d, activity: shuffled.slice(0, 3) }));
  };

  const apply = () => {
    setApplied(draft);
    navigation.navigate('List');
  };

  const sidebar = (
    <View style={wide ? styles.sidebar : undefined}>
      {wide && (
        <View style={styles.sideHeading}>
          <Text style={styles.sideHeadingText}>REFINE RESULTS</Text>
          <View style={styles.count}>
            <Text style={styles.countText}>{total}</Text>
          </View>
        </View>
      )}
      {wide ? (
        <View style={{ gap: 4 }}>
          {filterCategories.map((f) => (
            <SideItem key={f.key} cat={f} value={draft[f.key]} active={f.key === activeKey} onPress={() => setActiveKey(f.key)} />
          ))}
        </View>
      ) : (
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 8, paddingHorizontal: 16 }}>
          {filterCategories.map((f) => (
            <SideItem key={f.key} compact cat={f} value={draft[f.key]} active={f.key === activeKey} onPress={() => setActiveKey(f.key)} />
          ))}
        </ScrollView>
      )}
      {wide && (
        <View style={styles.sideFoot}>
          <Text style={styles.sideFootText}>Your filters work together. Add a few constraints to find options that match the whole group.</Text>
        </View>
      )}
    </View>
  );

  const editor = (
    <View style={{ flex: 1, paddingHorizontal: wide ? 34 : 16, paddingTop: wide ? 31 : 20 }}>
      <View style={styles.editorHeader}>
        <View style={{ flexDirection: 'row', gap: 12, flex: 1 }}>
          <View style={styles.editorIcon}>
            <Text style={{ fontFamily: font.inter, fontSize: 20, color: c.ink }}>{cat.icon}</Text>
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.editorTitle}>{cat.label}</Text>
            <Text style={styles.editorDesc}>{cat.description}</Text>
          </View>
        </View>
        {wide && (
          <View style={styles.modeTag}>
            <Text style={styles.modeTagText}>{cat.multi ? 'CHOOSE OPTIONS' : 'CHOOSE ONE'}</Text>
          </View>
        )}
      </View>

      <View style={styles.sectionHeading}>
        <Text style={styles.sectionLeft}>{cat.question.toUpperCase()}</Text>
        <Text style={styles.sectionRight}>{cat.multi ? 'SELECT ALL THAT APPLY' : 'PICK ONE'}</Text>
      </View>
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 9, marginTop: 15 }}>
        {cat.options.map((o) => (
          <Chip key={o} label={o} selected={draft[activeKey].includes(o)} onPress={() => toggle(o)} />
        ))}
      </View>

      {activeKey === 'activity' && (
        <>
          <View style={styles.panel}>
            <View style={styles.panelIcon}>
              <Text style={{ fontFamily: font.inter, fontSize: 16, color: c.ink }}>✦</Text>
            </View>
            <View style={{ flex: 1, maxWidth: 448 }}>
              <Text style={styles.panelTitle}>Keep it flexible</Text>
              <Text style={styles.panelText}>Pick more than one activity to see a wider mix of suggestions. Your group can decide on the exact plan later.</Text>
            </View>
          </View>
          <View style={styles.suggested}>
            <View style={{ flex: 1 }}>
              <Text style={styles.suggestTitle}>Not sure yet?</Text>
              <Text style={styles.suggestText}>Choose a few things your group might enjoy.</Text>
            </View>
            <Pressable accessibilityRole="button" onPress={sideQuestMode} style={styles.suggestPill}>
              <Text style={styles.suggestPillText}>SIDE QUEST MODE</Text>
            </Pressable>
          </View>
        </>
      )}

      <View style={[styles.footer, { flexDirection: wide ? 'row' : 'column', alignItems: wide ? 'center' : 'stretch' }]}>
        <View style={{ flex: wide ? 1 : undefined }}>
          <Text style={styles.footerTitle}>
            {total} {total === 1 ? 'filter' : 'filters'} active
          </Text>
          <Text style={styles.footerText}>Adjust any category before applying.</Text>
        </View>
        <View style={{ flexDirection: 'row', gap: 9 }}>
          <Pressable accessibilityRole="button" onPress={() => setDraft((d) => ({ ...d, [activeKey]: [] }))} style={styles.clearBtn}>
            <Text style={styles.clearText}>Clear this</Text>
          </Pressable>
          <Pressable accessibilityRole="button" onPress={apply} style={({ pressed }) => [styles.applyBtn, !wide && { flex: 1 }, pressed && { opacity: 0.85 }]}>
            <Text style={styles.applyText}>Show matching options →</Text>
          </Pressable>
        </View>
      </View>
    </View>
  );

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: c.bg }} edges={['top']}>
      <ScrollView contentContainerStyle={{ paddingHorizontal: wide ? 28 : 0, paddingBottom: 40 }}>
        <View style={{ width: '100%', maxWidth: 1224, alignSelf: 'center' }}>
          {/* Top bar */}
          <View style={[styles.topbar, !wide && { paddingHorizontal: 16 }]}>
            <Pressable accessibilityRole="link" onPress={() => navigation.navigate('Home')} style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
              <View style={styles.brandMark}>
                <Text style={styles.brandMarkText}>↗</Text>
              </View>
              <Text style={styles.brand}>neoquest</Text>
            </Pressable>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
              {wide && <Text style={styles.topLabel}>BUILD YOUR SIDE QUEST</Text>}
              <Pressable accessibilityRole="button" accessibilityLabel="Account" onPress={() => navigation.navigate('SignIn')} style={styles.avatar}>
                <Text style={styles.avatarText}>V</Text>
              </Pressable>
            </View>
          </View>

          {/* Heading */}
          <View style={[styles.heading, !wide && { paddingHorizontal: 16 }]}>
            <View style={{ flex: 1, maxWidth: 444 }}>
              <Text style={styles.eyebrow}>DISCOVER · REFINE · GO</Text>
              <Text style={[styles.h1, !wide && { fontSize: 32, lineHeight: 34 }]}>Build Your nEoQuest</Text>
              <Text style={styles.sub}>Set your group's limits, dial in the details, and find a quest that fits.</Text>
            </View>
            <Pressable accessibilityRole="button" onPress={() => setDraft(emptyFilters())} style={{ alignSelf: 'flex-end', paddingVertical: 10 }}>
              <Text style={styles.reset}>Reset all ↺</Text>
            </Pressable>
          </View>

          {wide ? (
            <View style={styles.workspace}>
              {sidebar}
              {editor}
            </View>
          ) : (
            <View style={{ gap: 4 }}>
              {sidebar}
              <View style={[styles.workspace, { marginHorizontal: 16, marginTop: 12 }]}>{editor}</View>
            </View>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  topbar: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingTop: 24, height: 62 + 0 },
  brandMark: { width: 30, height: 30, borderRadius: 10, backgroundColor: c.lime, alignItems: 'center', justifyContent: 'center' },
  brandMarkText: { fontFamily: font.interBold, fontSize: 17, color: c.ink },
  brand: { fontFamily: font.interBold, fontSize: 23, letterSpacing: -1, color: c.ink },
  topLabel: { fontFamily: font.interSemi, fontSize: 12, letterSpacing: 0.7, color: c.muted },
  avatar: { width: 38, height: 38, borderRadius: 50, backgroundColor: c.avatar, alignItems: 'center', justifyContent: 'center' },
  avatarText: { fontFamily: font.interBold, fontSize: 13, color: c.ink },
  heading: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 34, marginBottom: 23 },
  eyebrow: { fontFamily: font.interBold, fontSize: 11, letterSpacing: 1.7, color: c.label },
  h1: { fontFamily: font.interBold, fontSize: 38, lineHeight: 39.5, letterSpacing: -1.8, color: c.ink, marginTop: 9 },
  sub: { fontFamily: font.inter, fontSize: 14, lineHeight: 22.4, color: c.muted, marginTop: 10 },
  reset: { fontFamily: font.interBold, fontSize: 13, color: '#55574F', textDecorationLine: 'underline' },
  workspace: {
    flexDirection: 'row',
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: c.border,
    borderRadius: 23,
    overflow: 'hidden',
    minHeight: 631,
    shadowColor: 'rgb(30,32,20)',
    shadowOpacity: 0.04,
    shadowRadius: 17,
    shadowOffset: { width: 0, height: 12 },
  },
  sidebar: { width: 278, backgroundColor: c.sidebar, borderRightWidth: 1, borderRightColor: c.border, paddingHorizontal: 12, paddingTop: 18 },
  sideHeading: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', height: 42, paddingLeft: 11, paddingRight: 11 },
  sideHeadingText: { fontFamily: font.interBold, fontSize: 12, letterSpacing: 1, color: c.ink },
  count: { width: 23, height: 23, borderRadius: 30, backgroundColor: c.lime, alignItems: 'center', justifyContent: 'center' },
  countText: { fontFamily: font.interBold, fontSize: 11, color: c.ink },
  navItem: { height: 55, borderRadius: 12, flexDirection: 'row', alignItems: 'center', paddingLeft: 11, paddingRight: 14, gap: 12 },
  navIcon: { width: 29, height: 29, borderRadius: 9, alignItems: 'center', justifyContent: 'center' },
  navIconText: { fontFamily: font.inter, fontSize: 14 },
  navLabel: { fontFamily: font.interBold, fontSize: 13 },
  navSub: { fontFamily: font.inter, fontSize: 11, marginTop: 3 },
  chevron: { fontFamily: font.inter, fontSize: 17 },
  sideFoot: { borderTopWidth: 1, borderTopColor: c.border, marginHorizontal: 8, marginTop: 'auto', marginBottom: 16, paddingTop: 18 },
  sideFootText: { fontFamily: font.inter, fontSize: 11, lineHeight: 17, color: '#8B8D84' },
  editorHeader: { flexDirection: 'row', justifyContent: 'space-between', borderBottomWidth: 1, borderBottomColor: c.border, paddingBottom: 23 },
  editorIcon: { width: 42, height: 42, borderRadius: 13, backgroundColor: c.lime, alignItems: 'center', justifyContent: 'center', marginTop: 5 },
  editorTitle: { fontFamily: font.interBold, fontSize: 22, letterSpacing: -0.6, color: c.ink },
  editorDesc: { fontFamily: font.inter, fontSize: 13, lineHeight: 20, color: c.muted, marginTop: 7 },
  modeTag: { backgroundColor: c.tag, borderRadius: 7, height: 27.5, paddingHorizontal: 9, justifyContent: 'center' },
  modeTagText: { fontFamily: font.interBold, fontSize: 10, letterSpacing: 0.8, color: '#686A61' },
  sectionHeading: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 27, gap: 12 },
  sectionLeft: { fontFamily: font.interBold, fontSize: 12, letterSpacing: 0.7, color: c.muted2 },
  sectionRight: { fontFamily: font.interBold, fontSize: 10, letterSpacing: 0.5, color: '#9A9C93' },
  chip: { height: 38, borderRadius: 999, borderWidth: 1, paddingHorizontal: 15, justifyContent: 'center' },
  chipText: { fontFamily: font.interBold, fontSize: 12 },
  panel: { flexDirection: 'row', gap: 13, backgroundColor: c.panel, borderWidth: 1, borderColor: c.border, borderRadius: 16, padding: 18, marginTop: 28 },
  panelIcon: { width: 34, height: 34, borderRadius: 10, backgroundColor: c.lime, alignItems: 'center', justifyContent: 'center' },
  panelTitle: { fontFamily: font.interBold, fontSize: 14, color: c.ink },
  panelText: { fontFamily: font.inter, fontSize: 12, lineHeight: 19.8, color: c.muted, marginTop: 5 },
  suggested: { flexDirection: 'row', alignItems: 'center', gap: 12, borderTopWidth: 1, borderTopColor: c.border, marginTop: 27, paddingTop: 23 },
  suggestTitle: { fontFamily: font.interBold, fontSize: 13, color: c.ink },
  suggestText: { fontFamily: font.inter, fontSize: 12, color: c.muted, marginTop: 6 },
  suggestPill: { backgroundColor: '#FFFFFF', borderWidth: 1, borderColor: c.border, borderRadius: 8, height: 28.5, paddingHorizontal: 10, justifyContent: 'center' },
  suggestPillText: { fontFamily: font.interBold, fontSize: 9, letterSpacing: 0.8, color: c.muted },
  footer: { marginTop: 'auto', borderTopWidth: 1, borderTopColor: c.border, paddingTop: 18, paddingBottom: 28, gap: 14 },
  footerTitle: { fontFamily: font.interBold, fontSize: 12, color: c.ink },
  footerText: { fontFamily: font.inter, fontSize: 12, color: '#85877E', marginTop: 5 },
  clearBtn: { height: 40, borderRadius: 999, borderWidth: 1, borderColor: c.chipBorder, backgroundColor: '#FFFFFF', paddingHorizontal: 19, justifyContent: 'center' },
  clearText: { fontFamily: font.interBold, fontSize: 12, color: '#55574F' },
  applyBtn: { height: 40, borderRadius: 999, backgroundColor: c.button, paddingHorizontal: 19, alignItems: 'center', justifyContent: 'center' },
  applyText: { fontFamily: font.interBold, fontSize: 12, color: '#FFFFFF' },
});
