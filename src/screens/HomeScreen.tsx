import React, { useRef } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { Image } from 'expo-image';
import { SafeAreaView } from 'react-native-safe-area-context';
import { img } from '../assets';
import { font, home } from '../theme';
import { MixedLine } from '../components/GradientText';
import { Pill, useWide } from '../components/ui';
import { GoogleMap } from '../components/GoogleMap';
import { activities } from '../data';
import { useAuth } from '../AuthContext';
import type { ScreenProps } from '../navigation';

const steps = [
  { n: '01', title: 'Get Started', body: 'Browse nearby activities and hidden gems tailored to your interests.' },
  { n: '02', title: 'Customize and Configure', body: 'Compare locations and find the perfect activity for your next hangout,' },
  { n: '03', title: 'Grow Your Business', body: 'Complete your quest and turn everyday outings into precious memories.' },
];

/** Framed media box: the 10px lavender border around the embeds and the group photo. */
function Framed({ children, ratio, style }: { children: React.ReactNode; ratio: number; style?: object }) {
  return <View style={[{ borderWidth: 10, borderColor: home.lavender, aspectRatio: ratio, overflow: 'hidden' }, style]}>{children}</View>;
}

function Divider({ source, width }: { source: number; width: number }) {
  return <Image source={source} style={{ width, maxWidth: '100%', height: 4, alignSelf: 'center' }} contentFit="fill" />;
}

export default function HomeScreen({ navigation }: ScreenProps<'Home'>) {
  const { wide, width } = useWide();
  const { user, signOut } = useAuth();
  const scroller = useRef<React.ComponentRef<typeof ScrollView>>(null);
  const contactY = useRef(0);
  const gutter = wide ? 53 : 20;

  const s = {
    title: wide ? 150 : Math.min(96, width * 0.22),
    h1: wide ? 60 : 36,
    h1Line: wide ? 60 : 40,
    stat: wide ? 40 : 26,
    statLine: wide ? 60 : 38,
    big: wide ? 80 : 56,
  };
  const display = { fontFamily: font.display, letterSpacing: -1.5 } as const;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: home.bg }} edges={['top']}>
      <ScrollView ref={scroller} contentContainerStyle={{ paddingBottom: 80 }}>
        <View style={{ width: '100%', maxWidth: 1280, alignSelf: 'center' }}>
          {/* ---- Navigation ---- */}
          <View style={[styles.nav, { paddingHorizontal: wide ? 9 : 12 }]}>
            <Image source={img.logoMark} style={{ width: wide ? 79 : 52, height: wide ? 82 : 54 }} contentFit="cover" accessibilityLabel="NeoQuest logo" />
            <View style={[styles.navPill, wide ? styles.navPillFloat : styles.navPillPhone]}>
              {[
                { label: 'Map', onPress: () => navigation.navigate('Map') },
                { label: 'Activities', onPress: () => navigation.navigate('List') },
                { label: 'Contact', onPress: () => scroller.current?.scrollTo({ y: contactY.current, animated: true }) },
              ].map((l) => (
                <Pressable key={l.label} accessibilityRole="link" onPress={l.onPress} hitSlop={8}>
                  <Text style={styles.navItem}>{l.label}</Text>
                </Pressable>
              ))}
            </View>
            {user ? (
              <Pill label={`${user.name.split(' ')[0]} · Sign out`} bg={home.lavender} color={home.ink} onPress={signOut} style={!wide && { paddingHorizontal: 16, paddingVertical: 10 }} />
            ) : (
              <Pill label="Sign In" bg={home.lavender} color={home.ink} arrow={img.arrowSignIn} onPress={() => navigation.navigate('SignIn')} style={!wide && { paddingHorizontal: 16, paddingVertical: 10 }} />
            )}
          </View>

          {/* ---- NeoQuest title ---- */}
          <Text style={[styles.title, { fontSize: s.title, lineHeight: s.title * 1.05, letterSpacing: -s.title * 0.03 }]} accessibilityRole="header">
            NeoQuest
          </Text>
          <View style={{ marginTop: wide ? 4 : 0, paddingHorizontal: gutter }}>
            <Divider source={img.dividerHero} width={785} />
          </View>

          {/* ---- Hero ---- */}
          <View style={{ paddingHorizontal: gutter, marginTop: wide ? 45 : 32, gap: wide ? 40 : 28 }}>
            <View style={{ flexDirection: wide ? 'row' : 'column', justifyContent: 'space-between', gap: 28 }}>
              <View style={{ flex: wide ? 1 : undefined, maxWidth: 620, gap: 22, paddingTop: wide ? 30 : 0 }}>
                <View>
                  <MixedLine parts={['Discover the ', { g: 'story' }]} style={[display, { fontSize: s.h1, lineHeight: s.h1Line }]} />
                  <MixedLine parts={[{ g: 'around' }, ' every corner.']} style={[display, { fontSize: s.h1, lineHeight: s.h1Line }]} />
                </View>
                <Text style={[styles.heroBody, !wide && { fontSize: 17, lineHeight: 25 }]}>
                  Your next great adventure is just seconds away. Connect with friends, explore exciting new activities, and fill your days with endless possibilities at the click of a button.
                </Text>
              </View>
              <Framed ratio={542 / 452} style={{ width: wide ? 542 : '100%' }}>
                <Image source={img.embedPlaceholder} style={StyleSheet.absoluteFill} contentFit="cover" />
              </Framed>
            </View>

            <View style={{ flexDirection: wide ? 'row' : 'column', alignItems: wide ? 'center' : 'stretch', gap: wide ? 133 : 28 }}>
              <Framed ratio={587 / 445} style={{ width: wide ? 587 : '100%' }}>
                <Image source={img.groupPhoto} style={StyleSheet.absoluteFill} contentFit="cover" accessibilityLabel="Group of NeoQuest explorers" />
              </Framed>
              <View>
                <MixedLine parts={['11,513 campus ', { g: 'quests' }]} style={[display, { fontSize: s.stat, lineHeight: s.statLine }]} />
                <MixedLine parts={['5,512 active ', { g: 'explorers' }]} style={[display, { fontSize: s.stat, lineHeight: s.statLine }]} />
                <MixedLine parts={['4.9★ average ', { g: 'rating' }]} style={[display, { fontSize: s.stat, lineHeight: s.statLine }]} />
              </View>
            </View>
          </View>

          {/* ---- Explore ---- */}
          <View style={{ paddingHorizontal: wide ? 33 : 20, marginTop: wide ? 130 : 70 }}>
            <Divider source={img.dividerExplore} width={785} />
            <View style={{ alignItems: 'center', gap: 40, marginTop: 40, paddingHorizontal: wide ? 207 : 0 }}>
              <Text style={styles.eyebrow}>Explore</Text>
              <View>
                <MixedLine center parts={['your next  ', { g: 'adventure' }]} style={[display, { fontSize: s.h1, lineHeight: s.h1Line, textAlign: 'center' }]} />
                <MixedLine center parts={[{ g: 'is closer' }, ' than you think.']} style={[display, { fontSize: s.h1, lineHeight: s.h1Line, textAlign: 'center' }]} />
              </View>
              <Text style={[styles.para, { textAlign: 'center' }]}>
                Discover hidden and gems and exciting activities right around you. Explore the map to find experiences that match your interests.
              </Text>
              <Pill label="Explore the Map" onPress={() => navigation.navigate('Map')} />
            </View>
            <View style={{ marginTop: 40, alignSelf: 'center', width: wide ? 980 : '100%', maxWidth: '100%' }}>
              <Framed ratio={980 / 606}>
                <GoogleMap items={activities} />
              </Framed>
            </View>
          </View>

          {/* ---- How it works ---- */}
          <View style={{ marginHorizontal: wide ? 33 : 20, marginTop: wide ? 120 : 70, borderTopWidth: 1, borderTopColor: home.divider, paddingTop: 80, gap: 80 }}>
            <View style={{ flexDirection: wide ? 'row' : 'column', justifyContent: 'space-between', alignItems: wide ? 'flex-start' : 'center', gap: 24 }}>
              <MixedLine center={!wide} parts={[{ g: 'Find' }, ' your next  ', { g: 'quest' }]} style={[display, { fontSize: s.h1, lineHeight: s.h1Line }]} />
              <Pill label="Explore Activities" onPress={() => navigation.navigate('List')} />
            </View>
            <View style={{ flexDirection: wide ? 'row' : 'column', gap: 20 }}>
              {steps.map((st, i) => (
                <View
                  key={st.n}
                  accessibilityLabel={`Step ${i + 1} of 3`}
                  style={{ flex: wide ? 1 : undefined, borderTopWidth: 1, borderTopColor: i === 0 ? home.lavender : home.divider, paddingTop: wide ? 60 : 40, paddingBottom: 20, paddingRight: 30, gap: wide ? 60 : 32 }}
                >
                  <Text style={{ fontFamily: font.sans, fontSize: s.big, lineHeight: s.big, letterSpacing: -s.big * 0.04, color: home.lavender }}>{st.n}</Text>
                  <View style={{ gap: 20 }}>
                    <Text style={{ fontFamily: font.serif, fontSize: 18, lineHeight: 18, letterSpacing: -0.54, color: home.lavender }}>{st.title}</Text>
                    <Text style={styles.para}>{st.body}</Text>
                  </View>
                </View>
              ))}
            </View>
          </View>

          {/* ---- Contact ---- */}
          <View
            onLayout={(e) => (contactY.current = e.nativeEvent.layout.y)}
            style={{ marginHorizontal: wide ? 33 : 20, marginTop: 80, borderTopWidth: 0.5, borderTopColor: home.divider, paddingTop: 78, alignItems: 'center', gap: 20 }}
          >
            <MixedLine center parts={[{ g: 'Contact' }, ' ', { g: 'Us' }]} style={[display, { fontSize: s.h1, lineHeight: s.h1Line }]} />
            <Text style={[styles.para, { textAlign: 'center', maxWidth: 600 }]}>
              Have a question or idea for a new quest? We’d love to hear from you. Reach out and help us make every adventure better.
            </Text>
            {/* TODO: point this at your contact email or form. */}
            <Pill label="Get In Touch" bg={home.lavender} color={home.ink} arrow={img.arrowContact} style={{ width: 600, maxWidth: '100%', height: 48, marginTop: 18 }} />
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  nav: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingTop: 1, minHeight: 84 },
  navPill: {
    borderRadius: 100,
    backgroundColor: home.navPill,
    flexDirection: 'row',
    alignItems: 'center',
  },
  // Desktop: floats centered at the top, 258×44 as in Figma.
  navPillFloat: { position: 'absolute', left: '50%', transform: [{ translateX: -129 }], top: 16, width: 258, height: 44, justifyContent: 'space-around', paddingHorizontal: 12 },
  // Phone: sits in the row between the logo and Sign In.
  navPillPhone: { height: 36, gap: 12, paddingHorizontal: 12 },
  navItem: { fontFamily: font.sansBold, fontSize: 14, lineHeight: 19.6, letterSpacing: -0.35, color: '#000000' },
  title: { fontFamily: font.title, color: '#FFFFFF', textAlign: 'center', marginTop: 4 },
  heroBody: { fontFamily: font.inter, fontSize: 20, lineHeight: 28, color: '#FFFFFF' },
  eyebrow: { fontFamily: font.mono, fontSize: 12, lineHeight: 16.8, letterSpacing: -0.12, color: home.lavender, textAlign: 'center' },
  para: { fontFamily: font.sans, fontSize: 15, lineHeight: 21, letterSpacing: -0.075, color: home.body },
});
